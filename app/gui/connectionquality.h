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

    // 串流窗口在桌面上的真实矩形（全局坐标）：
    // 供 QML 把悬浮窗精确贴到串流画面上，避免多屏时用虚拟桌面宽度算错位置
    Q_PROPERTY(int streamX MEMBER m_StreamX NOTIFY streamGeometryChanged)
    Q_PROPERTY(int streamY MEMBER m_StreamY NOTIFY streamGeometryChanged)
    Q_PROPERTY(int streamWidth MEMBER m_StreamWidth NOTIFY streamGeometryChanged)
    Q_PROPERTY(int streamHeight MEMBER m_StreamHeight NOTIFY streamGeometryChanged)

    // 横条整体缩放比例（串流中鼠标被锁定，主要靠快捷键调节）
    Q_PROPERTY(double uiScale MEMBER m_UiScale NOTIFY uiScaleChanged)

    // 串流中临时显隐（B 键切换，不改持久设置；会话结束时复位）
    Q_PROPERTY(bool barEnabled MEMBER m_BarEnabled NOTIFY barEnabledChanged)

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

    /// 由 Session 在串流窗口就绪后调用，记录窗口的真实桌面矩形
    void setStreamGeometry(int x, int y, int width, int height);

    /// 调节横条整体大小（direction > 0 放大，< 0 缩小），供快捷键与鼠标手柄调用
    Q_INVOKABLE void adjustScale(int direction);
    /// 直接设置缩放比例（鼠标拖动手柄时用）
    Q_INVOKABLE void setScale(double scale);
    /// 串流中临时显隐横条（B 键调用）
    Q_INVOKABLE void toggleBar();
    /// 明确设置横条显隐（QML 在串流开始时按设置初始化用）
    Q_INVOKABLE void setBarVisible(bool visible);

signals:
    void statsChanged();
    void activeChanged();
    void streamGeometryChanged();
    void uiScaleChanged();
    void barEnabledChanged();

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

    int m_StreamX = 0;
    int m_StreamY = 0;
    int m_StreamWidth = 0;
    int m_StreamHeight = 0;

    double m_UiScale = 1.0;
    // 初始不可见；串流开始时由 QML 按持久设置初始化，之后可用 B 键随时呼出/收起
    bool m_BarEnabled = false;
};
