param(
    [Parameter(Position = 0)]
    [string]$Path = "."
)

$ErrorActionPreference = "Stop"
$ExpectedHash = "cd92b0435120b8f145d95f3ff121d4df437885a29a6e99e2099c4574f2be1e69"
$ExpectedName = "Idevero-iOS-0.2.6-DeviceUnsigned.ipa"

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
