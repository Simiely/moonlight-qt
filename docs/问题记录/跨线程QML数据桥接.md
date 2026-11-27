---
id: pitfalls.cross-thread-qml
title: 解码线程数据无法刷新 QML 悬浮窗
summary: 单例对象必须在主线程创建，否则 QueuedConnection 投递到没有事件循环的解码线程，UI 永远停在初始值。
type: explanation
kind: pitfall
status: resolved
owner: "@simiely"
tier: normal
confidence: high
topics: [development]
severity: high
symptom: 串流中连接质量横条的延迟、码率、帧率一直是初始值；C++ 侧日志显示每秒都在推数据，QML 绑定却从不更新。
cause: ConnectionQuality 单例在解码线程首次 get() 时被创建，对象线程亲和性落在解码线程；主线程 QML 绑定拿到的是跨线程对象，QueuedConnection 把调用投递回解码线程的事件循环，而那里并不处理 UI 事件。
detect: 在推送函数里打印 QThread::currentThread() 与 object->thread()；若两者都不是主线程，或 QML 数值不动而 C++ 有日志，即可确认。
avoid: 在 main.cpp 主线程预创建单例并注册为 QML 单例；所有跨线程更新一律用 QMetaObject::invokeMethod(..., Qt::QueuedConnection)，不要依赖对象首次使用时才创建。
recover: 把单例创建移到主线程启动阶段；已发布的对象不要 deleteLater 后重建，否则 QML 仍绑定旧对象。
applies_to: [docs.modification]
source_type: code
source: app/gui/connectionquality.cpp
last_reviewed: 2026-11-27
related: [docs.modification:see-also]
---
# 解码线程数据无法刷新 QML 悬浮窗

**TL;DR**：单例在主线程预创建，跨线程更新统一走 `QueuedConnection`。

## 症状

- 横条能显示，但延迟 / 丢包 / 码率 / 帧率一直停在首帧的值
- 解码线程日志正常，每秒都有统计输出
- 重启串流偶尔恢复一次，随后又冻结

## 根因

`ConnectionQuality::get()` 是懒创建。第一次调用发生在 `publishStats()` 里，也就是解码线程，于是对象线程亲和性落在解码线程。

主线程 QML 绑定读取属性时，`QueuedConnection` 会把更新投递到**对象所属线程**的事件循环。解码线程没有常规事件循环，投递的调用不会执行，UI 自然不刷新。

## 排查

```cpp
qDebug() << QThread::currentThread() << this->thread();
```

两者不一致、或 `this->thread()` 不是主线程，即可确认。

## 正确做法

1. 在 `main.cpp` 主线程启动阶段调用 `ConnectionQuality::get()` 预创建，再 `qmlRegisterSingletonInstance`。
2. 高频更新用 `QMetaObject::invokeMethod(this, [=]{ ... }, Qt::QueuedConnection)`，不要直接改成员。
3. 会话结束时只重置数值，不销毁对象。

## 关联

- 改造说明：[Moonlight PC 改造说明](../改造说明.md)
- 同源问题：[本机无工具链时用 GitHub Actions 云端编译](GitHubActions云端编译.md)
