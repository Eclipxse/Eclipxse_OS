$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$required = @(
    'README.md',
    'ASSETS.yml',
    'docs/BRAND.md',
    'docs/CONTENT-PROFILES.md',
    'docs/HARDWARE-TARGET.md',
    'docs/ROADMAP.md',
    'docs/TYPOGRAPHY.md',
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
    'themes/aurorae/MARISHOKU/restore.svg',
    'themes/kvantum/MARISHOKU/MARISHOKU.kvconfig',
    'themes/kvantum/MARISHOKU/MARISHOKU.svg',
    'themes/typography/MARISHOKU.conf'
    'themes/icons/MARISHOKU/index.theme'
    'themes/icons/MARISHOKU/scalable/apps/marishoku-start.svg'
    'artwork/wallpapers/MARISHOKU-NightLine/metadata.json'
    'artwork/wallpapers/MARISHOKU-NightLine/contents/images/1920x1080.png'
    'artwork/wallpapers/MARISHOKU-NeonVelvet/metadata.json'
    'artwork/wallpapers/MARISHOKU-NeonVelvet/contents/images/1920x1080.png'
    'tools/apply-desktop-layout.js'
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

$kvantumSvg = 'themes/kvantum/MARISHOKU/MARISHOKU.svg'
$kvantumFramePositions = @('top', 'left', 'bottom', 'right', 'topleft', 'topright', 'bottomleft', 'bottomright')

function Assert-KvantumFrames([string] $family, [string[]] $states) {
    foreach ($state in $states) {
        $base = "${family}-${state}"
        Assert-SvgIds $kvantumSvg @(
            $base
            $kvantumFramePositions | ForEach-Object { "${base}-${_}" }
        )
    }
}

Assert-KvantumFrames 'button' @('normal', 'focused', 'pressed', 'toggled')
Assert-KvantumFrames 'lineedit' @('normal', 'focused')
Assert-KvantumFrames 'common' @('normal', 'focused')
Assert-KvantumFrames 'tab' @('normal', 'focused', 'toggled')
Assert-KvantumFrames 'itemview' @('focused', 'pressed', 'toggled')
Assert-KvantumFrames 'menuitem' @('pressed', 'toggled')
Assert-KvantumFrames 'menubaritem' @('pressed', 'toggled')
Assert-KvantumFrames 'scrollbarslider' @('normal', 'focused', 'pressed')
Assert-KvantumFrames 'slider' @('normal', 'toggled')
Assert-KvantumFrames 'progress' @('normal')
Assert-KvantumFrames 'progress-pattern' @('normal', 'disabled')
Assert-KvantumFrames 'menu' @('normal')
Assert-KvantumFrames 'tooltip' @('normal')
Assert-KvantumFrames 'tabframe' @('normal')

Assert-SvgIds $kvantumSvg @(
    'checkbox-normal', 'checkbox-focused', 'checkbox-checked-normal', 'checkbox-checked-focused',
    'checkbox-tristate-normal', 'checkbox-tristate-focused',
    'radio-normal', 'radio-focused', 'radio-checked-normal', 'radio-checked-focused',
    'slidercursor-normal', 'slidercursor-focused', 'slidercursor-pressed', 'slidercursor-disabled',
    'tree-plus-normal', 'tree-plus-focused', 'tree-plus-disabled',
    'tree-minus-normal', 'tree-minus-focused', 'tree-minus-disabled',
    'splitter-grip-normal', 'splitter-grip-focused', 'splitter-grip-pressed',
    'sizegrip-normal', 'header-separator', 'toolbar-handle'
)

foreach ($direction in @('up', 'right', 'down', 'left')) {
    foreach ($state in @('normal', 'focused', 'pressed', 'toggled', 'disabled')) {
        Assert-SvgIds $kvantumSvg @("arrow-${direction}-${state}")
    }
}

$kvantumFullPath = Join-Path $root $kvantumSvg
[xml] $kvantumDocument = Get-Content -Raw -Encoding UTF8 -LiteralPath $kvantumFullPath
$kvantumIds = Get-SvgIds $kvantumSvg
foreach ($use in $kvantumDocument.SelectNodes('//*[local-name()="use"]')) {
    $reference = $use.GetAttribute('href', 'http://www.w3.org/1999/xlink')
    if ($reference.StartsWith('#') -and -not $kvantumIds.ContainsKey($reference.Substring(1))) {
        throw "Broken SVG reference '$reference' in $kvantumSvg."
    }
}

$kvantumConfig = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'themes/kvantum/MARISHOKU/MARISHOKU.kvconfig')
foreach ($setting in @(
    '(?m)^\[%General\]$',
    '(?m)^animate_states=false$',
    '(?m)^composite=false$',
    '(?im)^window\.color=#C0C0CA$',
    '(?im)^highlight\.color=#000080$',
    '(?m)^frame\.element=button$',
    '(?m)^frame\.element=lineedit$',
    '(?m)^frame\.element=itemview$'
)) {
    if ($kvantumConfig -notmatch $setting) {
        throw "Kvantum configuration is missing expected setting: $setting"
    }
}

$typography = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'themes/typography/MARISHOKU.conf')
foreach ($fontToken in @($tokens.typography.body, $tokens.typography.system, $tokens.typography.title)) {
    $family, $size = $fontToken -split ' (?=\d+$)'
    if ($typography -notmatch "(?m)=${family},${size},") {
        throw "Typography config has drifted from token '$fontToken'."
    }
}

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
    @{ Name = 'dark text on panel face'; Foreground = '#101018'; Background = $tokens.color.panel200 },
    @{ Name = 'title text on active navy'; Foreground = $tokens.color.panel050; Background = $tokens.color.titleBlue },
    @{ Name = 'cyan focus on dark shell'; Foreground = $tokens.color.cyan400; Background = $tokens.color.ink950 }
)

foreach ($pair in $contrastPairs) {
    $ratio = Get-ContrastRatio $pair.Foreground $pair.Background
    if ($ratio -lt 4.5) {
        throw ("Contrast failure for {0}: {1:N2}:1" -f $pair.Name, $ratio)
    }
}

Write-Host 'MARISHOKU/OS Phase 1C validation passed.' -ForegroundColor Cyan
