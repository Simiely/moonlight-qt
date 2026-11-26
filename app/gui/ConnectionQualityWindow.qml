import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import ConnectionQuality 1.0
import StreamingPreferences 1.0

/*
 * 独立连接质量悬浮窗（横条）。
 *
 * - 半透明、无边框、始终置顶，不进入任务栏（Qt.Tool）
 * - 整条可拖动，位置可记忆
 * - 仅在串流中且设置开启时显示
 * - 数据来自 ConnectionQuality 单例（解码线程 -> 主线程安全传递）
 */
Window {
    id: qualityWindow

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"

    // 不跟随主窗口隐藏：串流时主窗口会被隐藏，但悬浮窗需独立显示
    transientParent: null

    width: 860
    height: 58

    // 位置记忆（仅记住坐标，不记住可见性）
    property real savedX: -1
    property real savedY: -1

    visible: ConnectionQuality.active && StreamingPreferences.showConnectionQualityWindow

    // 首次显示时定位到屏幕顶部居中，之后沿用用户拖动的位置
    onVisibleChanged: {
        if (visible && savedX < 0) {
            savedX = (Screen.desktopAvailableWidth - qualityWindow.width) / 2
            savedY = 8
        }
        if (visible) {
            qualityWindow.x = savedX
            qualityWindow.y = savedY
        }
    }

    // 连接质量配色：延迟/丢包低=绿，中=黄，高=红
    function rttColor(ms) {
        if (ms <= 0) return "#b0bec5"
        if (ms < 30) return "#69f0ae"
        if (ms < 60) return "#ffd740"
        return "#ff5252"
    }

    function lossColor(pct) {
        if (pct < 0.5) return "#69f0ae"
        if (pct < 2.0) return "#ffd740"
        return "#ff5252"
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#e622262d"
        border.color: "#555b66"
        border.width: 1
    }

    // 整条拖动
    MouseArea {
        id: dragArea
        anchors.fill: parent
        z: 1
        property real lastX
        property real lastY
        onPressed: {
            lastX = mouseX
            lastY = mouseY
        }
        onPositionChanged: {
            if (pressed) {
                qualityWindow.x += mouseX - lastX
                qualityWindow.y += mouseY - lastY
                qualityWindow.savedX = qualityWindow.x
                qualityWindow.savedY = qualityWindow.y
            }
        }
    }

    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.right: parent.right
        anchors.rightMargin: 34
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0
        z: 2

        // 每项：上方中文标签，下方数值
        Item {
            width: 66
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 2
                Label {
                    text: qsTr("连接质量")
                    color: "#ffffff"
                    font.pixelSize: 12
                    font.bold: true
                }
                Label {
                    text: qsTr("实时")
                    color: "#80cbc4"
                    font.pixelSize: 10
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 96
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("分辨率"); color: "#90a4ae"; font.pixelSize: 10 }
                Label {
                    text: "%1×%2".arg(ConnectionQuality.width).arg(ConnectionQuality.height)
                    color: "#e0e0e0"; font.pixelSize: 13
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 112
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("编码"); color: "#90a4ae"; font.pixelSize: 10 }
                Label { text: ConnectionQuality.codec; color: "#80cbc4"; font.pixelSize: 12 }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 62
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("帧率"); color: "#90a4ae"; font.pixelSize: 10 }
                Label {
                    text: "%1 FPS".arg(ConnectionQuality.fps.toFixed(0))
                    color: "#e0e0e0"; font.pixelSize: 13
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 88
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("码率"); color: "#90a4ae"; font.pixelSize: 10 }
                Label {
                    text: "%1 Mbps".arg(ConnectionQuality.bitrateMbps.toFixed(1))
                    color: "#ffffff"; font.pixelSize: 13; font.bold: true
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 96
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("延迟"); color: "#90a4ae"; font.pixelSize: 10 }
                Row {
                    spacing: 5
                    Label {
                        text: "%1 ms".arg(ConnectionQuality.rttMs)
                        color: rttColor(ConnectionQuality.rttMs)
                        font.pixelSize: 14; font.bold: true
                    }
                    Label {
                        text: ConnectionQuality.rttVarianceMs > 0
                              ? ("±%1".arg(ConnectionQuality.rttVarianceMs)) : ""
                        color: "#90a4ae"; font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 128
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("丢包 / 抖动丢包"); color: "#90a4ae"; font.pixelSize: 10 }
                Row {
                    spacing: 5
                    Label {
                        text: "%1%".arg(ConnectionQuality.networkLossPercent.toFixed(1))
                        color: lossColor(ConnectionQuality.networkLossPercent)
                        font.pixelSize: 13; font.bold: true
                    }
                    Label { text: "/"; color: "#607d8b"; font.pixelSize: 12 }
                    Label {
                        text: "%1%".arg(ConnectionQuality.jitterLossPercent.toFixed(1))
                        color: lossColor(ConnectionQuality.jitterLossPercent)
                        font.pixelSize: 13; font.bold: true
                    }
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 70
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("解码"); color: "#90a4ae"; font.pixelSize: 10 }
                Label {
                    text: "%1 ms".arg(ConnectionQuality.decodeTimeMs.toFixed(1))
                    color: "#e0e0e0"; font.pixelSize: 13
                }
            }
        }

        Rectangle { width: 1; height: 30; color: "#455a64"; anchors.verticalCenter: parent.verticalCenter }

        Item {
            width: 78
            height: 44
            Column {
                anchors.centerIn: parent
                spacing: 1
                Label { text: qsTr("主机处理"); color: "#90a4ae"; font.pixelSize: 10 }
                Label {
                    text: ConnectionQuality.hostProcessingLatencyMs > 0
                          ? ("%1 ms".arg(ConnectionQuality.hostProcessingLatencyMs.toFixed(1)))
                          : "—"
                    color: "#e0e0e0"; font.pixelSize: 13
                }
            }
        }
    }

    // 临时隐藏按钮（最上层，可点击）
    Label {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        text: "×"
        color: "#b0bec5"
        font.pixelSize: 20
        z: 3

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            onClicked: StreamingPreferences.showConnectionQualityWindow = false
        }
    }
}
