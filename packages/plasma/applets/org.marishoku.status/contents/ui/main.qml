// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    fullRepresentation: Item {
        implicitWidth: 164
        implicitHeight: 48

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
                    text: "裏 / URA · MR-10"
                    color: "#62DDE4"
                    font.family: "Terminus"
                    font.pixelSize: 8
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
