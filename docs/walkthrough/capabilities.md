---
id: walkthrough.capabilities
title: 改造能力清单
summary: 连接质量横条与快捷键帮助窗的真实能力盘点，含入口、边界与硬限制，供场景走查引用。
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

盘点依据：代码实读，不是设计意图。每条能力带 C-ID，后续素材与报告统一引用。

## 连接质量横条

| C-ID | 能力 | 入口 | 边界/限制 | 证据 |
|---|---|---|---|---|
| C-01 | 串流中显示横条 | 设置开关 `showConnectionQualityWindow` + 会话 active | 默认关闭；非串流不显示 | `ConnectionQualityWindow.qml:29` |
| C-02 | 每秒刷新指标 | 解码线程统计窗口翻转 | 上游固定 1s 频率，非逐帧 | `ffmpeg.cpp` 每秒翻转段 |
| C-03 | 拖动横条 | 全窗 MouseArea | 串流鼠标锁定时拖不动 | `ConnectionQualityWindow.qml:66` |
| C-04 | 关闭横条 | 右侧 × 按钮 → 关设置开关 | 串流鼠标锁定时点不到 | `ConnectionQualityWindow.qml` × Label |
| C-05 | 位置记忆 | `savedX/savedY` | 仅窗口存活期内，重启丢失 | `ConnectionQualityWindow.qml:26` |

## 快捷键帮助窗

| C-ID | 能力 | 入口 | 边界/限制 | 证据 |
|---|---|---|---|---|
| C-06 | H 键唤出/关闭 | `KeyComboToggleShortcuts` | 仅串流中生效 | `input.h` 枚举、`keyboard.cpp` 分发 |
| C-07 | 列出 12 条键盘快捷键 | 静态 JS 数组 | X/D/K 在非桌面环境实际不可用 | `ShortcutHelpWindow.qml` model |
| C-08 | 列出 2 条手柄组合键 | 静态文本 | 与 gamepad.cpp 硬编码一致 | `gamepad.cpp:389,406` |
| C-09 | 拖动帮助窗 | 标题栏 MouseArea | 同 C-03 | `ShortcutHelpWindow.qml` titleBar |
| C-10 | 串流结束自动隐藏 | `visible` 绑定 `ConnectionQuality.active` | 本次走查前缺失，已补 | `ShortcutHelpWindow.qml:24` |

## 会话与设置

| C-ID | 能力 | 入口 | 边界/限制 | 证据 |
|---|---|---|---|---|
| C-11 | 会话开始置 active | `startConnectionAsync` 成功后 | 连接失败不置 true | `session.cpp:1737` |
| C-12 | 会话结束清 active | 清理任务 `run()` 开头 | 异常崩溃不保证执行 | `session.cpp:1274` |
| C-13 | 设置持久化 | QSettings 键 `showconnquality` | 默认 false | `streamingpreferences.cpp` |

## 能力边界（明确不做）

- 双向剪贴板：标准 Sunshine 无协议支持
- 横条自定义指标/排序：固定 9 项
- 帮助窗内容动态生成：静态表，需随上游快捷键变更手工同步
