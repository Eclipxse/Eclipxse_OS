// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    property var tools: [
        { icon: "heart.svg", label: "MARISHOKU", url: "applications:org.marishoku.welcome.desktop" },
        { icon: "note.svg", label: "TEXT", url: "applications:org.kde.kate.desktop" },
        { icon: "controls.svg", label: "CONTROL", url: "applications:org.marishoku.center.desktop" },
        { icon: "select.svg", label: "CAPTURE", url: "applications:org.kde.spectacle.desktop" },
        { icon: "kana.svg", label: "日本語", url: "applications:org.fcitx.Fcitx5.desktop" },
        { icon: "terminal.svg", label: "TERMINAL", url: "applications:org.marishoku.konsole.desktop" },
        { icon: "folder.svg", label: "FILES", url: "applications:org.kde.dolphin.desktop" },
        { icon: "network.svg", label: "NETWORK", url: "applications:firefox-esr.desktop" },
        { icon: "profile.svg", label: "OMOTE / URA", url: "applications:org.marishoku.profile-omote.desktop" },
        { icon: "disk.svg", label: "STORAGE", url: "applications:org.marishoku.storage.desktop" }
    ]

    fullRepresentation: Item {
        implicitWidth: 52
        implicitHeight: 502

        Column {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Repeater {
                model: root.tools

                delegate: Rectangle {
                    id: toolButton
                    required property var modelData
                    width: 46
                    height: 46
                    color: toolMouse.pressed ? "#B7A7BC" : toolMouse.containsMouse ? "#E8DCE9" : "#D8CDD9"
                    border.color: "#15101F"
                    border.width: 2

                    Rectangle { x: 3; y: 3; width: parent.width - 6; height: 2; color: toolMouse.pressed ? "#56445E" : "#FFF3FF" }
                    Rectangle { x: 3; y: 3; width: 2; height: parent.height - 6; color: toolMouse.pressed ? "#56445E" : "#FFF3FF" }
                    Rectangle { x: 3; y: parent.height - 5; width: parent.width - 6; height: 2; color: toolMouse.pressed ? "#FFF3FF" : "#56445E" }
                    Rectangle { x: parent.width - 5; y: 3; width: 2; height: parent.height - 6; color: toolMouse.pressed ? "#FFF3FF" : "#56445E" }

                    Image {
                        anchors.centerIn: parent
                        width: 30
                        height: 30
                        source: Qt.resolvedUrl("../images/" + modelData.icon)
                        fillMode: Image.PreserveAspectFit
                        smooth: false
                        mipmap: false
                    }

                    Rectangle {
                        visible: toolMouse.containsMouse
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 20
                        height: 2
                        color: "#62DDE4"
                    }

                    Controls.ToolTip.visible: toolMouse.containsMouse
                    Controls.ToolTip.text: modelData.label
                    Controls.ToolTip.delay: 350

                    MouseArea {
                        id: toolMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally(modelData.url)
                    }
                }
            }
        }
    }
}
