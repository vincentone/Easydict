## 2026-09-02 | 任务：删除弹框右上角四按钮与设置页失效逻辑

**Links:** [执行计划](../../exec-plans/completed/2026-09-02-remove-titlebar-quick-buttons.md)

### 用户请求

删除翻译弹框右上角四个按钮（快捷操作 ⚙️、Google、Apple 词典、Eudic）及相关逻辑；
设置页清理已不存在功能的配置项；仅保留核心有道翻译弹框。

### 变更

- `EZTitlebar` 仅保留 pinButton：删除 quickActionButton（含 quickActionMenu 五项：
  添加到收藏/替换换行/移除注释/分词/打开设置）、googleButton、appleDictionaryButton、
  eudicButton、stackView 及 `EZTitlebarButtonType` 三个 case；`updateTitlebar` 简化为
  语言变化刷新 pin。
- 删除已无使用者的 `menuActionBlock` 链路：`EZBaseQueryWindow` 赋值、
  `EZBaseQueryViewController.receiveTitlebarAction:` 声明与实现。
- 快捷键链路：`ShortcutAction` 删除 `.google/.eudic/.appleDic`；`KeyHolderWrapper`、
  `MainMenuShortcutCommand` 同步删三项；`ShortcutManager+Default` 删除三组默认键；
  Defaults keys（googleShortcut/eudicShortcut/appleDictionaryShortcut）与
  `MyConfiguration` 三个 ShortcutWrapper 删除，observeKeys 收窄为 `[.pinShortcut]`。
- 设置页：GeneralTab 删除 quick link 分区（4 个 Toggle + header）；Defaults keys
  `show*QuickLink`×3 + `showQuickActionButton` 删除；`MyConfiguration` 4 wrapper +
  4 observer + `postUpdateQuickLinkButtonNotification` 删除。
- 通知链：`Notification.Name.linkButtonUpdated`（两处）与
  `EZConst.h EZQuickLinkButtonUpdateNotification` 删除。
- `EZOpenLinkButton`：删除三个 URL scheme 常量与 Google 搜索死分支（类保留，
  pin 与结果视图有道链接按钮仍使用）；`EZQueryView.m` 清理引用已删按钮的注释块。
- 本地化：删除 14 个失效 key（quick_action/add_to_favorites/open_app_settings/
  open_in_*×3/文本处理三项/show_*_quick_link×4/quick_link header）。

### 设计意图

弹框只保留核心查询能力：输入、pin、有道结果与发音/复制；设置入口收敛到状态栏
右键菜单。被删按钮的文本处理动作在设置中仍有"自动"模式等效功能。

### 验证

- `xcodebuild build`：BUILD SUCCEEDED。
- `xcodebuild test` 全量 185 用例：与基线一致——仅既有 `OCRImageTests` 4 用例
  （基线提交同样失败）与时序 flake（AppleScript/TaskTimeout，单独复跑通过）。
- `swiftc -parse` 修改文件、`plutil -lint` pbxproj、`jq` xcstrings、
  `git diff --check`：通过。
- 符号残留扫描（四按钮、ButtonType case、menuActionBlock、quick link keys、
  通知名、URL scheme 常量）：无残留。

### 受影响文件

- `Easydict/objc/ViewController/View/Titlebar/EZTitlebar.h/.m`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.m`、
  `EZBaseQueryViewController.h/.m`
- `Easydict/objc/ViewController/View/CustomButton/EZLinkButton/EZOpenLinkButton.h/.m`
- `Easydict/objc/ViewController/View/QueryView/EZQueryView.m`
- `Easydict/Swift/Feature/Shortcut/Model/{ShortcutAction,ShortcutManager+Default}.swift`、
  `Easydict/Swift/Feature/Shortcut/View/KeyHolderWrapper.swift`
- `Easydict/Swift/View/MenuView/MainMenuShortcutCommand.swift`、
  `Easydict/Swift/View/SettingView/Tabs/TabView/GeneralTab.swift`
- `Easydict/Swift/Feature/Configuration/{MyConfiguration,Defaults.Keys+Extension}.swift`、
  `Easydict/Swift/Utility/Extensions/Notification/Notification+Name.swift`、
  `Easydict/App/EZConst.h`
- `Easydict/App/Localizable.xcstrings`
- `docs/exec-plans/completed/2026-09-02-remove-titlebar-quick-buttons.md`

### 后续事项

- 老用户 UserDefaults 中残留的快捷键/quick link 键为死数据，可在后续版本清理。
- 收藏功能仅剩设置页查看入口；如需重新提供添加收藏 UI，可在结果视图另加。
