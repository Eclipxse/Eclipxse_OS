import QtQuick 2.15

Presentation {
    id: presentation

    Slide {
        anchors.fill: parent
        Image { anchors.fill: parent; source: "welcome.png"; fillMode: Image.PreserveAspectCrop; smooth: false }
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            height: 110; color: "#EED8EC"; border.color: "#25172C"; border.width: 2
            Text {
                anchors.centerIn: parent
                text: qsTr("REAL PIXEL WINDOWS // OMOTE + URA")
                color: "#25172C"; font.family: "Noto Sans Mono"; font.pixelSize: 21; font.bold: true
            }
        }
    }

    Slide {
        anchors.fill: parent
        color: "#130D1A"
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: qsTr("JAPANESE INPUT READY\nFCITX 5 + MOZC\n\nCTRL+SPACE TO SWITCH")
            color: "#FFF3FF"; font.family: "Noto Sans Mono"; font.pixelSize: 24; font.bold: true
        }
    }

    Slide {
        anchors.fill: parent
        color: "#D8CDD9"
        Text {
            anchors.centerIn: parent; width: parent.width * 0.8
            horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap
            text: qsTr("DEBIAN 13 FOUNDATION\nKDE PLASMA 6 // WAYLAND\n\nSYSTEM READY. SHIP THE BUILD.")
            color: "#25172C"; font.family: "Noto Sans Mono"; font.pixelSize: 24; font.bold: true
        }
    }
}
