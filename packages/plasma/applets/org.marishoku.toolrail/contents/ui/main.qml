// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    property var tools: [
        { glyph: "\u2665", url: "applications:org.marishoku.welcome.desktop", color: "#d63bac" },
        { glyph: "TXT", url: "applications:org.kde.kate.desktop", color: "#201727" },
        { glyph: "CFG", url: "applications:org.marishoku.center.desktop", color: "#201727" },
        { glyph: "[ ]", url: "applications:org.kde.spectacle.desktop", color: "#201727" },
        { glyph: "\u3042", url: "applications:org.fcitx.Fcitx5.desktop", color: "#8f276f" },
        { glyph: ">_", url: "applications:org.marishoku.konsole.desktop", color: "#201727" },
        { glyph: "DIR", url: "applications:org.kde.dolphin.desktop", color: "#201727" },
        { glyph: "NET", url: "applications:firefox-esr.desktop", color: "#201727" },
        { glyph: "O/U", url: "applications:org.marishoku.profile-omote.desktop", color: "#7141b8" },
        { glyph: "DSK", url: "applications:org.marishoku.storage.desktop", color: "#201727" }
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
                        font.pixelSize: modelData.glyph.length > 1 ? 11 : 23
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
