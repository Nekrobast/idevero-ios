param([string]$IpaPath = ".\Idevero-iOS-0.2.8-DeviceUnsigned.ipa", [string]$ChecksumsPath = ".\SHA256SUMS.txt", [string]$ManifestPath = ".\manifest.json")
$ErrorActionPreference = "Stop"
if (-not (Test-Path -LiteralPath $IpaPath -PathType Leaf)) { throw "FAIL: IPA not found: $IpaPath" }
if (-not (Test-Path -LiteralPath $ChecksumsPath -PathType Leaf)) { throw "FAIL: checksum file not found: $ChecksumsPath" }
$actual = (Get-FileHash -LiteralPath $IpaPath -Algorithm SHA256).Hash.ToLowerInvariant()
$line = Get-Content -LiteralPath $ChecksumsPath | Where-Object { $_ -match "Idevero-iOS-0\.2\.8-DeviceUnsigned\.ipa" } | Select-Object -First 1
if (-not $line) { throw "FAIL: IPA entry missing from SHA256SUMS.txt" }
$expected = ($line -split "\s+")[0].ToLowerInvariant()
if ($actual -ne $expected) { throw "FAIL: SHA-256 mismatch`nExpected: $expected`nActual:   $actual" }
if (-not (Test-Path -LiteralPath $ManifestPath -PathType Leaf)) { throw "FAIL: candidate manifest missing" }
$candidateManifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
if ($candidateManifest.version -ne "0.2.8" -or $candidateManifest.build -ne 12) { throw "FAIL: expected 0.2.8 build 12" }
if ($candidateManifest.ipaSHA256 -ne $actual) { throw "FAIL: manifest does not match IPA" }
if ($candidateManifest.sourceCommit -notmatch '^[0-9a-f]{40}$') { throw "FAIL: invalid source commit" }
if ($candidateManifest.physicalQualityV6 -ne "AWAITING FINAL IPHONE RETEST") { throw "FAIL: invalid physical validation status" }
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $IpaPath))
try { if (-not ($archive.Entries | Where-Object { $_.FullName -eq "Payload/Idevero.app/Info.plist" } | Select-Object -First 1)) { throw "FAIL: Payload/Idevero.app/Info.plist is missing" } } finally { $archive.Dispose() }
Write-Host "PASS: IDEVERO 0.2.8 IPA integrity preflight"
Write-Host "SHA-256: $actual"
Write-Host "Build: 12; source commit: $($candidateManifest.sourceCommit)"
Write-Host "Physical Quality V6: AWAITING FINAL IPHONE RETEST"
