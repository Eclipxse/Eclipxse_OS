// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    compactRepresentation: fullRepresentation

    fullRepresentation: Item {
        implicitWidth: 156
        implicitHeight: 52

        Text {
            anchors.centerIn: parent
            text: "MARISHOKU/OS"
            color: "#fff3ff"
            font.family: "Noto Sans Mono"
            font.pixelSize: 15
            font.bold: true
            renderType: Text.NativeRendering
        }
    }
}
