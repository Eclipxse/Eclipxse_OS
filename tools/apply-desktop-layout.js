// MARISHOKU/OS Plasma 6 desktop layout. @WALLPAPER_URI@ is replaced at install time.

var oldPanels = panelIds;
for (var index = 0; index < oldPanels.length; index += 1) {
    var oldPanel = panelById(oldPanels[index]);
    if (oldPanel) {
        oldPanel.remove();
    }
}

var taskbar = new Panel();
taskbar.location = "bottom";
taskbar.alignment = "left";
taskbar.lengthMode = "fill";
taskbar.height = 58;
taskbar.hiding = "none";

function addFirstWidget(candidates) {
    for (var candidate = 0; candidate < candidates.length; candidate += 1) {
        if (knownWidgetTypes.indexOf(candidates[candidate]) !== -1) {
            return taskbar.addWidget(candidates[candidate]);
        }
    }
    return null;
}

var launcher = addFirstWidget(["org.kde.plasma.kicker", "org.kde.plasma.kickoff"]);
if (launcher) {
    launcher.currentConfigGroup = ["General"];
    launcher.writeConfig("icon", "marishoku-heart");
    launcher.writeConfig("showAppsByName", true);
}

addFirstWidget(["org.kde.plasma.taskmanager", "org.kde.plasma.icontasks"]);
addFirstWidget(["org.kde.plasma.panelspacer"]);
taskbar.addWidget("org.marishoku.status");
addFirstWidget(["org.kde.plasma.systemtray"]);

var clock = addFirstWidget(["org.kde.plasma.digitalclock"]);
if (clock) {
    clock.currentConfigGroup = ["Appearance"];
    clock.writeConfig("showDate", false);
    clock.writeConfig("showSeconds", false);
    clock.writeConfig("use24hFormat", 2);
}

var toolRail = new Panel();
toolRail.location = "left";
toolRail.alignment = "left";
toolRail.lengthMode = "custom";
toolRail.minimumLength = 522;
toolRail.maximumLength = 522;
toolRail.height = 56;
toolRail.hiding = "none";
toolRail.addWidget("org.marishoku.toolrail");

var allDesktops = desktops();
for (var desktopIndex = 0; desktopIndex < allDesktops.length; desktopIndex += 1) {
    var desktop = allDesktops[desktopIndex];
    desktop.wallpaperPlugin = "org.kde.image";
    desktop.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    desktop.writeConfig("Image", "@WALLPAPER_URI@");
    desktop.writeConfig("FillMode", 2);
}
