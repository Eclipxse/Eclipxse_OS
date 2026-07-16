// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    property var tools: [
        { glyph: "♥", url: "applications:org.kde.dolphin.desktop", color: "#d63bac" },
        { glyph: "✎", url: "applications:org.kde.kate.desktop", color: "#201727" },
        { glyph: "⚒", url: "applications:systemsettings.desktop", color: "#201727" },
        { glyph: "□", url: "applications:org.kde.spectacle.desktop", color: "#201727" },
        { glyph: "A", url: "", color: "#201727" },
        { glyph: "╱", url: "applications:org.marishoku.konsole.desktop", color: "#201727" },
        { glyph: "▣", url: "applications:org.kde.dolphin.desktop", color: "#201727" },
        { glyph: "○", url: "applications:firefox-esr.desktop", color: "#201727" },
        { glyph: "☝", url: "", color: "#201727" },
        { glyph: "▦", url: "applications:org.kde.plasma-systemmonitor.desktop", color: "#201727" }
    ]

    fullRepresentation: Item {
        implicitWidth: 48
        implicitHeight: 490

        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Repeater {
                model: root.tools

                delegate: Rectangle {
                    required property var modelData
                    width: 42
                    height: 42
                    color: toolMouse.pressed ? "#c8b9cc" : "#d8cdd9"
                    border.color: "#15101f"
                    border.width: 2

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 3
                        anchors.topMargin: 3
                        width: parent.width - 6
                        height: 2
                        color: "#fff3ff"
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: modelData.color
                        font.family: "Noto Sans Mono"
                        font.pixelSize: 23
                        font.bold: true
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: toolMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.url !== "") {
                                Qt.openUrlExternally(modelData.url)
                            }
                        }
                    }
                }
            }
        }
    }
}
