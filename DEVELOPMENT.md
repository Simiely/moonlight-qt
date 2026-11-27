# DEVELOPMENT · moonlight-qt（Simiely fork）

> 面向开发者的架构说明与关键问题。版本口径：fork `v1.3.0`，基于上游 `moonlight-stream/moonlight-qt` 6.2.0（提交 `8886485`）。

## 项目概览

这是一个 Moonlight PC 的个人分支，保留上游的串流协议、解码与输入核心，只改 GUI 与少量接入点：

- 默认简体中文（不依赖 `LANG` / `QLocale` 检测）
- 串流中显示可缩放的连接质量横条
- `Ctrl+Alt+Shift+H` 唤出快捷键帮助窗
- 文档与机器校验按 knowledge-base 单项目规范 v2.1.5 维护

功能说明见 [改造说明](docs/改造说明.md)，构建细节见 [构建](docs/构建.md)，版本历史见 [CHANGELOG](CHANGELOG.md)。

## 架构说明

```
app/
├── main.cpp                  QML 单例预创建（ConnectionQuality / ShortcutOverlay）
├── gui/
│   ├── connectionquality.*   横条数据模型，解码线程 → 主线程
│   ├── ConnectionQualityWindow.qml
│   ├── shortcutoverlay.*     帮助窗显隐状态
│   ├── ShortcutHelpWindow.qml
│   ├── main.qml              运行时 createObject(null) 创建两个悬浮窗
│   └── SettingsView.qml      横条开关 + 快捷键速查
├── streaming/
│   ├── session.cpp           会话开始/结束切换模型 active 与显隐重置
│   ├── video/ffmpeg.cpp      每秒统计窗口推送快照
│   └── input/                input.* 配置组合键，keyboard.cpp 分发
└── settings/streamingpreferences.*   开关持久化（showconnquality，默认 true）
```

### 数据流

```
解码线程 FFmpeg 统计
   └─(QueuedConnection)─> ConnectionQuality（主线程）
                              └─ QML 绑定 ─> ConnectionQualityWindow
串流开始/结束
   └─> Session ─> ConnectionQuality::setActive() / ShortcutOverlay::setVisible(false)
键盘
   └─> keyboard.cpp ─> performSpecialKeyCombo(KeyCombo*) ─> 对应单例
```

### 窗口生命周期

两个悬浮窗都在 `main.qml` 里用 `Component.createObject(null)` 运行时创建并保存到属性。原因是 `ApplicationWindow` 的子 `Window` 会继承 `transientParent`，串流时主窗口隐藏会把悬浮窗一起隐藏；`parent=null` 后它们独立存在，也不抢键盘焦点（`Qt.WindowDoesNotAcceptFocus`）。

## 关键问题与方案

### 问题：横条数值不刷新

**TL;DR**：单例在主线程预创建，跨线程更新走 `QueuedConnection`。

完整记录见 [解码线程数据无法刷新 QML 悬浮窗](docs/问题记录/跨线程QML数据桥接.md)。

### 问题：悬浮窗随主窗口隐藏 / 抢焦点

- 现象：串流开始后横条不显示；或点击横条后游戏按键失灵
- 根因：子 `Window` 继承 `transientParent`；普通窗口获得键盘焦点
- 解决：`createObject(null)` + `Qt.Tool` + `Qt.WindowDoesNotAcceptFocus`
- 预防：新增悬浮窗一律走同一套创建函数，不复用声明式子窗口

### 问题：QML `ListElement` 里不能调用 `qsTr()`

- 现象：快捷键表的中文不随语言切换，或直接报语法错误
- 根因：`ListElement` 的属性值只能是字面量，不能是函数调用
- 解决：改用 JS 数组 + `modelData`，在 `Text` 里再 `qsTr(modelData)`
- 预防：需要翻译的列表一律用 JS 数组

### 问题：连续 push 后构建全被取消

**TL;DR**：`build.yml` 的并发组会互相取消，出包走 `workflow_dispatch`。

完整记录见 [本机无工具链时用 GitHub Actions 云端编译](docs/问题记录/GitHubActions云端编译.md)。

### 问题：新增中文文案切英文仍显示中文

- 现象：界面语言切到 English 后，横条与帮助窗仍是中文
- 根因：新文案直接写成中文字面量，没有进 `.ts`
- 解决：默认 `zh_CN`，中文即兜底；要完整多语言需跑 `lupdate` 后补翻译
- 预防：面向所有语言的文案必须走 `qsTr()` 并更新 `app/languages/qml_zh_CN.ts`

## 构建与验证

本机没有 Qt / MSVC 时不要硬装工具链，直接走云端：

```bash
gh workflow run build-win-mac.yml --ref master
gh run list --workflow build-win-mac.yml --limit 3
```

本地构建（Windows）：

```
git submodule update --init --recursive
setup-deps.ps1
scripts\build-arch.bat release x64
scripts\generate-bundle.bat
```

文档与结构校验（三项全绿才算完成）：

```bash
python tools/repo-kit/check_repo.py --root .
python tools/repo-kit/generate.py --root . --check
pwsh tools/update-repo-kit.ps1 -Check
```

## 边界

- 不侵入协议层、编解码与输入发送核心
- 不改上游默认行为，除非明确写进 [CHANGELOG](CHANGELOG.md)
- 双向剪贴板未做：标准 Sunshine 协议未支持（相关 PR 未合并且仅 Linux X11）
