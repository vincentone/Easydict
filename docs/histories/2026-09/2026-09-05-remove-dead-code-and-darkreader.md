# 2026-09-05 | 任务：清理遗留死代码与未使用的 DarkReader 资源

**Links:** None

### 用户请求

检查仓库中有无遗留代码或不可达的代码文件；随后确认删除检查报告中的第一类
（完整死文件）与第二类（部分死符号）；另检查有无 Windows 相关文件（本应用仅在
macOS 运行）。

### 变更

- 删除完整死文件并同步 `Easydict.xcodeproj/project.pbxproj`（移除 46 行
  PBXBuildFile/PBXFileReference/group/phase 条目，DarkReader PBXGroup 整块删除）：
  - `Easydict/Swift/Utility/DarkReader/`（darkreader.min.js、DarkReader-LICENSE.txt、
    README.md）：打包进 Resources 但源码零引用的 WebView 暗色注入遗留资源；随删
    `.gitattributes`（唯一条目为该 js 的 binary 标记）。
  - `Easydict/Swift/Utility/Environment/BuildConfig.swift`（`BuildConfig.isDebug` 零引用）。
  - `Easydict/Swift/Utility/Throttler.swift`（类零实例化，仅 ThrottleGate 注释提及）。
  - `Easydict/Swift/Utility/Extensions/View/View+Builder.swift`（三个 macOS 15
    ViewModifier 零调用）。
  - `Easydict/Swift/Utility/Extensions/URL/URL+Extension.swift`（`isValid`/`rootURL`
    零调用）。
  - `Easydict/Swift/Utility/Extensions/Int/Int+ToDouble.swift`（`.double` 零调用）。
  - `Easydict/Swift/Utility/Extensions/Others/WindowTypeExtensions.swift`
    （`availableOptions` 零引用；`EZWindowType` 无 Defaults 存储与
    `localizedStringResource` 调用，conformance 无依赖）。
  - `Easydict/objc/Libraries/CoolToast/CTView.h/.m`（CoolToast 引用链不含 CTView）。
- 删除部分死符号：
  - `NSPasteboard+Extension.swift`：删除零调用的 `image` 属性（含遗留调试 print）、
    `setString(_:)` 及仅被其使用的 `createImageFromPDFData(_:)`；保留被
    `EZWindowManager.m` 使用的 `string` 属性。
  - `EZEnumTypes.h/.m`：删除零调用的 `windowName:`、`fixedWindowPositionDict` 类方法
    与 `EZActionTypeShortcutQuery` 常量，同步删除空类壳与失效的
    `OrderedDictionary+Variadic.h` import。
  - `Double+String.swift`：删除零调用的 `string1f`/`string2f` 与整个 CGFloat 扩展；
    保留被 `elapsedTimeString` 内部使用的 `string3f`。
  - `NSButton+Extension.swift`：删除零调用的 `mm_isOn` 兼容扩展。
  - `Dictionary+Extension.swift`：删除零调用的 `queryString`（及失效的 Alamofire import）。
  - `MMMacro.h`：删除零调用的 `mm_ignoreUnusedVariableWarning` 宏。
- Windows 检查：无 Windows 专属文件、平台宏、CI runner 或行尾配置；历史文档中的
  "windows" 均指应用内窗口。

### 设计意图

仅移除经符号级交叉引用确认零引用的代码与资源，不改变任何运行时行为；
`OrderedDictionary+Variadic.h/.m` 经复查因 `TTTDictionary.m:257` 使用
`initWithKeysAndObjects:` 而从删除清单排除。可编译性与 pbxproj 完整性由构建验证兜底。

### 验证

- `plutil -lint Easydict.xcodeproj/project.pbxproj`：OK。
- `git diff --check`：通过。
- `swiftformat --lint`（4 个变更 Swift 文件）：0/4 需要格式化。
- `xcodebuild build -workspace Easydict.xcworkspace -scheme Easydict`：BUILD SUCCEEDED，
  构建产物清理确认 darkreader 资源已从打包移除。

### 受影响文件

- `Easydict.xcodeproj/project.pbxproj`
- `.gitattributes`（删除）
- `Easydict/Swift/Utility/DarkReader/`（目录删除）
- `Easydict/Swift/Utility/Environment/BuildConfig.swift`（删除）
- `Easydict/Swift/Utility/Throttler.swift`（删除）
- `Easydict/Swift/Utility/Extensions/View/View+Builder.swift`（删除）
- `Easydict/Swift/Utility/Extensions/URL/URL+Extension.swift`（删除）
- `Easydict/Swift/Utility/Extensions/Int/Int+ToDouble.swift`（删除）
- `Easydict/Swift/Utility/Extensions/Others/WindowTypeExtensions.swift`（删除）
- `Easydict/objc/Libraries/CoolToast/CTView.h`、`CTView.m`（删除）
- `Easydict/Swift/Utility/Extensions/Pasteboard/NSPasteboard+Extension.swift`
- `Easydict/Swift/Utility/Extensions/Double/Double+String.swift`
- `Easydict/Swift/Utility/Extensions/NSButton/NSButton+Extension.swift`
- `Easydict/Swift/Utility/Extensions/Dictionary/Dictionary+Extension.swift`
- `Easydict/objc/MMKit/Kit/MMMacro.h`
- `Easydict/objc/Service/Model/EZEnumTypes.h`、`EZEnumTypes.m`

### 后续事项

- `entry.m` 中 `detect_text` 的首个 if 分支仅打日志、与第二个 if 重复判断，以及
  `parseArmguments` 拼写问题未在本次处理（未获授权范围）。
- ObjC `NSObject+EZDarkMode` 与 Swift `DarkModeProtocol` 两套暗色实现并存，可考虑
  后续统一。
