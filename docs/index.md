---
id: docs.index
title: 文档索引
summary: moonlight-qt fork 的人工导航；完整页面索引由生成器产出。
type: reference
kind: index
status: active
owner: "@simiely"
topics: [governance]
source_type: doc
source: README.md
last_reviewed: 2026-11-27
related: []
---
# 文档索引

本页只做人工导航；完整页面索引由生成器产出，见 [生成索引](_generated/index.md)。

## 开始

- [README](../README.md) — 项目简介、改造功能与快速开始
- [改造说明](改造说明.md) — 两个改造功能的完整说明与改动清单
- [构建与出包](构建.md) — 云端 Actions 与本地各平台构建
- [DEVELOPMENT](../DEVELOPMENT.md) — 架构与关键问题
- [AGENTS](../AGENTS.md) — AI / 维护者入口
- [CHANGELOG](../CHANGELOG.md) — 版本历史

## 问题记录

- [跨线程 QML 数据桥接](问题记录/跨线程QML数据桥接.md) — 解码线程推送不刷新 UI
- [GitHub Actions 云端编译](问题记录/GitHubActions云端编译.md) — 无本机工具链时的出包路径

## 走查记录

- [能力清单](walkthrough/capabilities.md) — 两个改造功能的真实能力与边界
- [场景素材与覆盖矩阵](walkthrough/scenarios.md) — 9 条操作链，L1-L9 分级
- [走查报告](walkthrough/report.md) — 问题清单、风险评分与修复结论

## 边界

不要在这里复制完整页面清单；生成索引与反链由 `tools/repo-kit/generate.py` 产出。
