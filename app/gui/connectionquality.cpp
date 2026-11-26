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
            emit activeChanged();
        }
    }, Qt::QueuedConnection);
}
