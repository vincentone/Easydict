## 2026-09-02 | 任务：删除划词翻译子系统、Markdown 渲染与 Sparkle 更新

**Links:** [执行计划](../../exec-plans/completed/2026-09-02-remove-selection-markdown-sparkle.md)

### 用户请求

通用设置中划词翻译相关设置经检查功能仍存活，用户确认连功能一起删除；
Markdown 渲染（流式服务已删，功能已死）删除；更新相关连 Sparkle 一起删除。

### 变更

- **划词子系统**：删除 `Swift/Utility/EventMonitor/`（10 文件）、弹按钮窗口
  （EZPopButtonWindow/ViewController）、EZRightClickDetector、MMEventMonitor、
  `SystemUtility/` 全目录（Selection/AX/Shortcut/MenuAction/AppleScript/
  FocusedElementInfo/SystemUtility.swift）、AppleScriptTask+Browser、
  EZReplaceTextButton、DisabledAppTab、AppTriggerConfig、
  ForceGetSelectedTextType、MMEventMonitor pch 导入；`EZWindowManager` 移除
  EventMonitor 装配/selectedText/popButton/selectTextTranslate/logSelectedTextEvent；
  `EZBaseQueryViewController.disableReplaceTextButton` 与
  `QueryResult.showReplaceButton`、`QueryService` 划词可编辑判断删除；
  `NSString/String+HandleInputText.removeBooksExcerptInfo`（Books 摘录）删除；
  HTTP Server `/selectedText` 路由与 GetSelectedTextResponse 删除。
- **快捷键**：`.selectTranslate`（⌥D）、`.toggleAutoSelectText` 两个全局 action、
  selectionShortcut/toggleAutoSelectTextShortcut 键与默认值删除。
- **设置**：AdvancedTab 删除「鼠标查询图标」「文本选择与替换」两个分区及鼠标窗口
  类型 picker；GeneralTab 删除 keep_prev_result/auto_query_selected_text/
  auto_copy_selected_text 三个开关；MyConfiguration/Defaults 对应 wrapper、
  observer、didSet、key 全删；`showMiniFloatingWindow`、`EZQueryMenuTextView`
  改用 shortcutSelectTranslateWindowType / Mini 窗口。
- **Markdown**：`Feature/Markdown/`、MarkdownRendererTests、EZWordResultView 的
  EDMarkdownLabel/ToggleButton 分支、`QueryResult.isMarkdownRenderingEnabled/
  markdownRenderingOverride/toggleMarkdownRendering`、设置开关与 key 删除。
- **Sparkle**：GlobalContext 仅剩共享单例，`MyConfiguration.updater/
  automaticallyChecksForUpdates`、GeneralTab 检查更新/自动检查/Beta 通道 UI、
  主菜单检查更新命令、Info.plist SU* 键、Sparkle SPM 包删除。
- Package.resolved：移除 sparkle/selectedtextkit/axswift 及连带依赖 pin。

### 设计意图

应用收敛为输入翻译 + 粘贴板翻译 + 截图 OCR + TTS 的核心形态；保留
`shortcutSelectTranslateWindowType`（输入翻译/OCR/记录打开仍使用）；
文本自动处理三项设置作用于输入查询管线，保留。

### 验证

- `xcodebuild build`：BUILD SUCCEEDED。
- `xcodebuild test`：161 用例（删除了划词/Markdown 测试），失败仅剩既有
  OCRImageTests 用例与 AppleScript 超时 flake，与基线一致。
- `swiftc -parse` 修改文件、`plutil -lint` pbxproj/Info.plist、`jq` JSON、
  `git diff --check`：通过。
- 符号残留扫描（EventMonitor/SelectedTextKit/Sparkle/Markdown/popButton/
  showReplaceButton/AppTriggerConfig）：无残留。

### 受影响文件

- 删除：EventMonitor(10)、PopButtonWindow(4)、StatusItem(2)、MMEventMonitor(2)、
  SystemUtility(7)、AppleScriptTask+Browser、EZReplaceTextButton(2)、Markdown(3)、
  MarkdownRendererTests、DisabledAppTab、AppTriggerConfig、ForceGetSelectedTextType
- 修改：EZWindowManager.h/.m、EZBaseQueryViewController.h/.m、EZWordResultView.m、
  EZQueryMenuTextView.m、EZQueryView.m、PrefixHeader.pch、EasydictApp.swift、
  GlobalContext.swift、MainMenuCommand.swift、GeneralTab/AdvancedTab/SettingView、
  MyConfiguration、Defaults.Keys+Extension、Notification+Name、ShortcutAction、
  ShortcutManager+Default、KeyHolderWrapper、QueryResult、QueryService、
  LocalStorage、DetectManager 依赖链、SharedConstants、AppleScriptTask、
  String+HandleInputText、HTTPServer routes/TranslationRequest、Info*.plist、
  pbxproj、Package.resolved、Localizable.xcstrings

### 后续事项

- 老用户 UserDefaults 中划词相关残留键为死数据，可在后续版本清理。
- `EZEventMonitor` objc 类已随划词移除；如未来需要取词能力可基于 SelectedTextKit 重引入。
