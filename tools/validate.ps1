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
    'docs/V1-VISUAL-SPEC.md',
    'docs/ARCHITECTURE.md',
    'docs/VM-TEST-CHECKLIST.md',
    'themes/TOKENS.json',
    'themes/colors/MARISHOKU.colors',
    'themes/colors/MARISHOKU-OMOTE.colors',
    'themes/gtk/MARISHOKU/gtk-3.0/gtk.css',
    'themes/gtk/MARISHOKU/gtk-4.0/gtk.css',
    'themes/cursors/MARISHOKU/index.theme',
    'themes/cursors/MARISHOKU/src/left_ptr.cursor',
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
    'themes/global/org.marishoku.os/contents/splash/Splash.qml',
    'themes/global/org.marishoku.os/contents/splash/images/background.png',
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
    'artwork/source/ura-v1-master.png'
    'artwork/concepts/desktop-v1-approved.png'
    'themes/icons/MARISHOKU/index.theme'
    'themes/icons/MARISHOKU/scalable/apps/marishoku-start.svg'
    'artwork/wallpapers/MARISHOKU-NightLine/metadata.json'
    'artwork/wallpapers/MARISHOKU-NightLine/contents/images/1920x1080.png'
    'artwork/wallpapers/MARISHOKU-NeonVelvet/metadata.json'
    'artwork/wallpapers/MARISHOKU-NeonVelvet/contents/images/1920x1080.png'
    'tools/apply-desktop-layout.js'
    'artwork/wallpapers/MARISHOKU-URA/metadata.json'
    'artwork/wallpapers/MARISHOKU-URA/contents/images/1920x1080.png'
    'themes/icons/MARISHOKU/scalable/apps/marishoku-heart.svg'
    'themes/konsole/MARISHOKU.colorscheme'
    'themes/konsole/MARISHOKU.profile'
    'themes/fastfetch/config.jsonc'
    'themes/fastfetch/marishoku-heart.txt'
    'themes/boot/grub/theme.txt'
    'themes/boot/grub/background.png'
    'themes/boot/plymouth/marishoku/marishoku.plymouth'
    'themes/boot/plymouth/marishoku/marishoku.script'
    'themes/sddm/MARISHOKU/metadata.desktop'
    'themes/sddm/MARISHOKU/Main.qml'
    'themes/sddm/MARISHOKU/background.png'
    'profiles/omote/profile.conf'
    'profiles/ura/profile.conf'
    'artwork/wallpapers/MARISHOKU-OMOTE/contents/images/1920x1080.png'
    'artwork/wallpapers/MARISHOKU-URA-V1/contents/images/1920x1080.png'
    'artwork/sounds/MARISHOKU/index.theme'
    'packages/plasma/applets/org.marishoku.status/metadata.json'
    'packages/plasma/applets/org.marishoku.status/contents/ui/main.qml'
    'packages/plasma/applets/org.marishoku.launcher/metadata.json'
    'packages/plasma/applets/org.marishoku.launcher/contents/ui/main.qml'
    'packages/plasma/applets/org.marishoku.launcher/contents/images/heart.svg'
    'packages/plasma/applets/org.marishoku.toolrail/metadata.json'
    'packages/plasma/applets/org.marishoku.toolrail/contents/ui/main.qml'
    'packages/plasma/applets/org.marishoku.toolrail/contents/images/heart.svg'
    'packages/plasma/applets/org.marishoku.toolrail/contents/images/terminal.svg'
    'packages/plasma/applets/org.marishoku.toolrail/contents/images/kana.svg'
    'packages/autostart/org.marishoku.first-run.desktop'
    'packages/applications/org.marishoku.dolphin.desktop'
    'packages/applications/org.marishoku.konsole.desktop'
    'packages/applications/org.marishoku.japanese.desktop'
    'packages/applications/org.marishoku.session.desktop'
    'packages/system-apps/marishoku_center.py'
    'packages/bin/neofetch'
    'packages/installer/branding/marishoku/branding.desc'
    'packages/debian/control'
    'tools/build-v1-assets.py'
    'tools/build-cursors.sh'
    'tools/marishoku-profile'
    'tools/marishoku-first-run'
    'tools/stage-rootfs.sh'
    'tools/build-package.sh'
    'tools/stage-live-build.sh'
    'iso/auto/config'
    'iso/auto/build'
    'iso/config/package-lists/marishoku-desktop.list.chroot'
    'iso/config/hooks/live/0100-marishoku.hook.chroot'
    'iso/artwork/splash.png'
    'iso/build.sh'
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
$fastfetch = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/fastfetch/config.jsonc') | ConvertFrom-Json

