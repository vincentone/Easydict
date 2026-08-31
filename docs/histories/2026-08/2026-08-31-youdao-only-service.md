## 2026-08-31 | 任务：收敛为仅有道翻译来源

**Links:** [执行计划](../../exec-plans/completed/2026-08-31-youdao-only-service.md)

### 用户请求

只保留有道作为唯一查询来源，应用只展示有道的信息，删除其他一切无关服务来源及其代码、配置与 UI。

### 变更

- `QueryServiceFactory` 服务注册表仅保留 `.youdao`；`LocalStorage` 默认服务列表仅剩有道。
- 删除 25 个服务目录（Ali/Baidu/Bing/BuiltInAI/Caiyun/Claude/ClaudeCode/CodexCLI/CustomOpenAI/DeepL/DeepSeek/Dictionary/Doubao/Gemini/GitHub Models/Google/Groq/MiniMax/NiuTrans/Ollama/OpenAI/Tencent/Volcano/Zhipu/AITool）及 objc WebViewTranslator；`AppleService` 剥离翻译与系统 TTS，仅保留 Apple Vision OCR 与设备端语言检测的内部能力。
- 移除 StreamService 体系级联引用：GlobalContext 订阅逻辑、EZResultView/EZBaseQueryViewController 流式分支、ActionManager 与翻译/润色替换动作及其菜单、快捷键、Defaults key；HTTP Server 移除 `streamTranslate` 与 Apple Dictionary 分支，仅保留有道可用的 `/translate`、`/ocr`、`/detect` 等。
- 移除语言检测优化设置（baidu/google）、Apple 离线翻译开关与全部非有道 TTS 选项；`TTSServiceType` 仅剩有道。
- `EZEnumTypes`/`EZConstKey`/`EZSchemeParser` 仅保留有道与通用 key；原 AppleDictionary 服务依赖的系统词典单词判断提取为 `SystemDictionary`（DictionaryKit）。
- 同步 pbxproj：移除约 130 个文件引用、GoogleGenerativeAI 与 OpenAI SPM 包、30 个空 group；清理 140 个失效本地化 key 与已删服务的测试（保留 Apple 检测/OCR、OCR 文本处理等）。
- 同步 `docs/architecture/overview.md` 的来源描述。

### 设计意图

有道为唯一查询来源；Apple Vision OCR 与设备端语言检测作为离线系统能力保留（决策点 A 采用推荐方案）；quick link、HTTP Server、Markdown 渲染等通用设施不属于"来源"，按非目标保留。旧的 UserDefaults 未知服务 ID 由 `QueryServiceFactory.metadata` 过滤天然容忍。

### 验证

- `swiftc -parse` 全部剩余 Swift 源文件：通过。
- `plutil -lint` pbxproj、括号平衡校验、悬挂引用扫描：通过。
- `jq -e .` Localizable.xcstrings、代码引用 key 完整性检查：通过。
- `git diff --check`：通过。
- 符号级残留扫描（服务类名、StreamService、EZServiceType*、AI action）：无残留。
- Xcode 26.6 环境实测：
  - `xcodebuild build`：**BUILD SUCCEEDED**。
  - `xcodebuild test` 全量 185 个用例：除 `OCRImageTests` 4 个用例（在基线提交 7ef64343 上同样失败，属 macOS 26 Vision OCR 输出与预期文本的既有差异）和 3 个时序/环境敏感用例（TaskTimeout 超时边界、AppleScript 执行超时、系统提示音量，单独复跑均通过）外全部通过；`ServiceTests` 有道翻译集成、语言检测、OCR 文本处理等核心套件通过。
  - 构建/验证过程中发现并修复三处问题：pbxproj 包引用区两处括号损坏（导致 SPM 解析静默丢失 15 个包）、`Package.resolved` 被失败构建部分重写、以及带空格路径（`GitHub Models`）的引用漏删；另修复两个既有编译错误（Magnet 3.x `KeyCombo(key:carbonModifiers:)` 非可失败、`stringDefaultsKey`/`customOpenAI` 遗留引用），并补上 `SystemDictionary.swift` 的工程注册。

### 后续事项

- 老用户 UserDefaults 中残留的旧服务配置为死数据，可在后续版本考虑一次性清理。
- `OCRImageTests` 4 个用例为 macOS 26 OCR 引擎输出与历史预期文本的既有差异，与本次收敛无关，可另行更新预期文本修复。

### 受影响文件

- `Easydict/Swift/Service/**`（删除 25 个服务目录、裁剪 Apple/Youdao/Model）
- `Easydict/Swift/{Feature,View,Utility,Model}/**`（配置、设置 UI、HTTP Server、快捷键、菜单、SystemDictionary 新增）
- `Easydict/objc/**`（EZEnumTypes、EZConstKey、EZSchemeParser、EZAudioPlayer、EZResultView、EZWordResultView、EZBaseQueryViewController、EZTitlebar、EZWebViewManager；删除 objc/Service/WebViewTranslator）
- `EasydictTests/Service/**`（删除 6 个测试文件/目录、改写 ServiceTests/AppleServiceTests）
- `Easydict.xcodeproj/project.pbxproj`、`Easydict.xcworkspace/xcshareddata/swiftpm/Package.resolved`、`Easydict/App/Localizable.xcstrings`、`Easydict/App/Assets.xcassets/service-icon/*`
- `docs/architecture/overview.md`、`docs/exec-plans/completed/2026-08-31-youdao-only-service.md`
