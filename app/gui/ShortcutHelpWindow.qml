import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import ShortcutOverlay 1.0
import ConnectionQuality 1.0

/*
 * 串流中按 Ctrl+Alt+Shift+H 唤出的快捷键帮助悬浮窗。
 * 独立置顶窗口，串流时主窗口隐藏也不受影响；可拖动，再按一次 H 关闭。
 * 串流结束时随会话自动隐藏，避免窗口残留桌面。
 */
Window {
    id: helpWindow

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    // 小屏时收窄/收矮，避免窗口超出可用区域
    width: Screen.desktopAvailableWidth > 0
           ? Math.min(460, Screen.desktopAvailableWidth - 16)
           : 460
    height: Screen.desktopAvailableHeight > 0
            ? Math.min(520, Screen.desktopAvailableHeight - 16)
            : 520

    property real savedX: -1
    property real savedY: -1

    visible: ConnectionQuality.active && ShortcutOverlay.visible

    onVisibleChanged: {
        if (visible && savedX < 0) {
            savedX = (Screen.desktopAvailableWidth - helpWindow.width) / 2
            savedY = (Screen.desktopAvailableHeight - helpWindow.height) / 2
        }
        if (visible) {
            helpWindow.x = savedX
            helpWindow.y = savedY
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#e622262d"
        border.color: "#555b66"
        border.width: 1
    }

    // 标题栏（可拖动）
    Rectangle {
        id: titleBar
        width: parent.width
        height: 40
        color: "#333943"
        radius: 10

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 10
            color: parent.color
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("串流快捷键")
            color: "#ffffff"
            font.pixelSize: 15
            font.bold: true
        }

        Label {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "Ctrl+Alt+Shift+H"
            color: "#80cbc4"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            property real lastX
            property real lastY
            onPressed: {
                lastX = mouseX
                lastY = mouseY
            }
            onPositionChanged: {
                if (pressed) {
                    // 保证窗口至少有 80px 留在屏幕内，防止拖出后找不回来
                    var nx = helpWindow.x + (mouseX - lastX)
                    var ny = helpWindow.y + (mouseY - lastY)
                    nx = Math.max(80 - helpWindow.width,
                                  Math.min(Screen.desktopAvailableWidth - 80, nx))
                    ny = Math.max(0, Math.min(Screen.desktopAvailableHeight - 30, ny))
                    helpWindow.x = nx
                    helpWindow.y = ny
                    helpWindow.savedX = nx
                    helpWindow.savedY = ny
                    lastX = mouseX
                    lastY = mouseY
                }
            }
        }
    }

    Column {
        anchors.top: titleBar.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 0
        spacing: 4

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: qsTr("键盘（串流中）")
            color: "#b0bec5"
            font.pixelSize: 12
            font.bold: true
        }

        Repeater {
            model: [
                { keys: "Ctrl+Alt+Shift+Q", desc: qsTr("断开会话") },
                { keys: "Ctrl+Alt+Shift+Z", desc: qsTr("释放 / 捕获输入") },
                { keys: "Ctrl+Alt+Shift+X", desc: qsTr("切换全屏") },
                { keys: "Ctrl+Alt+Shift+S", desc: qsTr("显示 / 隐藏性能统计") },
                { keys: "Ctrl+Alt+Shift+M", desc: qsTr("切换鼠标模式") },
                { keys: "Ctrl+Alt+Shift+C", desc: qsTr("显示鼠标指针（远程桌面）") },
                { keys: "Ctrl+Alt+Shift+D", desc: qsTr("最小化窗口") },
                { keys: "Ctrl+Alt+Shift+V", desc: qsTr("粘贴剪贴板文本到主机") },
                { keys: "Ctrl+Alt+Shift+L", desc: qsTr("切换指针区域锁定") },
                { keys: "Ctrl+Alt+Shift+E", desc: qsTr("断开并退出 Moonlight") },
                { keys: "Ctrl+Alt+Shift+K", desc: qsTr("切换系统按键捕获") },
                { keys: "Ctrl+Alt+Shift+H", desc: qsTr("显示 / 隐藏本帮助") }
            ]
            delegate: Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 10
                Label {
                    width: 150
                    text: modelData.keys
                    color: "#80cbc4"
                    font.pixelSize: 12
                }
                Label {
                    text: modelData.desc
                    color: "#e0e0e0"
                    font.pixelSize: 12
                }
            }
        }

        Rectangle {
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: "#455a64"
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 16
            text: qsTr("手柄")
            color: "#b0bec5"
            font.pixelSize: 12
            font.bold: true
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            spacing: 10
            Label {
                width: 150
                text: "Start+Select+L1+R1"
                color: "#ffb74d"
                font.pixelSize: 11
            }
            Label {
                text: qsTr("断开会话")
                color: "#e0e0e0"
                font.pixelSize: 12
            }
        }
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            spacing: 10
            Label {
                width: 150
                text: "Select+L1+R1+X"
                color: "#ffb74d"
                font.pixelSize: 11
            }
            Label {
                text: qsTr("显示 / 隐藏性能统计")
                color: "#e0e0e0"
                font.pixelSize: 12
            }
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.topMargin: 6
            text: qsTr("再次按 Ctrl+Alt+Shift+H 关闭")
            color: "#90a4ae"
            font.pixelSize: 11
            italic: true
        }
    }
}
