---
id: walkthrough.capabilities
title: 改造能力清单
summary: 连接质量横条与快捷键帮助窗的真实能力盘点（v1.2 口径），含入口、边界与硬限制，供场景走查引用。
type: reference
kind: report
status: active
owner: "@simiely"
topics: [development]
source_type: doc
source: docs/改造说明.md
last_reviewed: 2026-11-27
related: []
---
# 改造能力清单

盘点依据：v1.2.0 代码实读，不是设计意图。每条能力带 C-ID，后续素材与报告统一引用。

## 连接质量横条

| C-ID | 能力 | 入口 | 边界/限制 | 证据 |
|---|---|---|---|---|
| C-01 | 串流中显示横条 | 设置开关 `showConnectionQualityWindow`（默认开）+ 会话 active | 非串流不显示 | `ConnectionQualityWindow.qml:44` |
| C-02 | 每秒刷新指标 | 解码线程统计窗口翻转 | 上游固定 1s 频率，非逐帧 | `ffmpeg.cpp` 每秒翻转段 |
| C-03 | 贴串流画面顶部居中 | `streamX/Y/Width/Height` 四个属性 | 全屏独占时可能被游戏盖住 | `connectionquality.h` stream 属性 |
| C-04 | 整体缩放 0.6x~1.6x | `Ctrl+Alt+Shift+[` / `]` | 上限还受可用屏宽约束 | `ConnectionQualityWindow.qml:33` |
| C-05 | 背景透明度 0.15~1.0 | `Ctrl+Alt+Shift+-` / `=` | 只影响底色，不影响文字 | `ConnectionQualityWindow.qml:81` |
| C-06 | 显隐横条 | `Ctrl+Alt+Shift+B` | 不受设置开关限制，随时可用 | `keyboard.cpp` 分发 |
| C-14 | 单行四项指标 | 固定布局 | 延迟 / 丢包 / 码率 / 帧率，不提供自定义排序 | `ConnectionQualityWindow.qml` 内容行 |

## 快捷键帮助窗

| C-ID | 能力 | 入口 | 边界/限制 | 证据 |
|---|---|---|---|---|
| C-07 | H 键唤出/关闭 | `KeyComboToggleShortcuts` | 仅串流中生效 | `input.h` 枚举、`keyboard.cpp` 分发 |
| C-08 | 列出 17 条键盘快捷键 | 静态 JS 数组 | X/D/K 在非桌面环境实际不可用 | `ShortcutHelpWindow.qml` model |
| C-09 | 列出 2 条手柄组合键 | 静态文本 | 与 gamepad.cpp 硬编码一致 | `gamepad.cpp:389,406` |
| C-10 | 串流结束自动隐藏 | 会话清理 `ShortcutOverlay::setVisible(false)` | 异常崩溃不保证执行 | `session.cpp:1277` |
| C-15 | 不抢键盘焦点 | `Qt.WindowDoesNotAcceptFocus` | 只收鼠标，不能拖动 | `ShortcutHelpWindow.qml:17` |

## 会话与设置

| C-ID | 能力 | 入口 | 边界/限制 | 证据 |
|---|---|---|---|---|
| C-11 | 会话开始置 active | `startConnectionAsync` 成功后 | 连接失败不置 true | `session.cpp:1737` |
| C-12 | 会话结束清 active | 清理任务 `run()` 开头 | 异常崩溃不保证执行 | `session.cpp:1274` |
| C-13 | 设置持久化 | QSettings 键 `showconnquality` | 默认 true | `streamingpreferences.cpp:149` |

## 能力边界（明确不做）

- 双向剪贴板：标准 Sunshine 无协议支持
- 横条自定义指标/排序：固定四项核心指标
- 横条/帮助窗拖动：串流中鼠标被游戏锁定，拖动无法操作
- 帮助窗内容动态生成：静态表，需随上游快捷键变更手工同步
