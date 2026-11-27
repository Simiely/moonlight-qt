---
id: docs.generated.pitfalls
title: 踩坑索引
summary: 从 kind=pitfall 页面自动生成的失败模式索引；勿手改。
type: reference
kind: index
status: active
owner: "@platform"
source_type: doc
source: schema/taxonomy.json
last_reviewed: 2026-11-11
related: []
---

# 踩坑索引

> 生成文件，勿手改。运行 `python tools/repo-kit/generate.py --root . --write` 重建。
> 每个坑的权威内容在它自己的页面；本页只做导航。

## 未解决（0）

（无）

## 已解决（2）

| 严重度 | 坑 | 症状 | 适用 |
|---|---|---|---|
| high | [解码线程数据无法刷新 QML 悬浮窗](../问题记录/跨线程QML数据桥接.md) | 串流中连接质量横条的延迟、码率、帧率一直是初始值；C++ 侧日志显示每秒都在推数据，QML 绑定却从不更新。 | `docs.modification` |
| medium | [本机无工具链时用 GitHub Actions 云端编译](../问题记录/GitHubActions云端编译.md) | 本地没有 Qt / MSVC / 7-Zip，无法出包；git push 报 schannel 或 502，Actions 页面看不到成功的构建。 | `docs.modification` |

## 按适用范围

### `docs.modification`

- [解码线程数据无法刷新 QML 悬浮窗](../问题记录/跨线程QML数据桥接.md)（high）
- [本机无工具链时用 GitHub Actions 云端编译](../问题记录/GitHubActions云端编译.md)（medium）
