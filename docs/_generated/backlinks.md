---
id: docs.generated.backlinks
title: 反向链接
summary: 从 related 与 pitfall 的 applies_to 自动派生的反向链接；勿手改。
type: reference
kind: index
status: active
owner: "@platform"
source_type: doc
source: schema/taxonomy.json
last_reviewed: 2026-11-11
related: []
---

# 反向链接

> 生成文件，勿手改。方向性关系只存一侧，本页是派生结果；对称关系按规范边去重。
> `applies_to` 是 pitfall 的专用字段，可指向页面 id 或技能 name；技能没有页面可链，故只出现在目标列。

| 目标 id / 技能 | 来源 id | 关系 | 来源页面 |
|---|---|---|---|
| `docs.modification` | [构建与出包](../构建.md) | see-also | `docs/构建.md` |
| `docs.modification` | [解码线程数据无法刷新 QML 悬浮窗](../问题记录/跨线程QML数据桥接.md) | applies-to（反向：has-pitfall；来自 applies_to 字段） | `docs/问题记录/跨线程QML数据桥接.md` |
| `docs.modification` | [解码线程数据无法刷新 QML 悬浮窗](../问题记录/跨线程QML数据桥接.md) | see-also | `docs/问题记录/跨线程QML数据桥接.md` |
| `docs.modification` | [本机无工具链时用 GitHub Actions 云端编译](../问题记录/GitHubActions云端编译.md) | applies-to（反向：has-pitfall；来自 applies_to 字段） | `docs/问题记录/GitHubActions云端编译.md` |
| `docs.modification` | [本机无工具链时用 GitHub Actions 云端编译](../问题记录/GitHubActions云端编译.md) | see-also | `docs/问题记录/GitHubActions云端编译.md` |
