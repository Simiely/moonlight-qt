# AGENTS.md · moonlight-qt (Simiely fork) 项目规则

> 📌 **文档基线**：2026-11-26（`8886485`）—— 完成四件套重写与两个改造功能
> **更新文档/代码后，请更新此行**（日期 + 新 commit hash），并在 CHANGELOG 追加版本

本仓库是官方 moonlight-qt 的个人 fork，增加了连接质量横条与快捷键帮助窗。回答相关问题前先读这份，再读 [docs/index.md](docs/index.md)。

## 技术栈

- C++ / Qt 6.11+（上游 CI 用 6.12.1）、QML、qmake、SDL2、FFmpeg、Moonlight Common C
- Windows：MSVC + Qt 6.11+；Linux：GCC/Clang + Qt 6（推荐）；macOS：Xcode + Qt 6.11+
- 机器校验：Python 3.12+（PyYAML / markdown-it-py / jsonschema）

## 关键坑（越具体越好）

- 跨线程模型（ConnectionQuality / ShortcutOverlay）必须在主线程预创建，否则 QueuedConnection 投递到工作线程、UI 永不刷新
- QML `ListElement` 属性值不能调用 `qsTr()`，快捷键表用 JS 数组 + `modelData` 才能翻译
- 新快捷键复用官方 `m_SpecialKeyCombos`（Ctrl+Alt+Shift+字母），自动继承多语言键盘扫描码兼容，别另写监听
- 悬浮窗设 `transientParent: null`，否则串流时主窗口隐藏会带着它一起隐藏
- 标准 Sunshine 无双向剪贴板协议；别在客户端单侧浪费时间
- 云端编译：API 提交不触发 Actions，需 `workflow_dispatch`；git 经本机代理 TLS 失败，用 Python urllib 走 API

## 约定

- 中文文档；改造相关 UI 文案用中文；上游原文件尽量不改字节
- 新增功能默认关闭，不改变上游默认行为
- 不侵入协议层、编解码、输入核心逻辑；改造集中在 gui/ 与接入点
- 机器层文件（`tools/repo-kit/`、`schema/kit.lock.json` 锁定的文件）由上游 kit 托管，勿手改；改了即 `KIT LOCK: FAIL`
- `docs/_generated/` 由生成器产出，不要手改；改 `schema/` 后重跑生成
- 同一命令、清单、报错表只允许一个权威位置；别处链接，不复制；未验证的内容不写进正文

## 常用命令

```bash
python tools/repo-kit/check_repo.py --root .
python tools/repo-kit/generate.py --root . --check
pwsh tools/update-repo-kit.ps1 -Check
```

Windows 编译（见 docs/改造说明.md）：

```
scripts\build-arch.bat release x64
scripts\generate-bundle.bat
```

## 当前规模

- 页面：7（critical=1）
- 按 type：explanation=2, how-to=2, reference=3
- 词表版本：2.9.1

## 边界

机器只保结构、链接、真源与新鲜度；语义正确性靠人审。不要把本文件写成第二本规范。
