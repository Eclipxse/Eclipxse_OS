// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    fullRepresentation: Item {
        implicitWidth: 202
        implicitHeight: 54

        Row {
            anchors.centerIn: parent
            spacing: 9

            Rectangle {
                width: 9
                height: 9
                anchors.verticalCenter: parent.verticalCenter
                color: "#D63BAC"
                border.color: "#15101F"
                border.width: 1
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1
                Text {
                    text: "MARISHOKU/OS"
                    color: "#FFF3FF"
                    font.family: "Terminus"
                    font.pixelSize: 14
                    font.bold: true
                    renderType: Text.NativeRendering
                }
                Text {
                    text: "裏 // URA  ·  MR-10"
                    color: "#62DDE4"
                    font.family: "Terminus"
                    font.pixelSize: 9
                    font.bold: true
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
