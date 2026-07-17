import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#130D1A"

    property color ink: "#25172C"
    property color panel: "#D8CDD9"
    property color panelHi: "#FFF3FF"
    property color panelShadow: "#56445E"
    property color active: "#C82E91"
    property color cyan: "#62DDE4"
    property string statusMessage: "READY // LOGIN REQUIRED"

    function login() {
        statusMessage = "AUTHENTICATING..."
        sddm.login(userName.text, password.text, sessionModel.lastIndex)
    }

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        smooth: false
    }

    Rectangle {
        id: cardShadow
        width: Math.min(760, root.width - 48)
        height: 480
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 8
        anchors.verticalCenterOffset: 8
        color: "#09050D"
    }

    Rectangle {
        id: card
        width: cardShadow.width
        height: cardShadow.height
        anchors.centerIn: parent
        color: panel
        border.color: ink
        border.width: 2

        Rectangle { x: 3; y: 3; width: parent.width - 6; height: 2; color: panelHi }
        Rectangle { x: 3; y: 3; width: 2; height: parent.height - 6; color: panelHi }
        Rectangle { x: 3; y: parent.height - 5; width: parent.width - 6; height: 2; color: panelShadow }
        Rectangle { x: parent.width - 5; y: 3; width: 2; height: parent.height - 6; color: panelShadow }

        Rectangle {
            id: titlebar
            x: 7; y: 7; width: parent.width - 14; height: 52
            color: active
            Text {
                anchors.left: parent.left; anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: "♡  MARISHOKU/OS // SIGN IN"
                color: "#FFF3FF"
                font.family: "Terminus"; font.pixelSize: 22; font.bold: true
            }
            Rectangle {
                width: 36; height: 36; anchors.right: parent.right; anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: panel; border.color: ink; border.width: 2
                Text { anchors.centerIn: parent; text: "×"; color: ink; font.pixelSize: 23; font.bold: true }
            }
        }

        Text {
            x: 64; y: 91
            text: "魔理蝕 // ECLIPXSE SYSTEMS // MR-10"
            color: "#7141C1"
            font.family: "Terminus"; font.pixelSize: 20; font.bold: true
        }

        Text { x: 64; y: 148; text: "USER"; color: ink; font.family: "Terminus"; font.pixelSize: 19; font.bold: true }
        Rectangle {
            x: 210; y: 132; width: 470; height: 54
            color: "#FFF9FF"; border.color: panelShadow; border.width: 2
            TextInput {
                id: userName
                anchors.fill: parent; anchors.margins: 12
                text: userModel.lastUser
                color: ink; selectionColor: active
                font.family: "Terminus"; font.pixelSize: 20
                Keys.onReturnPressed: password.forceActiveFocus()
            }
        }

        Text { x: 64; y: 221; text: "PASSWORD"; color: ink; font.family: "Terminus"; font.pixelSize: 19; font.bold: true }
        Rectangle {
            x: 210; y: 205; width: 470; height: 54
            color: "#FFF9FF"; border.color: password.activeFocus ? active : panelShadow; border.width: 2
            TextInput {
                id: password
                anchors.fill: parent; anchors.margins: 12
                echoMode: TextInput.Password
                color: ink; selectionColor: active
                font.family: "Terminus"; font.pixelSize: 20
                focus: true
                Keys.onReturnPressed: root.login()
            }
        }

        Rectangle {
            id: loginButton
            x: 210; y: 286; width: 240; height: 58
            color: loginMouse.pressed ? "#8F276F" : active
            border.color: ink; border.width: 2
            Rectangle { x: 3; y: 3; width: parent.width - 6; height: 2; color: "#FF8BC8" }
            Text { anchors.centerIn: parent; text: "ENTER // ログイン"; color: "#FFF3FF"; font.family: "Terminus"; font.pixelSize: 20; font.bold: true }
            MouseArea { id: loginMouse; anchors.fill: parent; onClicked: root.login() }
        }

        Text {
            x: 64; y: 375; width: parent.width - 128
            text: statusMessage
            color: statusMessage.indexOf("FAILED") >= 0 ? "#B00050" : "#7141C1"
            font.family: "Terminus"; font.pixelSize: 17; font.bold: true
        }

        Row {
            x: 64; y: 416; spacing: 24
            Text { text: "[RESTART]"; color: ink; font.family: "Terminus"; font.pixelSize: 17; MouseArea { anchors.fill: parent; onClicked: sddm.reboot() } }
            Text { text: "[POWER OFF]"; color: ink; font.family: "Terminus"; font.pixelSize: 17; MouseArea { anchors.fill: parent; onClicked: sddm.powerOff() } }
            Text { text: Qt.formatDateTime(new Date(), "HH:mm  ddd dd MMM"); color: ink; font.family: "Terminus"; font.pixelSize: 17 }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            statusMessage = "AUTH FAILED // CHECK PASSWORD"
            password.selectAll()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() { statusMessage = "WELCOME BACK // LINK READY" }
    }
}
