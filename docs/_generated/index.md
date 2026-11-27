---
id: docs.generated.index
title: 生成索引
summary: 从 frontmatter 自动生成的导航；勿手改。
type: reference
kind: index
status: active
owner: "@platform"
source_type: doc
source: schema/taxonomy.json
last_reviewed: 2026-11-11
related: []
---

# 生成索引

> 生成文件，勿手改。运行 `python tools/repo-kit/generate.py --root . --write` 重建。

## 按 type

### how-to

| 页面 | kind | status | owner | tier | source |
|---|---|---|---|---|---|
| [构建与出包](../构建.md) | note | active | @simiely | normal | `README.md` |

### reference

| 页面 | kind | status | owner | tier | source |
|---|---|---|---|---|---|
| [文档索引](../index.md) | index | active | @simiely | normal | `README.md` |

## Reports

| 页面 | status | owner | tier | source |
|---|---|---|---|---|
| [Moonlight PC 改造说明](../改造说明.md) | active | @simiely | normal | `README.md` |
| [改造能力清单](../walkthrough/capabilities.md) | active | @simiely | normal | `docs/改造说明.md` |
| [改造代码走查报告](../walkthrough/report.md) | active | @simiely | normal | `docs/walkthrough/scenarios.md` |
| [场景素材与覆盖矩阵](../walkthrough/scenarios.md) | active | @simiely | normal | `docs/walkthrough/capabilities.md` |

## Pitfalls

| 坑 | severity | 症状 | applies_to | status |
|---|---|---|---|---|
| [解码线程数据无法刷新 QML 悬浮窗](../问题记录/跨线程QML数据桥接.md) | high | 串流中连接质量横条的延迟、码率、帧率一直是初始值；C++ 侧日志显示每秒都在推数据，QML 绑定却从不更新。 | `docs.modification` | resolved |
| [本机无工具链时用 GitHub Actions 云端编译](../问题记录/GitHubActions云端编译.md) | medium | 本地没有 Qt / MSVC / 7-Zip，无法出包；git push 报 schannel 或 502，Actions 页面看不到成功的构建。 | `docs.modification` | resolved |

## 全部页面

| id | 标题 | type | kind | status |
|---|---|---|---|---|
| `docs.build` | [构建与出包](../构建.md) | how-to | note | active |
| `docs.index` | [文档索引](../index.md) | reference | index | active |
| `docs.modification` | [Moonlight PC 改造说明](../改造说明.md) | how-to | report | active |
| `pitfalls.cross-thread-qml` | [解码线程数据无法刷新 QML 悬浮窗](../问题记录/跨线程QML数据桥接.md) | explanation | pitfall | resolved |
| `pitfalls.gha-remote-build` | [本机无工具链时用 GitHub Actions 云端编译](../问题记录/GitHubActions云端编译.md) | how-to | pitfall | resolved |
| `walkthrough.capabilities` | [改造能力清单](../walkthrough/capabilities.md) | reference | report | active |
| `walkthrough.report` | [改造代码走查报告](../walkthrough/report.md) | explanation | report | active |
| `walkthrough.scenarios` | [场景素材与覆盖矩阵](../walkthrough/scenarios.md) | reference | report | active |
