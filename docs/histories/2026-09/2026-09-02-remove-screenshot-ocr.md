## 2026-09-02 | 任务：删除截图翻译与图片 OCR 全家族

**Links:** [执行计划](../../exec-plans/completed/2026-09-02-remove-selection-markdown-sparkle.md)

### 用户请求

截图翻译的功能及设置全部删除。覆盖：截图翻译（⌥S）、静默截图 OCR（⌥⇧S）、
截图 OCR 窗口、粘贴板 OCR、有道 OCR 开关、OCR 设置区及全部相关逻辑。
（同轮确认：上一轮检查的三个设置中 autoQueryOCRText/autoCopyOCRText 随本任务
删除；selectQueryTextWhenWindowActivate 保留——它作用于输入翻译窗口。）

### 变更

- 删除 `Feature/Screenshot/`（截图采集/覆盖层/状态/事件监听）、
  `Service/Apple/AppleOCREngine/`（27 文件：引擎/合并/窗口/调试视图）、
  `YoudaoService+OCR` + `YoudaoOCRResponse`、`EZOCRResult.h/.m`、`String+OCR`、
  `NSImage+ImageFormat`、`NSImage+Export`、`NSImage+Test`、OCR 测试
  （OCRImageTests/文本处理/标点/样例/OCRImages 资源）。
- `AppleService` 仅保留语言检测（移除 Vision OCR 与引擎）；`AppleLanguageMapper`
  移除 OCR 语言表；`QueryService` 移除 `ocr/ocrAndTranslate` 虚方法；
  `YoudaoService` 移除 OCR 实现；`DetectManager` 仅保留语言检测与代理检查；
  `QueryModel` 移除 ocrImage/ocrConfidence。
- `EZWindowManager` 移除 snipTranslate/silentScreenshotOCR/screenshotOCR/
  showFloatingWindowWithOCRImage/captureWithRestorePreviousApp 与 Screenshot 守卫；
  `pasteboardTranslate` 仅保留文本；`closeWindowOrExitSreenshot` 简化。
- `EZBaseQueryViewController` 移除 startOCRImage/resetQueryModelForBackgroundOCR
  与 OCR 自动查询/复制分支；`EZEnumTypes` 删除 OCR 类 actionType 常量。
- 快捷键：snipTranslate/silentScreenshotOCR/screenshotOCR/pasteboardOCR/
  showOCRWindow 五个 action、默认键与 Defaults key 删除。
- 设置：GeneralTab 删除「图片 OCR 后自动查询」「自动复制截图 OCR 结果」；
  AdvancedTab 删除整个 OCR 设置区；`EZConst`/Notification 无 OCR 残留；
  本地化删除 15+ 个 OCR/截图 key；`AppleLanguageMapper` OCR 语言表清理；
  `TestSuites` 移除 .ocr 标签。
- pbxproj：移除 123 个文件引用与 11 个空 group。

### 设计意图

应用形态最终收敛为：输入翻译、粘贴板翻译（文本）、有道查询弹框、TTS、
状态栏与设置。图片/截图相关能力全部移除。

### 验证

- `xcodebuild build`：BUILD SUCCEEDED。
- `xcodebuild test`：138 用例，失败仅剩系统时序/环境 flake（AppleScript 执行、
  提示音量、超时边界，单独复跑均通过），无功能性失败。
- `swiftc -parse`、`plutil -lint`、`jq`、`git diff --check`：通过。
- 符号残留扫描（OCR/Screenshot/snip/pasteboardOCR/AppleOCREngine/EZOCRResult）：
  无残留。

### 受影响文件

- 删除 125 个文件（Screenshot/AppleOCREngine/Youdao OCR/EZOCRResult/测试与资源）
- 修改：EZWindowManager、EZBaseQueryViewController、EZQueryView、EZEnumTypes、
  PrefixHeader、Bridging Header、AppleService、AppleLanguageMapper、YoudaoService、
  QueryService、QueryModel、DetectManager、ShortcutAction、ShortcutManager+Default、
  KeyHolderWrapper、MyConfiguration、Defaults.Keys+Extension、GeneralTab/AdvancedTab、
  routes/TranslationRequest、SharedConstants、TestSuites、pbxproj、
  Package.resolved、Localizable.xcstrings

### 后续事项

- 老用户 UserDefaults 中截图/OCR 残留键为死数据，可在后续版本清理。
- `AppleLanguageDetector` 内补回的 `wordComponents/englishWordCount` 助手仅服务
  语言检测，如后续无用可再清理。
