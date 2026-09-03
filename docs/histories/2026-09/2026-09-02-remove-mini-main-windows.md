## 2026-09-02 | 任务：只保留侧悬浮窗口（删除迷你/主窗口）

**Links:** [执行计划](../../exec-plans/completed/2026-09-02-remove-mini-main-windows.md)

### 用户请求

服务设置中的三个窗口（侧悬浮/迷你/主窗口）只保留侧悬浮窗口；排查确认迷你窗口
已不可达（唯一入口改为打开侧悬浮窗）、主窗口仅启动时可能显示后即被隐藏。

### 变更

- 删除 `EZMainQueryWindow`、`EZMiniQueryWindow` 类；`EZWindowManager` 移除
  mainWindow/miniWindow 属性与 getter、`showMainWindowIfNeeded`/
  `destroyMainWindow`/`showMiniFloatingWindow`；`windowWithType`、
  `floatingWindowLocationWithType` 收敛为 fixed。
- `EZWindowType` 枚举收敛为 `None(-1)/Fixed(2)`（保留 raw value 2 以兼容老用户
  侧悬浮窗配置 key）；`EZLayoutManager` 移除 mini/main frame 与分支；
  `EZEnumTypes` 的 windowName/translateWindowTypeDict 简化。
- 关闭逻辑：`closeFloatingWindowIfNotPinnedOrMain`/`...:exceptWindowType:` 合并为
  `closeFloatingWindowIfNotPinned`；`EZBaseQueryWindow` 不再有 main 面板分支，
  统一为 NonactivatingPanel 浮动面板。
- AppDelegate：启动与 reopen 不再显示主窗口，启动时固定
  `NSApplicationActivationPolicyAccessory`（菜单栏应用）。
- 快捷键：删除「显示迷你窗口 ⌥F」action 与 key。
- 设置：ServiceTab 移除窗口类型切换（服务配置固定侧悬浮窗）；AdvancedTab 删除
  「快捷键划词窗口类型」「迷你窗口位置」picker 与「隐藏主窗口」开关；
  `MyConfiguration`/Defaults 对应 wrapper、observer、key 删除。
- `LocalStorage`/`QueryServiceConfiguration`/`QueryService` 默认 windowType 改为
  `.fixed`；`EZQueryMenuTextView`/`FavoritesTab`/`AppDelegate+EZURLScheme` 调用点
  写死 fixed。
- 本地化删除 5 个失效 key（menu_show_mini_window/mini_window/hide_main_window/
  两个 window type picker key）。

### 设计意图

单窗口形态下窗口类型机制保留骨架（EZWindowType/服务配置 key 结构），仅收敛到
fixed，避免大面积签名改动；老用户 mini/main 的服务启用配置为死数据。

### 验证

- `xcodebuild build`：BUILD SUCCEEDED。
- `xcodebuild test`：138 用例，失败仅剩系统时序/环境 flake（AppleScript、提示音量、
  超时边界，单独复跑均通过），无功能性失败。
- `swiftc -parse`、`plutil -lint`、`jq`、`git diff --check`：通过。
- 符号残留扫描（EZMainQueryWindow/EZMiniQueryWindow/EZWindowTypeMain/
  EZWindowTypeMini/showMiniWindow/hideMainWindow）：无残留。

### 受影响文件

- 删除：`objc/ViewController/Window/MainQueryWindow/`(2)、`MiniQueryWindow/`(2)
- 修改：EZWindowManager.h/.m、EZLayoutManager.h/.m、EZBaseQueryWindow.m、
  EZQueryView.m、EZEnumTypes.h/.m、EZOpenLinkButton.m、AppDelegate.m、
  AppDelegate+EZURLScheme.m、ServiceTab.swift、AdvancedTab.swift、FavoritesTab.swift、
  ServiceSecretConfigreValidatable.swift、WindowTypeExtensions.swift、
  QueryServiceConfiguration.swift、QueryService.swift、LocalStorage.swift、
  ShortcutAction.swift、ShortcutManager+Default.swift、KeyHolderWrapper.swift、
  MyConfiguration.swift、Defaults.Keys+Extension.swift、EZQueryMenuTextView.m、
  Localizable.xcstrings、pbxproj

### 后续事项

- 老用户 UserDefaults 中 mini/main 服务配置与窗口 frame 为死数据，可在后续版本清理。
