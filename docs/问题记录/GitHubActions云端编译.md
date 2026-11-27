---
id: pitfalls.gha-remote-build
title: 本机无工具链时用 GitHub Actions 云端编译
summary: 本机没有 Qt/MSVC 时，用 workflow_dispatch 触发 Windows 构建；连续 push 会被并发组互相取消，认证与代理问题要先排除。
type: how-to
kind: pitfall
status: resolved
owner: "@simiely"
tier: normal
confidence: high
topics: [development]
severity: medium
symptom: 本地没有 Qt / MSVC / 7-Zip，无法出包；git push 报 schannel 或 502，Actions 页面看不到成功的构建。
cause: 三个问题叠加：本机代理对 github.com 的 CONNECT 不稳定、git/gh 未完成认证、build.yml 的 concurrency 设置了 cancel-in-progress，连续 push 会互相取消。
detect: 先看 gh auth status 是否已登录；再跑 git ls-remote 验证代理链路；最后用 gh run list 看 event 与 conclusion，区分 push 触发与手动触发。
avoid: 一次 push 合并多个提交，减少并发取消；出包统一走 workflow_dispatch 触发 Build - Windows and macOS，不要在 push 后等构建；代理不稳时给 git 显式指定可用代理。
recover: 在 Actions 页面对失败的 job 点 Re-run，或重新 dispatch 指定分支；已取消的 run 不会自动补跑。
applies_to: [docs.modification]
source_type: code
source: .github/workflows/build-win-mac.yml
last_reviewed: 2026-11-27
related: [docs.modification:see-also]
---
# 本机无工具链时用 GitHub Actions 云端编译

**TL;DR**：本机只负责改代码和推送，出包交给 `workflow_dispatch` 的 Windows/macOS 构建。

## 症状

- `git push` 报 `schannel: server closed abruptly` 或 `CONNECT tunnel failed, response 502`
- push 后 Actions 里一堆 `Build` 全部 `cancelled`
- 手动触发后能成功，但不知道产物在哪

## 根因

1. **代理**：系统代理对 `github.com` 的 CONNECT 不稳定，`ls-remote` 也会失败；换一个可用本地代理即可。
2. **认证**：`gh` 未登录时所有 API 都不可用，`gh run list` 直接报未认证。
3. **并发取消**：`build.yml` 里 `concurrency: group: build-${{ github.ref }}` + `cancel-in-progress: true`，同一分支连续 push 时后一个会取消前一个。
4. **触发方式**：`build.yml` 的 push 构建只上传 CI 版本号与临时产物；要拿完整包应使用 `build-win-mac.yml` 的 `workflow_dispatch`。

## 正确做法

```bash
# 1. 验证链路（能返回 HEAD 即通）
git -c http.proxy=http://127.0.0.1:7890 ls-remote https://github.com/Simiely/moonlight-qt.git HEAD

# 2. 认证
gh auth status

# 3. 手动出包
gh workflow run build-win-mac.yml --ref master
gh run list --workflow build-win-mac.yml --limit 3
```

产物在对应 run 的 Artifacts 区：`Moonlight-Windows-x64-v120`、`Moonlight-Windows-arm64-v120`、`zDevDbgSyms-Windows-v120`。

## 注意

- 产物是**便携目录**，不是安装器；解压后直接运行 `Moonlight.exe`。
- `Moonlight.exe` 的文件版本跟上游走（6.2.0.0），fork 版本看 Artifact 名称与 `CHANGELOG.md`。
- 连续 push 多个提交时，只有最后一个 push 构建可能存活；重要出包一律手动 dispatch。
- 若 dispatch 返回 `422 Actions has been disabled for this repository`，先打开仓库 Actions 页确认 fork 的启用按钮；此时 `GET /actions/permissions` 仍可能显示 `enabled: true`，不要只信 API。启用后 push 与 dispatch 才会恢复。

## 关联

- 改造说明：[Moonlight PC 改造说明](../改造说明.md)
- 同源问题：[解码线程数据无法刷新 QML 悬浮窗](跨线程QML数据桥接.md)