if ($plasma.'X-Plasma-API-Minimum-Version' -ne '6.0') {
    throw 'Plasma theme does not declare Plasma 6 support.'
}
if ($global.KPackageStructure -ne 'Plasma/LookAndFeel') {
    throw 'Global theme has the wrong KPackageStructure.'
}
if ($plasma.KPlugin.Version -ne $tokens.version -or $global.KPlugin.Version -ne $tokens.version) {
    throw 'Theme package versions have drifted from themes/TOKENS.json.'
}
if ($fastfetch.logo.type -ne 'file' -or $fastfetch.logo.source -notmatch 'marishoku-heart\.txt$') {
    throw 'Fastfetch does not select the MARISHOKU heart logo.'
}
$fastfetchOs = $fastfetch.modules | Where-Object { $_.type -eq 'custom' -and $_.key -eq 'OS' }
if ($fastfetchOs.format -notmatch '^MARISHOKU/OS') {
    throw 'Fastfetch OS identity is not MARISHOKU/OS.'
}
$fastfetchLogo = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'themes/fastfetch/marishoku-heart.txt')
if ($fastfetchLogo -notmatch '\$1' -or $fastfetchLogo -notmatch 'MARISHOKU/OS') {
    throw 'Fastfetch heart artwork is missing its palette marker or identity label.'
}

$globalDefaults = Get-Content -Raw -LiteralPath (Join-Path $root 'themes/global/org.marishoku.os/contents/defaults')
if ($globalDefaults -match '(?im)^widgetStyle=kvantum\s*$' -and -not (Test-Path (Join-Path $root 'themes/kvantum'))) {
    throw 'Global Theme selects Kvantum before a Kvantum theme is included.'
}

if ($tokens.version -ne '1.0.0') {
    throw 'V1 validation expects themes/TOKENS.json version 1.0.0.'
}

$osRelease = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'packages/branding/os-release')
foreach ($identity in @('ID=marishoku', 'ID_LIKE=debian', 'VERSION_ID="1.0"')) {
    if ($osRelease -notmatch [regex]::Escape($identity)) {
        throw "Missing OS identity: $identity"
    }
}

$isoPackages = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'iso/config/package-lists/marishoku-desktop.list.chroot')
foreach ($package in @('task-kde-desktop', 'task-japanese-kde-desktop', 'plasma-discover', 'calamares', 'plymouth', 'fcitx5-mozc', 'virtualbox-guest-x11')) {
    if ($isoPackages -notmatch "(?m)^$([regex]::Escape($package))$") {
        throw "Live image is missing required package: $package"
    }
}
if ($isoPackages -match '(?m)^discover$') {
    throw "Live image selects Debian's hardware-identification package 'discover' instead of KDE Plasma Discover."
}

$liveStaging = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/stage-live-build.sh')
foreach ($stagingContract in @('packages/debian/control', 'marishoku-system_\$\{package_version\}_all\.deb')) {
    if ($liveStaging -notmatch $stagingContract) {
        throw "Live-image staging does not derive the V1.3 package filename: $stagingContract"
    }
}

$isoBuild = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'iso/build.sh')
foreach ($buildContract in @('Debian 13 \(trixie\)', '30 GiB required', 'sudo: sudo ./iso/build\.sh', 'grub-mkstandalone', '/usr/lib/grub/x86_64-efi')) {
    if ($isoBuild -notmatch $buildContract) {
        throw "ISO build preflight is missing contract: $buildContract"
    }
}

$isoReadme = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'iso/README.md')
if ($isoReadme -notmatch '(?m)\bx11-apps\b' -or $isoReadme -match '(?m)dpkg-dev xcursorgen') {
    throw 'Debian 13 ISO instructions must install x11-apps as the xcursorgen provider.'
}
$themeInstaller = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/install-theme.sh')
if ($themeInstaller -notmatch '(?m)fcitx5-config-qt x11-apps') {
    throw 'Theme dependency installation must use Debian 13 package x11-apps.'
}

$sddm = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'themes/sddm/MARISHOKU/Main.qml')
foreach ($contract in @('sddm.login', 'sddm.reboot', 'sddm.powerOff', 'onLoginFailed')) {
    if ($sddm -notmatch [regex]::Escape($contract)) {
        throw "SDDM theme is missing its $contract contract."
    }
}

$profileTool = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/marishoku-profile')
foreach ($profile in @('MARISHOKU-OMOTE', 'MARISHOKU-URA-V1')) {
    if ($profileTool -notmatch [regex]::Escape($profile)) {
        throw "Profile switcher does not reference $profile."
    }
}

