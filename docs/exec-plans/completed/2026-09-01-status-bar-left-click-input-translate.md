# 状态栏图标左键直达输入翻译、右键精简菜单

- 状态：completed
- 创建日期：2026-09-01
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户要求：左键点击菜单栏图标直接打开输入翻译；右键才弹出菜单，且菜单仅保留
「输入翻译」「粘贴板翻译」「设置...」三项，其余菜单项及其相关逻辑全部删除。

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 目标结果：NSStatusItem 替换 MenuBarExtra；左键 → `inputTranslate`，右键 → 三项
  NSMenu；设置项复用 `.openSettings` 通知 + SettingsAccess 宿主管线；删除
  MenuItemView、showOCRMenuItems 开关、ZipArchive 包与失效字符串。
- 允许修改路径：`Easydict/`、`Easydict.xcodeproj/`、`Easydict.xcworkspace/`、
  `docs/exec-plans/`、`docs/histories/`
- 同任务 history：`docs/histories/2026-09/2026-09-01-status-bar-left-click-input-translate.md`
- 禁止动作：push、pull、rebase、merge
- 预期交付物：构建通过 + history + completed 计划
- 验收标准：左键/右键行为正确；菜单仅三项；构建与测试通过

## 语义与范围

- 用户要求 Agent 做什么：修改（菜单栏图标交互与菜单内容）
- 授权操作：新增 StatusBarController、改写 App 入口、删除菜单文件与死代码
- 否定与范围限制：不动全局快捷键、不动查询窗口 titlebar 的设置齿轮（.openSettings
  通知发送方）、不动 Settings 场景本身
- 歧义：无

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：6e7d96f304945fa68dd866497672a65ac413cfb2（dev）
- 初始 staged：无
- 初始 unstaged：`Easydict/App/Localizable.xcstrings`（Xcode 构建阶段自动重排格式，
  无语义变化，随本任务一并提交）
- 初始 untracked：本计划文件
- 初始冲突：无
- Agent-owned paths：Easydict/App/StatusBarController.swift、EasydictApp.swift、
  AppDelegate.m、MenuItemView.swift（删除）、AdvancedTab.swift、
  Defaults.Keys+Extension.swift、pbxproj、Package.resolved、Localizable.xcstrings、
  history

## 目标与非目标

### 目标

- 左键状态图标 → 输入翻译窗口；Ctrl/右键 → 三项菜单（含快捷键显示 ⌥A/⌥F/⌘,）
- `hideMenuBarIcon` / `selectedMenuBarIcon` 设置继续生效
- 删除：MenuItemView.swift、showOCRMenuItems、ZipArchive SPM、失效本地化 key
- xcodebuild build/test 通过

### 非目标

- 不改全局快捷键体系（Magnet/ShortcutManager）
- 不改查询窗口内 titlebar 按钮与 About/检查更新（主菜单仍保留检查更新入口）

## 工作计划

1. 新建 `Easydict/App/StatusBarController.swift`：NSStatusItem + 三项 NSMenu +
   隐藏 SettingsAccess 宿主（NSHostingView 1×1）+ Defaults 观察
2. 改写 `EasydictApp.swift`：移除 MenuBarExtra、toggledValue、hideMenuBar AppStorage
3. `AppDelegate.m` 启动时接入 `[[StatusBarController sharedInstance] setup]`
4. 删除 `MenuItemView.swift`；pbxproj 增删引用
5. 移除 `showOCRMenuItems`（AdvancedTab/Defaults key/字符串）
6. 移除 ZipArchive 包；清理失效本地化 key
7. `xcodebuild build + test` 验证

## 风险与决策

- SettingsAccess 的隐藏 SettingsLink 需要被 SwiftUI 实例化才能编程触发：
  放在状态按钮内的 NSHostingView 中，随按钮常驻（即使图标隐藏也保持宿主存活）
- NSMenu 在 menu tracking 模式下主队列仍会派发，`.openSettings` 通知路径可用
- 左键动作复用 `EZWindowManager.inputTranslate`（与全局快捷键同一路径）
- Xcode IDE 与命令行并发使用同一 DerivedData 会导致 SPM 工件互删：验证期间要求
  用户退出 Xcode 后构建即恢复正常（环境因素，非代码问题）

## 进度

- [x] StatusBarController
- [x] EasydictApp 改写 + AppDelegate 接入
- [x] MenuItemView 删除与 pbxproj
- [x] showOCRMenuItems / ZipArchive / 字符串清理
- [x] 验证与交付

## 验证

- `xcodebuild build`：BUILD SUCCEEDED（退出 Xcode 消除并发干扰后）。
- `xcodebuild test` 全量 185 用例：与任务前基线一致——仅既有 `OCRImageTests`
  4 用例（基线提交同样失败）与时序 flake（AppleScript 超时/TaskTimeout 边界，
  单独复跑通过）；其余全部通过。
- `swiftc -parse` 修改过的 Swift 文件：通过。
- `plutil -lint` pbxproj、`jq` xcstrings/Package.resolved：通过。

## 完成条件

- 全部步骤完成、验证通过、history 完整、自动本地提交完成。
