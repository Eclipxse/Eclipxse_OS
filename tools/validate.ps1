$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$required = @(
    'README.md',
    'ASSETS.yml',
    'docs/BRAND.md',
    'docs/CONTENT-PROFILES.md',
    'docs/HARDWARE-TARGET.md',
    'docs/ROADMAP.md',
    'themes/colors/MARISHOKU.colors',
    'themes/plasma-style/org.marishoku.desktop/metadata.json',
    'themes/global/org.marishoku.os/manifest.json',
    'themes/aurorae/MARISHOKU/metadata.desktop',
    'themes/aurorae/MARISHOKU/MARISHOKUrc',
    'themes/aurorae/MARISHOKU/decoration.svg',
    'themes/aurorae/MARISHOKU/close.svg',
    'themes/aurorae/MARISHOKU/minimize.svg',
    'themes/aurorae/MARISHOKU/maximize.svg',
    'themes/aurorae/MARISHOKU/restore.svg'
)

foreach ($path in $required) {
    $full = Join-Path $root $path
    if (-not (Test-Path -LiteralPath $full)) {
        throw "Missing required file: $path"
    }
}

$plasma = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/plasma-style/org.marishoku.desktop/metadata.json') | ConvertFrom-Json
$global = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/global/org.marishoku.os/manifest.json') | ConvertFrom-Json

if ($plasma.'X-Plasma-API-Minimum-Version' -ne '6.0') {
    throw 'Plasma theme does not declare Plasma 6 support.'
}
if ($global.KPackageStructure -ne 'Plasma/LookAndFeel') {
    throw 'Global theme has the wrong KPackageStructure.'
}

$auroraeRc = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/aurorae/MARISHOKU/MARISHOKUrc')
if ($auroraeRc -notmatch 'TitleHeight=26') {
    throw 'Aurorae title height has drifted from the v0.1 design token.'
}

Write-Host 'MARISHOKU/OS scaffold validation passed.' -ForegroundColor Magenta
