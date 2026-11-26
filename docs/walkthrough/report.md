---
id: walkthrough.report
title: 改造代码走查报告
summary: 9 条链路走查结果，5 条通顺、2 条链路断裂（悬浮窗随父窗口隐藏、帮助窗状态不重置），含风险评分与修复建议。
type: explanation
kind: report
status: active
owner: "@simiely"
topics: [development]
source_type: doc
source: docs/walkthrough/scenarios.md
last_reviewed: 2026-11-27
related: []
---
# 9 条链路走查报告

依据 [能力清单](capabilities.md) 与 [场景素材](scenarios.md)。走查方式：深度链逐层 Read 到文件:行号，快速链 grep 确认。

## 总体结论

**5 条通顺，2 条链路断裂（🔴 真缺陷），3 处边界缺陷（🟡），2 处极低（⚪）。** 素材与程序一致，无"写了不存在功能"的错误。

## 问题清单

| 编号 | 级别 | 问题 | 位置 | 受影响链路 | 风险分 L×I | 影响 |
|---|---|---|---|---|---|---|
| P-01 | 🔴 真缺陷 | 悬浮窗作为 ApplicationWindow 的子 Window 带 transientParent，串流时主窗口 `visible=false` 可能带着它一起隐藏 | `main.qml:516`、`main.qml:521` | S-01/S-02/S-04 | 5×5=25 | 串流时悬浮窗根本不显示，两个功能全废 |
| P-02 | 🔴 真缺陷 | `ShortcutOverlay.visible` 在会话结束从不重置，下次串流开始 `active=true` 时帮助窗自动弹出 | `session.cpp:1274`、`shortcutoverlay.cpp` | S-04 | 5×3=15 | 每次串流都莫名弹出帮助窗 |
| P-03 | 🟡 UX | 横条固定 860 宽、帮助窗固定 520 高，小屏（可用宽 <860 或高 <520）溢出，定位算出负坐标 | `ConnectionQualityWindow.qml:22`、`ShortcutHelpWindow.qml:19` | S-08 | 3×3=9 | 部分内容看不到 |
| P-04 | 🟡 UX | 拖动无边界约束，可把窗口拖到屏幕外且拖不回来 | 两个窗口的拖动 MouseArea | S-08/S-03 | 4×3=12 | 窗口"消失"，只能重开 |
| P-05 | ⚪ 极低 | 多显示器只用主屏 `Screen.desktopAvailableWidth` 定位，副屏场景位置不对 | 两个窗口 `onVisibleChanged` | S-01 | 3×2=6 | 位置偏，可手动拖 |
| P-06 | ⚪ 极低 | 帮助窗列出 X/D/K 快捷键，但非桌面环境实际不可用（`enabled` 为 false），未标注 | `ShortcutHelpWindow.qml` model | S-02 | 3×1=3 | 文案与能力不符 |
| P-07 | ⚪ 极低 | 会话结束不重置指标，下次串流首秒显示上次旧值 | `connectionquality.cpp` | S-01 | 5×1=5 | 1 秒后自动正确 |

## 覆盖矩阵结论

- 权限列、离线列空：单用户桌面应用无多角色/离线重放，已在素材写理由
- L4 状态推进（S-04）确实逼出了 P-02；L8 边界（S-08）逼出了 P-03/P-04——这两列是本次发现的主要来源
- 无盲区：两个模块的每列均有场景或有理由

## 走查验证的良好点

- **线程安全扎实**：`publishStats`/`setActive` 均为 functor 形式 `QueuedConnection`；单例在 `main.cpp` 主线程预创建（`main.cpp:973`、`main.cpp:982`），线程亲和性正确
- **除零保护完整**：丢包率、解码/渲染耗时、主机延迟的分母都判了 `> 0`
- **未侵入协议层**：改造集中在 gui/ 与三处接入点，解码、输入发送、协议包零改动
- **除零/失败分支正确**：连接失败时不置 `active`，横条不会误显示（S-09 通过）
- **快捷键复用官方机制**：`m_SpecialKeyCombos` + 扫描码回退，自动兼容非拉丁键盘
- **横条宽度自洽**：853 ≤ 860，正常屏不溢出

## 结论三问

1. **链路逻辑通顺吗？** 数据链路通（解码→模型→QML），但窗口显隐链路断两处（P-01/P-02）
2. **是补丁叠补丁吗？** 不是。状态有单点归属（`ConnectionQuality.active`），但 `ShortcutOverlay.visible` 缺一个重置点，属于状态机副作用遗漏
3. **会无法操作/出 bug 吗？** 会——P-01 会让悬浮窗在串流时完全不显示（功能全废），P-02 每次串流自动弹帮助窗

## 建议处理（按风险分排序）

| 优先级 | 问题 | 修法 |
|---|---|---|
| 必修 | P-01 | 两个悬浮窗改为**运行时 `createObject(null)` 创建**，清除 transientParent，使其不跟随主窗口隐藏 |
| 必修 | P-02 | 会话结束时同时 `ShortcutOverlay::get()->setVisible(false)` |
| 必修 | P-04 | 拖动时 clamp 坐标，保证窗口至少 80px 留在屏内 |
| 建议修 | P-03 | 窗口宽度取 `Math.min(860, 可用宽-16)`；帮助窗同理 |
| 可选 | P-05/P-06/P-07 | 多屏定位用 `Screen.width`；帮助窗标注条件性快捷键；会话结束时清零指标 |
