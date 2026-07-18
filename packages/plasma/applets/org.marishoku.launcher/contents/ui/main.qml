// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls as Controls
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    property color ink: "#15101F"
    property color shadow: "#56445E"
    property color face: "#D8CDD9"
    property color paper: "#FFF3FF"
    property color magenta: "#C82E91"
    property color pink: "#D63BAC"
    property color cyan: "#62DDE4"

    property var commands: [
        { code: "SYS", title: "CONTROL CENTER", detail: "SYSTEM / PROFILE", url: "applications:org.marishoku.center.desktop" },
        { code: "DIR", title: "FILES", detail: "HOME DIRECTORY", url: "applications:org.marishoku.dolphin.desktop" },
        { code: ">_", title: "TERMINAL", detail: "KONSOLE LINK", url: "applications:org.marishoku.konsole.desktop" },
        { code: "NET", title: "WEB", detail: "FIREFOX ESR", url: "applications:firefox-esr.desktop" },
        { code: "PKG", title: "SOFTWARE", detail: "DISCOVER", url: "applications:org.kde.discover.desktop" },
        { code: "あ", title: "JAPANESE", detail: "MOZC / FCITX 5", url: "applications:org.marishoku.japanese.desktop" }
    ]

    compactRepresentation: Item {
        implicitWidth: 48
        implicitHeight: 48

        Rectangle {
            anchors.fill: parent
            color: launchMouse.pressed ? root.shadow : launchMouse.containsMouse ? "#E8DCE9" : root.face
            border.color: root.ink
            border.width: 2

            Rectangle { x: 3; y: 3; width: parent.width - 6; height: 2; color: launchMouse.pressed ? root.shadow : root.paper }
            Rectangle { x: 3; y: 3; width: 2; height: parent.height - 6; color: launchMouse.pressed ? root.shadow : root.paper }
            Rectangle { x: 3; y: parent.height - 5; width: parent.width - 6; height: 2; color: launchMouse.pressed ? root.paper : root.shadow }
            Rectangle { x: parent.width - 5; y: 3; width: 2; height: parent.height - 6; color: launchMouse.pressed ? root.paper : root.shadow }

            Image {
                anchors.centerIn: parent
                width: 32
                height: 32
                source: Qt.resolvedUrl("../images/heart.svg")
                smooth: false
                mipmap: false
            }
        }

        Controls.ToolTip.visible: launchMouse.containsMouse
        Controls.ToolTip.text: "MARISHOKU/OS // START"
        Controls.ToolTip.delay: 300

        MouseArea {
            id: launchMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Rectangle {
        implicitWidth: 548
        implicitHeight: 458
        color: root.face
        border.color: root.ink
        border.width: 3

        Rectangle {
            id: titleBar
            x: 7
            y: 7
            width: parent.width - 14
            height: 38
            color: root.magenta
            border.color: root.ink
            border.width: 2

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: "♥  MARISHOKU/OS // COMMAND"
                color: root.paper
                font.family: "Terminus"
                font.pixelSize: 15
                font.bold: true
                renderType: Text.NativeRendering
            }

            Rectangle {
                width: 27
                height: 27
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                color: closeMouse.pressed ? root.shadow : root.face
                border.color: root.ink
                border.width: 2
                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: root.ink
                    font.family: "Terminus"
                    font.pixelSize: 19
                    font.bold: true
                }
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    onClicked: root.expanded = false
                }
            }
        }

        Row {
            id: body
            anchors.top: titleBar.bottom
            anchors.topMargin: 8
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.bottom: footer.top
            anchors.bottomMargin: 8
            spacing: 8

            Rectangle {
                width: 174
                height: parent.height
                color: "#24162B"
                border.color: root.ink
                border.width: 2

                Column {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 9

                    Image {
                        width: 56
                        height: 56
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: Qt.resolvedUrl("../images/heart.svg")
                        smooth: false
                        mipmap: false
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "魔理蝕"
                        color: root.paper
                        font.family: "Noto Sans CJK JP"
                        font.pixelSize: 19
                        font.bold: true
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "MR-10 / URA"
                        color: root.cyan
                        font.family: "Terminus"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Rectangle { width: parent.width; height: 2; color: root.shadow }
                    Text {
                        width: parent.width
                        text: "NO ONE IS COMING.\nPUSH ANYWAY."
                        color: "#FF91D0"
                        font.family: "Terminus"
                        font.pixelSize: 13
                        font.bold: true
                        lineHeight: 1.15
                    }
                    Text {
                        width: parent.width
                        text: "SYSTEM READY\nJP INPUT READY\nECLIPXSE LINK OK"
                        color: root.paper
                        font.family: "Terminus"
                        font.pixelSize: 10
                        lineHeight: 1.35
                    }
                }
            }

            Grid {
                width: parent.width - 182
                columns: 2
                spacing: 7

                Repeater {
                    model: root.commands
                    delegate: Rectangle {
                        id: commandButton
                        required property var modelData
                        width: 174
                        height: 102
                        color: commandMouse.pressed ? "#B7A7BC" : commandMouse.containsMouse ? "#F3EAF4" : root.face
                        border.color: root.ink
                        border.width: 2

                        Rectangle { x: 3; y: 3; width: parent.width - 6; height: 2; color: commandMouse.pressed ? root.shadow : root.paper }
                        Rectangle { x: 3; y: 3; width: 2; height: parent.height - 6; color: commandMouse.pressed ? root.shadow : root.paper }
                        Rectangle { x: 3; y: parent.height - 5; width: parent.width - 6; height: 2; color: commandMouse.pressed ? root.paper : root.shadow }
                        Rectangle { x: parent.width - 5; y: 3; width: 2; height: parent.height - 6; color: commandMouse.pressed ? root.paper : root.shadow }

                        Rectangle {
                            x: 12
                            y: 12
                            width: 48
                            height: 48
                            color: root.ink
                            border.color: root.pink
                            border.width: 2
                            Text {
                                anchors.centerIn: parent
                                text: modelData.code
                                color: root.cyan
                                font.family: modelData.code === "あ" ? "Noto Sans CJK JP" : "Terminus"
                                font.pixelSize: modelData.code === "あ" ? 22 : 13
                                font.bold: true
                            }
                        }
                        Text {
                            x: 70
                            y: 16
                            width: parent.width - 80
                            text: modelData.title
                            color: root.ink
                            font.family: "Terminus"
                            font.pixelSize: 12
                            font.bold: true
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            x: 12
                            y: 72
                            width: parent.width - 24
                            text: modelData.detail
                            color: root.shadow
                            font.family: "Terminus"
                            font.pixelSize: 9
                            font.bold: true
                        }
                        Rectangle {
                            visible: commandMouse.containsMouse
                            x: 12
                            y: parent.height - 9
                            width: parent.width - 24
                            height: 2
                            color: root.pink
                        }
                        MouseArea {
                            id: commandMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.expanded = false
                                Qt.openUrlExternally(modelData.url)
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: footer
            x: 8
            width: parent.width - 16
            height: 42
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            color: "#B7A7BC"
            border.color: root.ink
            border.width: 2

            Row {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 6

                Repeater {
                    model: [
                        { label: "OMOTE / 表", url: "applications:org.marishoku.profile-omote.desktop" },
                        { label: "URA / 裏", url: "applications:org.marishoku.profile-ura.desktop" },
                        { label: "SESSION...", url: "applications:org.marishoku.session.desktop" }
                    ]
                    delegate: Rectangle {
                        required property var modelData
                        width: modelData.label === "SESSION..." ? 130 : 118
                        height: 30
                        color: footerMouse.pressed ? root.shadow : root.face
                        border.color: root.ink
                        border.width: 2
                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: root.ink
                            font.family: modelData.label.indexOf("表") >= 0 || modelData.label.indexOf("裏") >= 0 ? "Noto Sans CJK JP" : "Terminus"
                            font.pixelSize: 10
                            font.bold: true
                        }
                        MouseArea {
                            id: footerMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.expanded = false
                                Qt.openUrlExternally(modelData.url)
                            }
                        }
                    }
                }

                Item { width: 1; height: 1 }
                Text {
                    width: 120
                    height: 30
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    text: "V1.3 // READY"
                    color: root.shadow
                    font.family: "Terminus"
                    font.pixelSize: 9
                    font.bold: true
                }
            }
        }
    }
}
