// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    fullRepresentation: Item {
        implicitWidth: 164
        implicitHeight: 48

        Rectangle {
            anchors.fill: parent
            color: statusMouse.containsMouse ? "#24162B" : "transparent"
            border.color: statusMouse.containsMouse ? "#62DDE4" : "transparent"
            border.width: 1
        }

        Row {
            anchors.centerIn: parent
            spacing: 7

            Rectangle {
                width: 8
                height: 8
                anchors.verticalCenter: parent.verticalCenter
                color: "#D63BAC"
                border.color: "#15101F"
                border.width: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                Text {
                    text: "MARISHOKU/OS"
                    color: "#FFF3FF"
                    font.family: "Terminus"
                    font.pixelSize: 12
                    font.bold: true
                    renderType: Text.NativeRendering
                }
                Text {
                    text: "裏 / URA · JP READY"
                    color: "#62DDE4"
                    font.family: "Terminus"
                    font.pixelSize: 8
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }
        }

        Controls.ToolTip.visible: statusMouse.containsMouse
        Controls.ToolTip.text: "JAPANESE INPUT // FCITX 5 + MOZC"
        Controls.ToolTip.delay: 300

        MouseArea {
            id: statusMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("marishoku:org.marishoku.japanese.desktop")
        }
    }
}
