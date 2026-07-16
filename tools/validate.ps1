$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$required = @(
    'README.md',
    'ASSETS.yml',
    'docs/BRAND.md',
    'docs/CONTENT-PROFILES.md',
    'docs/HARDWARE-TARGET.md',
    'docs/ROADMAP.md',
    'themes/TOKENS.json',
    'themes/colors/MARISHOKU.colors',
    'themes/plasma-style/org.marishoku.desktop/metadata.json',
    'themes/plasma-style/org.marishoku.desktop/dialogs/background.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/arrows.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/background.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/button.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/line.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/lineedit.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/panel-background.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/plasmoidheading.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/tasks.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/tooltip.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/viewitem.svg',
    'themes/global/org.marishoku.os/manifest.json',
    'themes/global/org.marishoku.os/contents/defaults',
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
$tokens = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/TOKENS.json') | ConvertFrom-Json

if ($plasma.'X-Plasma-API-Minimum-Version' -ne '6.0') {
    throw 'Plasma theme does not declare Plasma 6 support.'
}
if ($global.KPackageStructure -ne 'Plasma/LookAndFeel') {
    throw 'Global theme has the wrong KPackageStructure.'
}
if ($plasma.KPlugin.Version -ne $tokens.version -or $global.KPlugin.Version -ne $tokens.version) {
    throw 'Theme package versions have drifted from themes/TOKENS.json.'
}

$globalDefaults = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/global/org.marishoku.os/contents/defaults')
if ($globalDefaults -match '(?im)^widgetStyle=kvantum\s*$' -and -not (Test-Path (Join-Path $root 'themes/kvantum'))) {
    throw 'Global Theme selects Kvantum before a Kvantum theme is included.'
}

$auroraeRc = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/aurorae/MARISHOKU/MARISHOKUrc')
if ($auroraeRc -notmatch 'TitleHeight=26') {
    throw 'Aurorae title height has drifted from the v0.1 design token.'
}

function Get-SvgIds([string] $relativePath) {
    $full = Join-Path $root $relativePath
    try {
        [xml] $document = Get-Content -Raw -Encoding UTF8 -LiteralPath $full
    }
    catch {
        throw "Invalid SVG XML in ${relativePath}: $($_.Exception.Message)"
    }

    $ids = @{}
    foreach ($node in $document.SelectNodes('//*[@id]')) {
        if ($ids.ContainsKey($node.id)) {
            throw "Duplicate SVG id '$($node.id)' in $relativePath."
        }
        $ids[$node.id] = $true
    }
    return $ids
}

function Assert-SvgIds([string] $relativePath, [string[]] $requiredIds) {
    $ids = Get-SvgIds $relativePath
    foreach ($id in $requiredIds) {
        if (-not $ids.ContainsKey($id)) {
            throw "Missing SVG id '$id' in $relativePath."
        }
    }
}

$framePositions = @('topleft', 'top', 'topright', 'left', 'center', 'right', 'bottomleft', 'bottom', 'bottomright')
foreach ($path in @(
    'themes/plasma-style/org.marishoku.desktop/dialogs/background.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/background.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/panel-background.svg',
    'themes/plasma-style/org.marishoku.desktop/widgets/tooltip.svg'
)) {
    Assert-SvgIds $path $framePositions
}

foreach ($state in @('normal', 'hover', 'pressed', 'focus')) {
    Assert-SvgIds 'themes/plasma-style/org.marishoku.desktop/widgets/button.svg' @(
        $framePositions | ForEach-Object { "${state}-$_" }
    )
}

foreach ($state in @('normal', 'hover', 'focus', 'attention', 'minimized')) {
    Assert-SvgIds 'themes/plasma-style/org.marishoku.desktop/widgets/tasks.svg' @(
        $framePositions | ForEach-Object { "${state}-$_" }
    )
}

foreach ($state in @('normal', 'hover', 'selected', 'selected+hover')) {
    Assert-SvgIds 'themes/plasma-style/org.marishoku.desktop/widgets/viewitem.svg' @(
        $framePositions | ForEach-Object { "${state}-$_" }
    )
}

Assert-SvgIds 'themes/plasma-style/org.marishoku.desktop/widgets/arrows.svg' @(
    'up-arrow', 'right-arrow', 'down-arrow', 'left-arrow'
)
Assert-SvgIds 'themes/plasma-style/org.marishoku.desktop/widgets/line.svg' @(
    'horizontal-line', 'vertical-line'
)

function Get-RelativeLuminance([string] $hex) {
    $clean = $hex.TrimStart('#')
    if ($clean.Length -ne 6) {
        throw "Expected a six-digit hex color, got '$hex'."
    }

    $channels = @()
    foreach ($offset in @(0, 2, 4)) {
        $channel = [Convert]::ToInt32($clean.Substring($offset, 2), 16) / 255.0
        if ($channel -le 0.04045) {
            $channels += $channel / 12.92
        }
        else {
            $channels += [Math]::Pow(($channel + 0.055) / 1.055, 2.4)
        }
    }

    return (0.2126 * $channels[0]) + (0.7152 * $channels[1]) + (0.0722 * $channels[2])
}

function Get-ContrastRatio([string] $foreground, [string] $background) {
    $a = Get-RelativeLuminance $foreground
    $b = Get-RelativeLuminance $background
    return (([Math]::Max($a, $b) + 0.05) / ([Math]::Min($a, $b) + 0.05))
}

$contrastPairs = @(
    @{ Name = 'light text on dark shell'; Foreground = $tokens.color.panel050; Background = $tokens.color.ink950 },
    @{ Name = 'dark text on panel face'; Foreground = '#201727'; Background = $tokens.color.panel200 },
    @{ Name = 'title text on active magenta'; Foreground = $tokens.color.panel050; Background = $tokens.color.magenta700 },
    @{ Name = 'cyan focus on dark shell'; Foreground = $tokens.color.cyan400; Background = $tokens.color.ink950 }
)

foreach ($pair in $contrastPairs) {
    $ratio = Get-ContrastRatio $pair.Foreground $pair.Background
    if ($ratio -lt 4.5) {
        throw ("Contrast failure for {0}: {1:N2}:1" -f $pair.Name, $ratio)
    }
}

Write-Host 'MARISHOKU/OS Phase 1A validation passed.' -ForegroundColor Magenta
