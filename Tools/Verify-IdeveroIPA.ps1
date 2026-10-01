param(
    [Parameter(Position = 0)]
    [string]$Path = "."
)

$ErrorActionPreference = "Stop"
$ExpectedHash = "d3b52d0d2b4f6e68fa2bcce5467774724b0dd0c08fd08612c2e1d11dae0578cf"
$ExpectedName = "Idevero-iOS-0.2.3-DeviceUnsigned.ipa"

function Fail([string]$Message) {
    Write-Host "FAIL: $Message" -ForegroundColor Red
    exit 1
}

try {
    $Item = Get-Item -LiteralPath $Path -ErrorAction Stop
    if ($Item.PSIsContainer) {
        $Candidates = @(Get-ChildItem -LiteralPath $Item.FullName -Filter $ExpectedName -File -Recurse)
        if ($Candidates.Count -eq 0) { Fail "No se encontró $ExpectedName en $($Item.FullName)." }
        if ($Candidates.Count -gt 1) { Fail "Se encontraron varios IPA; indica la ruta exacta del archivo." }
        $Ipa = $Candidates[0]
    } else {
        $Ipa = $Item
    }

    if ($Ipa.Extension -ne ".ipa") { Fail "El archivo seleccionado no tiene extensión .ipa." }

    $ActualHash = (Get-FileHash -LiteralPath $Ipa.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($ActualHash -ne $ExpectedHash) {
        Fail "SHA-256 incorrecto. Esperado: $ExpectedHash. Obtenido: $ActualHash."
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $Archive = [System.IO.Compression.ZipFile]::OpenRead($Ipa.FullName)
    try {
        $Names = @($Archive.Entries | ForEach-Object { $_.FullName })
        if (-not ($Names | Where-Object { $_ -eq "Payload/Idevero.app/" })) {
            Fail "El ZIP no contiene Payload/Idevero.app/."
        }
        if (-not ($Names | Where-Object { $_ -eq "Payload/Idevero.app/Info.plist" })) {
            Fail "Falta Payload/Idevero.app/Info.plist."
        }
        if (-not ($Names | Where-Object { $_ -eq "Payload/Idevero.app/Idevero" })) {
            Fail "Falta el ejecutable Payload/Idevero.app/Idevero."
        }
    } finally {
        $Archive.Dispose()
    }

    Write-Host "PASS: IPA auténtico e íntegro." -ForegroundColor Green
    Write-Host "FILE: $($Ipa.FullName)"
    Write-Host "SHA256: $ActualHash"
    Write-Host "BUNDLE: Payload/Idevero.app/"
    exit 0
} catch {
    Fail $_.Exception.Message
}
