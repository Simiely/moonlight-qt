#include "shortcutoverlay.h"

#include <QMetaObject>

ShortcutOverlay* ShortcutOverlay::s_Instance = nullptr;

ShortcutOverlay* ShortcutOverlay::get(QObject* parent)
{
    if (s_Instance == nullptr) {
        s_Instance = new ShortcutOverlay(parent);
    }
    return s_Instance;
}

ShortcutOverlay::ShortcutOverlay(QObject* parent) :
    QObject(parent)
{
}

void ShortcutOverlay::toggle()
{
    QMetaObject::invokeMethod(this, [this]() {
        m_Visible = !m_Visible;
        emit visibleChanged();
    }, Qt::QueuedConnection);
}

void ShortcutOverlay::setVisible(bool visible)
{
    // 可能从输入线程调用，切回主线程更新
    QMetaObject::invokeMethod(this, [this, visible]() {
        if (m_Visible != visible) {
            m_Visible = visible;
            emit visibleChanged();
        }
    }, Qt::QueuedConnection);
}
