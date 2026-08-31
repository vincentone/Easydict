# 收敛为仅有道翻译来源

- 状态：completed
- 创建日期：2026-08-31
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户要求 Easydict 只保留有道（YoudaoService）作为唯一查询来源，应用只展示有道的结果，删除其他一切无关服务来源及其代码、配置与 UI。

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 目标结果：服务注册表仅含 Youdao；删除其余 28 个服务及其 AI 功能、TTS 选项、API key 配置、测试与 SPM 依赖；应用查询、TTS、OCR 只走有道 + Apple Vision/语言检测基础能力。
- 允许修改路径：`Easydict/`、`EasydictTests/`、`Easydict.xcodeproj/`、`docs/exec-plans/`、`docs/histories/`、`docs/architecture/overview.md`
- 同任务 history：`docs/histories/2026-08/2026-08-31-youdao-only-service.md`
- 禁止动作：push、pull、rebase、merge；不扩大到 quick link（Google/Eudic/Apple 词典跳转按钮）等应用级外围功能
- 预期交付物：可编译的 Youdao-only 构建 + history + completed 计划
- 验收标准：静态验证全部通过；查询/TTS/OCR 无非有道来源残留引用

## 语义与范围

- 用户要求 Agent 做什么：修改（按已确认计划实施）
- 授权的工作树操作：删除服务源码、编辑 pbxproj、修剪配置与 UI、清理测试与本地化
- 否定与条件：只保留有道来源；Apple Vision OCR 与 Apple 语言检测按推荐方案保留（决策点 A 用户未反对）；不动 quick link、HTTP Server、Markdown 渲染、Sparkle 等通用设施
- 歧义：无（决策点 A 采用计划默认推荐）

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：7ef6434311e01bfe6c29c66d800862daf4ade882（dev）
- 初始 staged 路径：无
- 初始 unstaged 路径：无
- 初始 untracked 路径：无
- 初始冲突：无
- Agent-owned paths：任务涉及的服务源码、测试、pbxproj、本地化、架构文档与同任务计划/history

## 目标与非目标

### 目标

- `QueryServiceFactory` 仅注册 `.youdao`
- 删除全部非有道服务目录（Swift/objc）、StreamService 体系、AI 服务与配置视图
- `EZEnumTypes` 仅保留 Youdao/Apple（Apple 仅作 OCR/检测内部服务类型）
- TTS 仅剩有道；OCR 仅剩 Apple Vision（默认）+ 有道（可选增强）
- 测试、本地化字符串、SPM 依赖（GoogleGenerativeAI、OpenAI 包）同步清理
- 静态验证通过（xcodebuild 在本环境不可用，见验证说明）

### 非目标

- 不移除 quick link（Google/Eudic/Apple Dictionary 外部跳转按钮）
- 不移除 HTTP Server（收敛后仅暴露有道）
- 不移除 Markdown 渲染（EZWordResultView 仍使用）
- 不改 appcast/发布脚本/README/user-docs 内容

## 工作计划

1. 服务注册收敛：`QueryServiceFactory`、`LocalStorage.defaultServiceTypeIDs`
2. 删除服务目录：`Easydict/Swift/Service/{Ali,Apple(翻译部分),Baidu,Bing,BuiltInAI,Caiyun,Claude,ClaudeCode,CodexCLI,CustomOpenAI,DeepL,DeepSeek,Dictionary,Doubao,Gemini,GitHub Models,Google,Groq,MiniMax,NiuTrans,Ollama,OpenAI,Tencent,Volcano,Zhipu,AITool}`；保留 Apple 内 OCR/语言检测；同步 pbxproj 与 SPM 包
3. StreamService 级联清理：GlobalContext、EZResultView.m、EZBaseQueryViewController.m、routes.swift、ActionManager 删除、菜单/快捷键清理
4. 设置页清理：GeneralTab 语言检测优化选择器、AdvancedTab Apple 离线翻译开关、ServiceConfigurationView 通用配置视图
5. objc 清理：EZEnumTypes、EZConstKey、EZSchemeParser、EZAudioPlayer、EZTitlebar、EZWebViewManager
6. 测试与字符串清理；pbxproj 引用脚本化处理（文件引用、构建文件、SPM 包、空 group）
7. 验证：swiftc -parse、plutil/jq、git diff --check、符号级残留扫描

## 风险与决策

- pbxproj 为 objectVersion 55 显式引用，删文件必须同步引用，采用脚本 + plutil/括号平衡校验
- AppleService 保留为内部 OCR/检测工具服务（不注册、不翻译），`EZServiceTypeApple` 常量保留
- `TTSServiceType` 枚举仅剩 `.youdao`；系统 TTS 兜底（NSSpeechSynthesizer）随 Apple TTS 一并移除
- 语言检测优化设置（baidu/google）整体移除，检测固定走 Apple 设备端检测
- 原 AppleDictionary 服务的系统词典单词判断能力提取为 `SystemDictionary`（基于 DictionaryKit），供文本分词使用

## 进度

- [x] Phase 1 服务注册收敛
- [x] Phase 2 服务目录删除与 pbxproj 同步
- [x] Phase 3 UI/配置清理
- [x] Phase 4 TTS/OCR 收敛
- [x] Phase 5 objc 分支清理
- [x] Phase 6 测试与字符串
- [x] 验证（静态；xcodebuild 未运行，见验证）
- [x] history + 归档 + 自动提交

## 验证

- `swiftc -parse` 全部剩余 Swift 源文件（含测试）：通过。
- `plutil -lint Easydict.xcodeproj/project.pbxproj`：通过；大括号/圆括号平衡为 0；无悬挂对象引用。
- `jq -e . Easydict/App/Localizable.xcstrings`：通过；移除 140 个失效 key 后代码引用 key 无缺失。
- `git diff --check`：通过。
- 符号级残留扫描（29 个服务类名、StreamService 体系、EZServiceType* 常量、语言检测优化、AI action）：无残留引用。
- `xcodebuild build/test`：**未运行**——当前环境未安装完整 Xcode（`xcode-select` 指向 CommandLineTools），构建验证状态为未验证。

## 完成条件

- 全部 Phase 完成、静态验证通过、计划归档 completed、同任务 history 完整、自动本地提交完成。
