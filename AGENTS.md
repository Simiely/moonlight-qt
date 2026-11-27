# AGENTS.md · moonlight-qt (Simiely fork) 项目规则

> 📌 **文档基线**：2026-11-27（`9e295b1`）—— 四件套补齐、机器层接入、知识库归档
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
- 悬浮窗必须运行时 `createObject(null)` 创建：声明为 ApplicationWindow 子窗口会继承 transientParent，串流时随主窗口一起隐藏
- 标准 Sunshine 无双向剪贴板协议；别在客户端单侧浪费时间
- 云端出包用 `workflow_dispatch` 触发 `build-win-mac.yml`；`build.yml` 的 push 构建带 `cancel-in-progress`，连续推送会互相取消
- 本机代理对 github.com 的 CONNECT 可能 502；先用 `git ls-remote` 验证链路再 push

## 约定

- 中文文档；改造相关 UI 文案用中文；上游原文件尽量不改字节
- 默认值必须写进 CHANGELOG：本 fork 横条默认开启、界面默认 `zh_CN`，其余保持上游默认
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

PR 上的真源联动检查：

```bash
python tools/repo-kit/check_repo.py --root . --changed-since origin/master
```

Windows 编译（见 [docs/构建.md](docs/构建.md)）：

```
scripts\build-arch.bat release x64
scripts\generate-bundle.bat
```

## 当前规模

- 页面：8（critical=0）
- 按 type：explanation=2, how-to=3, reference=3
- 词表版本：2.9.1（规范 2.1.5）

## 边界

机器只保结构、链接、真源与新鲜度；语义正确性靠人审。不要把本文件写成第二本规范。
