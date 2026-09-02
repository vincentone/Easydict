## 2026-09-01 | 任务：状态栏图标左键直达输入翻译、右键精简菜单

**Links:** [执行计划](../../exec-plans/completed/2026-09-01-status-bar-left-click-input-translate.md)

### 用户请求

左键点击菜单栏图标直接打开输入翻译；右键才显示弹窗，弹窗仅保留「输入翻译」
「粘贴板翻译」「设置...」，其余项及相关逻辑全部删除。

### 变更

- 新增 `StatusBarController`（NSStatusItem）：左键/Ctrl+左键 → `inputTranslate`；
  右键/中键 → 弹出仅含 输入翻译(⌥A)、粘贴板翻译(⌥F)、设置...(⌘,) 的 NSMenu。
  设置项通过 `.openSettings` 通知复用现有 SettingsAccess 管线；按钮内嵌 1×1
  隐藏 SwiftUI 宿主（NSHostingView）保持 `openSettingsAccess` 注入存活，
  查询窗口 titlebar 设置齿轮的通知路径不受影响。
- `EasydictApp` 移除 MenuBarExtra 及 `hideMenuBar` AppStorage、`toggledValue` 扩展；
  `AppDelegate` 启动时调用 `StatusBarController` setup。
- `hideMenuBarIcon`、`selectedMenuBarIcon` 设置改由 StatusBarController 观察
  Defaults 生效（图标可见性与 DEBUG/Release 模板渲染行为保持原逻辑）。
- 删除 `MenuItemView.swift` 及其版本检查/帮助/导出日志等逻辑；移除
  `showOCRMenuItems` 开关（AdvancedTab + Defaults key + 字符串）。
- 移除 ZipArchive SPM 包（唯一使用者已删）；清理失效本地化 key
  （quit/Help/Feedback/Export Log/Log Directory/show_ocr_menu_items 等）。
- `Package.resolved` 同步：移除 ziparchive pin，新增 Vapor 树新增传递依赖
  （swift-configuration/swift-http-structured-headers/swift-service-lifecycle）。

### 设计意图

MenuBarExtra 的 `.menu` 风格无法区分左右键，改用 NSStatusItem 获得原生左右键
分发；设置打开机制复用既有 `.openSettings` 通知 + SettingsAccess 隐藏
SettingsLink 注入，避免依赖已废弃的 `showSettingsWindow:` selector。

### 验证

- `xcodebuild build`：BUILD SUCCEEDED。
- `xcodebuild test` 全量 185 用例：仅既有 `OCRImageTests` 4 用例失败（与基线提交
  7ef64343 一致的 macOS 26 OCR 输出差异）与时序 flake（AppleScript/TaskTimeout，
  单独复跑通过），其余全部通过。
- `plutil -lint` pbxproj、`jq` JSON 校验、`swiftc -parse`：通过。
- 环境注意：Xcode IDE 与命令行并发使用同一 DerivedData 会互相删除 SPM 工件，
  表现为 "There is no XCFramework found"；退出 Xcode 后恢复正常。

### 受影响文件

- `Easydict/App/StatusBarController.swift`（新增）、`EasydictApp.swift`、`AppDelegate.m`
- `Easydict/Swift/View/MenuItemView.swift`（删除）、`AdvancedTab.swift`、
  `Defaults.Keys+Extension.swift`
- `Easydict.xcodeproj/project.pbxproj`、`Easydict.xcworkspace/xcshareddata/swiftpm/Package.resolved`、
  `Easydict/App/Localizable.xcstrings`
- `docs/exec-plans/completed/2026-09-01-status-bar-left-click-input-translate.md`

### 后续事项

- 若需要在隐藏菜单栏图标时保持设置齿轮可用，已有通知管线与宿主仍存活，无需处理。
- 老用户 `showOCRMenuItems` UserDefaults 键为死数据，可在后续版本清理。
