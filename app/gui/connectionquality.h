#pragma once

#include <QObject>
#include <QString>

/**
 * @brief 连接质量悬浮窗的数据模型（单例）。
 *
 * 解码线程每秒把一份 VIDEO_STATS 快照通过 QueuedConnection 推送到主线程，
 * 主线程更新 Q_PROPERTY 后由 QML 绑定自动刷新显示。
 *
 * 这里只做读取和展示，不参与串流协议，也不改变任何既有解码/渲染逻辑。
 */
class ConnectionQuality : public QObject
{
    Q_OBJECT

    // 视频流基本信息
    Q_PROPERTY(int width MEMBER m_Width NOTIFY statsChanged)
    Q_PROPERTY(int height MEMBER m_Height NOTIFY statsChanged)
    Q_PROPERTY(double fps MEMBER m_Fps NOTIFY statsChanged)
    Q_PROPERTY(QString codec MEMBER m_Codec NOTIFY statsChanged)
    Q_PROPERTY(double bitrateMbps MEMBER m_BitrateMbps NOTIFY statsChanged)

    // 连接质量核心指标
    Q_PROPERTY(int rttMs MEMBER m_RttMs NOTIFY statsChanged)
    Q_PROPERTY(int rttVarianceMs MEMBER m_RttVarianceMs NOTIFY statsChanged)
    Q_PROPERTY(double networkLossPercent MEMBER m_NetworkLossPercent NOTIFY statsChanged)
    Q_PROPERTY(double jitterLossPercent MEMBER m_JitterLossPercent NOTIFY statsChanged)

    // 解码/渲染耗时
    Q_PROPERTY(double decodeTimeMs MEMBER m_DecodeTimeMs NOTIFY statsChanged)
    Q_PROPERTY(double renderTimeMs MEMBER m_RenderTimeMs NOTIFY statsChanged)
    Q_PROPERTY(double hostProcessingLatencyMs MEMBER m_HostProcessingLatencyMs NOTIFY statsChanged)

    // 会话是否活跃（用于自动显示/隐藏悬浮窗）
    Q_PROPERTY(bool active MEMBER m_Active NOTIFY activeChanged)

public:
    static ConnectionQuality* get(QObject* parent = nullptr);

    /**
     * @brief 由解码线程调用，提交一份统计数据快照。
     *
     * 所有参数都是值类型，内部通过 QueuedConnection 切换到主线程后再更新属性，
     * 因此调用方无需加锁。
     */
    void publishStats(int width,
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
                      double hostProcessingLatencyMs);

    /// 会话开始/结束时由 Session 调用，控制悬浮窗自动显隐
    void setActive(bool active);

signals:
    void statsChanged();
    void activeChanged();

private slots:
    // 运行在主线程
    void applyStats(int width,
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
                    double hostProcessingLatencyMs);

private:
    explicit ConnectionQuality(QObject* parent = nullptr);
    static ConnectionQuality* s_Instance;

    int m_Width = 0;
    int m_Height = 0;
    double m_Fps = 0.0;
    QString m_Codec;
    double m_BitrateMbps = 0.0;
    int m_RttMs = 0;
    int m_RttVarianceMs = 0;
    double m_NetworkLossPercent = 0.0;
    double m_JitterLossPercent = 0.0;
    double m_DecodeTimeMs = 0.0;
    double m_RenderTimeMs = 0.0;
    double m_HostProcessingLatencyMs = 0.0;
    bool m_Active = false;
};
