#include "connectionquality.h"

#include <QMetaObject>

ConnectionQuality* ConnectionQuality::s_Instance = nullptr;

ConnectionQuality* ConnectionQuality::get(QObject* parent)
{
    if (s_Instance == nullptr) {
        s_Instance = new ConnectionQuality(parent);
    }
    return s_Instance;
}

ConnectionQuality::ConnectionQuality(QObject* parent) :
    QObject(parent)
{
}

void ConnectionQuality::publishStats(int width,
                                     int height,
                                     double fps,
                                     const QString& codec,
                                     double bitrateMbps,
                                     int rttMs,
                                     int rttVarianceMs,
                                     double networkLossPercent,
                                     double jitterLossPercent,
                                     double decodeTimeMs,
                                     double renderTimeMs,
                                     double hostProcessingLatencyMs)
{
    // 解码线程 -> 主线程。捕获值类型，QueuedConnection 保证 applyStats 在主线程执行。
    QMetaObject::invokeMethod(this, [this, width, height, fps, codec, bitrateMbps,
                                     rttMs, rttVarianceMs, networkLossPercent,
                                     jitterLossPercent, decodeTimeMs, renderTimeMs,
                                     hostProcessingLatencyMs]() {
        applyStats(width, height, fps, codec, bitrateMbps,
                   rttMs, rttVarianceMs, networkLossPercent,
                   jitterLossPercent, decodeTimeMs, renderTimeMs,
                   hostProcessingLatencyMs);
    }, Qt::QueuedConnection);
}

void ConnectionQuality::applyStats(int width,
                                   int height,
                                   double fps,
                                   const QString& codec,
                                   double bitrateMbps,
                                   int rttMs,
                                   int rttVarianceMs,
                                   double networkLossPercent,
                                   double jitterLossPercent,
                                   double decodeTimeMs,
                                   double renderTimeMs,
                                   double hostProcessingLatencyMs)
{
    m_Width = width;
    m_Height = height;
    m_Fps = fps;
    m_Codec = codec;
    m_BitrateMbps = bitrateMbps;
    m_RttMs = rttMs;
    m_RttVarianceMs = rttVarianceMs;
    m_NetworkLossPercent = networkLossPercent;
    m_JitterLossPercent = jitterLossPercent;
    m_DecodeTimeMs = decodeTimeMs;
    m_RenderTimeMs = renderTimeMs;
    m_HostProcessingLatencyMs = hostProcessingLatencyMs;

    emit statsChanged();
}

void ConnectionQuality::setActive(bool active)
{
    // 可能从工作线程调用（会话清理任务），切回主线程更新
    QMetaObject::invokeMethod(this, [this, active]() {
        if (m_Active != active) {
            m_Active = active;
            if (!active) {
                // 会话结束：收起横条，并清零旧指标，避免下次串流首秒显示上次的值
                m_BarEnabled = false;
                m_Width = 0;
                m_Height = 0;
                m_Fps = 0.0;
                m_Codec.clear();
                m_BitrateMbps = 0.0;
                m_RttMs = 0;
                m_RttVarianceMs = 0;
                m_NetworkLossPercent = 0.0;
                m_JitterLossPercent = 0.0;
                m_DecodeTimeMs = 0.0;
                m_RenderTimeMs = 0.0;
                m_HostProcessingLatencyMs = 0.0;
                emit barEnabledChanged();
                emit statsChanged();
            }
            emit activeChanged();
        }
    }, Qt::QueuedConnection);
}

void ConnectionQuality::toggleBar()
{
    QMetaObject::invokeMethod(this, [this]() {
        m_BarEnabled = !m_BarEnabled;
        emit barEnabledChanged();
    }, Qt::QueuedConnection);
}

void ConnectionQuality::setBarVisible(bool visible)
{
    QMetaObject::invokeMethod(this, [this, visible]() {
        if (m_BarEnabled != visible) {
            m_BarEnabled = visible;
            emit barEnabledChanged();
        }
    }, Qt::QueuedConnection);
}

void ConnectionQuality::adjustScale(int direction)
{
    setScale(m_UiScale + (direction > 0 ? 0.1 : -0.1));
}

void ConnectionQuality::setScale(double scale)
{
    QMetaObject::invokeMethod(this, [this, scale]() {
        // 限制在 0.6x ~ 1.6x，避免调得过小看不清或过大挡住画面
        double next = qBound(0.6, scale, 1.6);
        if (!qFuzzyCompare(m_UiScale, next)) {
            m_UiScale = next;
            emit uiScaleChanged();
        }
    }, Qt::QueuedConnection);
}

void ConnectionQuality::setStreamGeometry(int x, int y, int width, int height)
{
    // 可能从串流线程调用，切回主线程更新属性
    QMetaObject::invokeMethod(this, [this, x, y, width, height]() {
        if (m_StreamX != x || m_StreamY != y ||
            m_StreamWidth != width || m_StreamHeight != height) {
            m_StreamX = x;
            m_StreamY = y;
            m_StreamWidth = width;
            m_StreamHeight = height;
            emit streamGeometryChanged();
        }
    }, Qt::QueuedConnection);
}
