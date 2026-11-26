import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import ConnectionQuality 1.0
import StreamingPreferences 1.0

/*
 * 连接质量横条（覆盖在串流画面顶部）。
 *
 * - 半透明、无边框、始终置顶，不进入任务栏（Qt.Tool）
 * - 位置：串流画面顶部居中，跟随串流窗口所在显示器（双屏不会跑偏）
 * - 大小：Ctrl+Alt+Shift+[ 缩小 / ] 放大，或拖右下角手柄
 * - 仅在串流中且设置开启时显示
 */
Window {
    id: qualityWindow

    // WindowDoesNotAcceptFocus：不抢键盘焦点，避免串流中点击后游戏按键失灵
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.WindowDoesNotAcceptFocus
    color: "transparent"

    // 基准宽度：串流画面宽 - 16px，非串流时回退到当前屏幕
    property real baseWidth: {
        var avail = ConnectionQuality.streamWidth > 0
                    ? ConnectionQuality.streamWidth
                    : Screen.desktopAvailableWidth
        return avail > 16 ? Math.min(860, avail - 16) : 860
    }

    // 基准高度
    readonly property real baseHeight: 58

    // 整体缩放：窗口尺寸随缩放变化，内部按基准尺寸布局后统一缩放。
    // 上限按可用宽度动态收敛，避免小屏放大后超出屏幕被裁切。
    readonly property real uiScale: {
        var avail = ConnectionQuality.streamWidth > 0
                    ? ConnectionQuality.streamWidth
                    : Screen.desktopAvailableWidth
        var maxScale = (avail > 0 && baseWidth > 0) ? (avail / baseWidth) : 1.6
        return Math.max(0.6, Math.min(ConnectionQuality.uiScale, Math.min(1.6, maxScale)))
    }
    width: baseWidth * uiScale
    height: baseHeight * uiScale

    // 贴在串流画面顶部居中。
    // 用 ConnectionQuality.streamX/streamY（串流窗口的真实桌面矩形）定位，
    // 而不是 Screen.desktopAvailableWidth（那是虚拟桌面总宽，双屏会算到屏幕外）。
    x: {
        var avail = ConnectionQuality.streamWidth > 0
                    ? ConnectionQuality.streamWidth
                    : Screen.desktopAvailableWidth
        return ConnectionQuality.streamX + Math.max(0, (avail - width) / 2)
    }
    y: ConnectionQuality.streamY + 8

    // 设置只决定串流开始时的初始状态；串流中可用 Ctrl+Alt+Shift+B 随时呼出/收起
    visible: ConnectionQuality.active && ConnectionQuality.barEnabled

    Connections {
        target: ConnectionQuality
        function onActiveChanged() {
            if (ConnectionQuality.active) {
                ConnectionQuality.setBarVisible(StreamingPreferences.showConnectionQualityWindow)
            }
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

    // 内容以基准尺寸布局，再整体缩放，保证放大时比例一致
    Item {
        id: content
        width: qualityWindow.baseWidth
        height: qualityWindow.baseHeight
        scale: qualityWindow.uiScale
        transformOrigin: Item.TopLeft

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#e622262d"
            border.color: "#555b66"
            border.width: 1
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

        // 右下角缩放手柄：拖动可整体放大/缩小（串流中鼠标被锁定时请用快捷键）
        Rectangle {
            id: scaleHandle
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 18
            height: 18
            color: "transparent"
            z: 4

            // 视觉提示：右下角两道斜线
            Rectangle {
                width: 9; height: 1; color: "#80cbc4"; opacity: 0.7
                rotation: -45
                x: 5; y: 12
            }
            Rectangle {
                width: 5; height: 1; color: "#80cbc4"; opacity: 0.5
                rotation: -45
                x: 9; y: 14
            }

            MouseArea {
                anchors.fill: parent
                property real startGlobalX: 0
                property real startScale: 1.0
                onPressed: {
                    startGlobalX = mapToGlobal(mouseX, 0).x
                    startScale = ConnectionQuality.uiScale
                }
                onPositionChanged: {
                    if (pressed) {
                        var dx = mapToGlobal(mouseX, 0).x - startGlobalX
                        ConnectionQuality.setScale(startScale + dx / 600.0)
                    }
                }
            }
        }
    }
}
