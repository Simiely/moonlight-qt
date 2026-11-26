#pragma once

#include <QObject>

/**
 * @brief 快捷键帮助悬浮窗的显隐状态（单例）。
 *
 * 串流中的输入处理可能发生在非主线程，这里把所有状态变更都切回主线程，
 * 再由 QML 绑定 visible 属性显示/隐藏帮助窗口。
 */
class ShortcutOverlay : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool visible MEMBER m_Visible NOTIFY visibleChanged)

public:
    static ShortcutOverlay* get(QObject* parent = nullptr);

    /// 切换显隐（供快捷键调用）
    void toggle();
    void setVisible(bool visible);

signals:
    void visibleChanged();

private:
    explicit ShortcutOverlay(QObject* parent = nullptr);
    static ShortcutOverlay* s_Instance;
    bool m_Visible = false;
};
