import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

import ConnectionQuality 1.0
import StreamingPreferences 1.0

/*
 * 连接质量横条（极简版）。
 *
 * - 纯黑半透明底 + 单行四项：延迟 / 丢包 / 码率 / 帧率
 * - 位置：串流画面顶部居中，跟随串流窗口所在显示器
 * - Ctrl+Alt+Shift+B 显隐；[ / ] 缩放；- / = 调背景透明度
 */
Window {
    id: qualityWindow

    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.WindowDoesNotAcceptFocus
    color: "transparent"

    readonly property real baseHeight: 26
    readonly property real screenAvailWidth: ConnectionQuality.streamWidth > 0
                                             ? ConnectionQuality.streamWidth
                                             : Screen.desktopAvailableWidth

    // 宽度由内容决定，不固定 860，避免留白
    readonly property real baseWidth: {
        var w = contentRow.implicitWidth + 22
        return screenAvailWidth > 40 ? Math.min(w, screenAvailWidth - 16) : w
    }

    // 缩放上限按可用宽度收敛，避免小屏放大后溢出
    readonly property real uiScale: {
        var maxScale = (screenAvailWidth > 0 && baseWidth > 0) ? (screenAvailWidth / baseWidth) : 1.6
        return Math.max(0.6, Math.min(ConnectionQuality.uiScale, Math.min(1.6, maxScale)))
    }

    width: baseWidth * uiScale
    height: baseHeight * uiScale

    x: ConnectionQuality.streamX + Math.max(0, (screenAvailWidth - width) / 2)
    y: ConnectionQuality.streamY + 8

    visible: ConnectionQuality.active && ConnectionQuality.barEnabled

    Connections {
        target: ConnectionQuality
        function onActiveChanged() {
            if (ConnectionQuality.active) {
                ConnectionQuality.setBarVisible(StreamingPreferences.showConnectionQualityWindow)
            }
        }
    }

    // 延迟/丢包配色：低=绿，中=黄，高=红
    function rttColor(ms) {
        if (ms <= 0) return "#9e9e9e"
        if (ms < 30) return "#66d98a"
        if (ms < 60) return "#e6c34d"
        return "#e05a5a"
    }

    function lossColor(pct) {
        if (pct < 0.5) return "#66d98a"
        if (pct < 2.0) return "#e6c34d"
        return "#e05a5a"
    }

    Item {
        id: content
        width: qualityWindow.baseWidth
        height: qualityWindow.baseHeight
        scale: qualityWindow.uiScale
        transformOrigin: Item.TopLeft

        // 纯黑底，透明度由快捷键调节
        Rectangle {
            anchors.fill: parent
            radius: 5
            color: "#000000"
            opacity: ConnectionQuality.barOpacity
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 12

            // 文字亮度随背景透明度提升，保证低透明度时仍可读
            readonly property real textOpacity: Math.max(0.65, ConnectionQuality.barOpacity)

            Label {
                text: ConnectionQuality.rttMs + "ms"
                color: rttColor(ConnectionQuality.rttMs)
                opacity: contentRow.textOpacity
                font.pixelSize: 12
                font.bold: true
            }

            Label {
                text: ConnectionQuality.networkLossPercent.toFixed(1) + "%"
                color: lossColor(ConnectionQuality.networkLossPercent)
                opacity: contentRow.textOpacity
                font.pixelSize: 12
                font.bold: true
            }

            Label {
                text: ConnectionQuality.bitrateMbps.toFixed(1) + "M"
                color: "#dcdcdc"
                opacity: contentRow.textOpacity
                font.pixelSize: 12
            }

            Label {
                text: ConnectionQuality.fps.toFixed(0) + "fps"
                color: "#dcdcdc"
                opacity: contentRow.textOpacity
                font.pixelSize: 12
            }
        }
    }
}
