# Moonlight PC · 中文分支

基于 [moonlight-stream/moonlight-qt](https://github.com/moonlight-stream/moonlight-qt) 的个人分支：面向 NVIDIA GameStream / [Sunshine](https://github.com/LizardByte/Sunshine) 主机的 PC 串流客户端，默认简体中文，并加了两个串流中常用的小工具。

- **连接质量横条**：贴在串流画面顶部，实时显示延迟、丢包、码率、帧率，可缩放、可调透明度
- **快捷键帮助窗**：串流中按 `Ctrl+Alt+Shift+H` 随时查看全部快捷键
- **默认中文**：首次启动即中文界面，不受系统 `LANG` 影响

## 与上游的关系

| 项 | 值 |
|---|---|
| 上游 | `moonlight-stream/moonlight-qt` 6.2.0（`8886485`） |
| 本 fork 版本 | `v1.3.0` |
| 改动范围 | 仅 GUI 与接入点；协议、解码、输入发送核心不改 |
| 许可 | GPL-3.0（继承上游） |

上游功能（HDR、AV1、7.1 声道、手柄力反馈、多点触控等）全部保留，详见[上游 README](https://github.com/moonlight-stream/moonlight-qt#features)。

## 快速开始

1. 在主机安装 [Sunshine](https://github.com/LizardByte/Sunshine)（或 NVIDIA GameStream）。
2. 启动 Moonlight，同一局域网内会自动发现主机；没有发现时用「手动添加 PC」填 IP。
3. 在主机输入 Moonlight 显示的 4 位配对码。
4. 选择游戏或桌面开始串流。

串流中常用快捷键：

| 快捷键 | 功能 |
|---|---|
| `Ctrl+Alt+Shift+H` | 显示/隐藏快捷键帮助 |
| `Ctrl+Alt+Shift+B` | 显示/隐藏连接质量横条 |
| `Ctrl+Alt+Shift+[` / `]` | 缩小 / 放大横条 |
| `Ctrl+Alt+Shift+-` / `=` | 降低 / 提高横条背景透明度 |
| `Ctrl+Alt+Shift+Q` | 断开会话 |
| `Ctrl+Alt+Shift+Z` | 释放 / 捕获鼠标 |

完整列表见 [改造说明](docs/改造说明.md)。

## 下载与构建

仓库暂不发布安装包，构建产物从 GitHub Actions 获取：

```bash
gh workflow run build-win-mac.yml --ref master
gh run download <run-id> -n Moonlight-Windows-x64-v120
```

解压后直接运行 `Moonlight.exe`（便携目录，无需安装）。本地构建的工具链要求与各平台命令见 [构建与出包](docs/构建.md)。

## 文档

- [文档索引](docs/index.md) — 全部文档的入口
- [改造说明](docs/改造说明.md) — 两个功能的完整说明、改动清单与已知限制
- [构建与出包](docs/构建.md) — 云端 / 本地构建
- [DEVELOPMENT](DEVELOPMENT.md) — 架构与关键问题
- [CHANGELOG](CHANGELOG.md) — 版本历史

## 已知限制

- 全屏独占游戏可能盖住置顶悬浮窗，建议主机使用无边框窗口化
- 新增文案目前只有中文，切到其他语言时这部分仍是中文
- 双向剪贴板未实现：标准 Sunshine 协议尚未支持

## 致谢

上游项目与所有贡献者：[moonlight-stream/moonlight-qt](https://github.com/moonlight-stream/moonlight-qt)。本分支只做个人使用向的界面增强，问题请优先对照上游文档排查。
