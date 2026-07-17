import QtQuick 2.15

Rectangle {
    id: root
    color: "#130D1A"
    property int stage

    Image {
        anchors.fill: parent
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
        smooth: false
    }

    Rectangle {
        width: Math.min(620, parent.width - 48)
        height: 108
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 76
        color: "#D8CDD9"
        border.color: "#25172C"
        border.width: 2

        Text {
            anchors.left: parent.left; anchors.leftMargin: 22
            anchors.top: parent.top; anchors.topMargin: 17
            text: "STARTING DESKTOP // STAGE " + root.stage + "/5"
            color: "#25172C"
            font.family: "Noto Sans Mono"; font.pixelSize: 17; font.bold: true
        }
        Row {
            anchors.left: parent.left; anchors.leftMargin: 22
            anchors.bottom: parent.bottom; anchors.bottomMargin: 19
            spacing: 6
            Repeater {
                model: 5
                Rectangle {
                    width: 105; height: 22
                    color: index < root.stage ? "#C82E91" : "#806E86"
                    border.color: "#25172C"; border.width: 1
                }
            }
        }
    }
}