$layoutTool = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/apply-desktop-layout.js')
foreach ($layoutContract in @(
    'var oldPanels = \[\]',
    'for \(var index = oldPanels\.length - 1; index >= 0; index -= 1\)',
    'taskbar\.height = 54',
    'clock\.writeConfig\("fontFamily", "Terminus"\)'
    'org\.marishoku\.launcher'
)) {
    if ($layoutTool -notmatch $layoutContract) {
        throw "Responsive V1.3 layout is missing contract: $layoutContract"
    }
}
if ($layoutTool -match 'var oldPanels = panelIds') {
    throw 'Layout must not iterate the live panelIds collection while removing panels.'
}

foreach ($applet in @('org.marishoku.launcher', 'org.marishoku.status', 'org.marishoku.toolrail')) {
    $metadataPath = Join-Path $root "packages/plasma/applets/$applet/metadata.json"
    $metadata = Get-Content -Raw -Encoding UTF8 -LiteralPath $metadataPath | ConvertFrom-Json
    if ($metadata.KPlugin.Version -ne '1.3.0') {
        throw "V1.3 applet package version drifted for $applet."
    }
}

$launcherQml = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'packages/plasma/applets/org.marishoku.launcher/contents/ui/main.qml')
foreach ($launcherContract in @(
    'MARISHOKU/OS // COMMAND',
    'applications:org\.marishoku\.center\.desktop',
    'applications:org\.marishoku\.japanese\.desktop',
    'applications:org\.marishoku\.session\.desktop',
    'root\.expanded = !root\.expanded'
)) {
    if ($launcherQml -notmatch $launcherContract) {
        throw "V1.3 command launcher is missing contract: $launcherContract"
    }
}

$statusQml = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'packages/plasma/applets/org.marishoku.status/contents/ui/main.qml')
foreach ($statusContract in @('JP READY', 'org\.marishoku\.japanese\.desktop')) {
    if ($statusQml -notmatch $statusContract) {
        throw "V1.3 status applet is missing contract: $statusContract"
    }
}

$centerApp = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'packages/system-apps/marishoku_center.py')
foreach ($centerContract in @('MARISHOKU CONTROL\.EXE', 'VERSION 1\.3\.0 DEV', 'kcm_kscreen', 'fcitx5-config-qt')) {
    if ($centerApp -notmatch $centerContract) {
        throw "V1.3 Control Center is missing contract: $centerContract"
    }
}

$desktopContracts = @{
    'packages/applications/org.marishoku.center.desktop' = 'Exec=marishoku-center --page home'
    'packages/applications/org.marishoku.japanese.desktop' = 'Exec=marishoku-center --page japanese'
    'packages/applications/org.marishoku.session.desktop' = 'Exec=qdbus6 org.kde.LogoutPrompt /LogoutPrompt promptAll'
}
foreach ($entry in $desktopContracts.GetEnumerator()) {
    $desktopFile = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root $entry.Key)
    if ($desktopFile -notmatch [regex]::Escape($entry.Value)) {
        throw "Desktop entry '$($entry.Key)' is missing contract: $($entry.Value)"
    }
}

$installer = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/install-theme.sh')
if ($installer -notmatch 'layout-v1\.3\.applied') {
    throw 'Installer does not use the V1.3 desktop-layout marker.'
}
foreach ($installerContract in @('cp -a "\$applet" "\$applet_target"', 'cmp -s "\$applet/metadata\.json"', 'Plasma layout application failed')) {
    if ($installer -notmatch $installerContract) {
        throw "Hardened V1.3 installer is missing contract: $installerContract"
    }
}
$firstRun = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/marishoku-first-run')
if ($firstRun -notmatch 'welcome-v1\.3\.seen') {
    throw 'First-run launcher does not use the V1.3 marker.'
}
$debianControl = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'packages/debian/control')
if ($debianControl -notmatch '(?m)^Version: 1\.3\.0-1$') {
    throw 'Debian package version is not V1.3.'
}
$packageBuilder = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'tools/build-package.sh')
if ($packageBuilder -notmatch 'PACKAGE_VERSION=.*packages/debian/control') {
    throw 'Package builder does not derive its artifact version from Debian control metadata.'
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
    '(?im)^window\.color=#D8CDD9$',
    '(?im)^highlight\.color=#8F276F$',
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
    @{ Name = 'dark text on panel face'; Foreground = '#201727'; Background = $tokens.color.panel200 },
    @{ Name = 'title text on active magenta'; Foreground = $tokens.color.panel050; Background = $tokens.color.titleMagenta },
    @{ Name = 'cyan focus on dark shell'; Foreground = $tokens.color.cyan400; Background = $tokens.color.ink950 }
)

foreach ($pair in $contrastPairs) {
    $ratio = Get-ContrastRatio $pair.Foreground $pair.Background
    if ($ratio -lt 4.5) {
        throw ("Contrast failure for {0}: {1:N2}:1" -f $pair.Name, $ratio)
    }
}

Write-Host 'MARISHOKU/OS V1.3 repository validation passed.' -ForegroundColor Magenta
