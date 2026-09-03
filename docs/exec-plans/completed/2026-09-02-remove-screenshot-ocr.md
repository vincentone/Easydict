# 删除截图翻译与图片 OCR 全家族

- 状态：completed
- 创建日期：2026-09-02
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户要求：截图翻译的功能及设置全部删除。覆盖：截图翻译（⌥S）、静默截图 OCR
（⌥⇧S）、截图 OCR 窗口、粘贴板 OCR、有道 OCR 开关、OCR 设置区及全部相关逻辑。
前一轮检查确认 autoQueryOCRText/autoCopyOCRText 属于 OCR 家族随本任务删除；
selectQueryTextWhenWindowActivate 作用于输入翻译窗口，保留。

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 允许修改路径：`Easydict/`、`EasydictTests/`、`Easydict.xcodeproj/`、
  `Easydict.xcworkspace/`、`docs/exec-plans/`、`docs/histories/`
- 同任务 history：`docs/histories/2026-09/2026-09-02-remove-screenshot-ocr.md`
- 禁止动作：push、pull、rebase、merge
- 验收标准：OCR/截图零残留；输入/粘贴板翻译、TTS、语言检测保留；build/test 通过

## 语义与范围

- 删除：Feature/Screenshot、AppleOCREngine(27 文件)、Youdao OCR、EZOCRResult、
  String+OCR、NSImage+ImageFormat/Export、OCR 测试与资源、五个 OCR/截图快捷键、
  OCR 设置区、相关 Defaults key/observer/字符串、HTTP `/ocr` 路由
- 保留：输入翻译、粘贴板翻译（文本）、TTS、语言检测（DetectManager/Apple 检测）、
  selectQueryTextWhenWindowActivate、HTTP Server 其余路由

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：21c201cf（dev）
- 初始 staged/unstaged：无（xcstrings 格式噪声随任务）
- 初始冲突：无
- Agent-owned paths：全部 OCR/截图相关删除与修改文件

## 目标与非目标

### 目标

- OCR/截图零残留；build/test 通过；历史与计划归档

### 非目标

- 不动输入/粘贴板翻译、TTS、有道词典结果、状态栏、其余设置

## 工作计划

1. 删除 Screenshot/AppleOCREngine/Youdao OCR/EZOCRResult/测试与资源
2. EZWindowManager、EZBaseQueryViewController、EZQueryView、EZEnumTypes、
   QueryModel、QueryService、AppleService、AppleLanguageMapper、YoudaoService、
   DetectManager、routes、ShortcutAction/keys、MyConfiguration/Defaults、
   GeneralTab/AdvancedTab、PrefixHeader/Bridging Header 跟随清理
3. pbxproj 同步 + 字符串清理
4. build/test 验证

## 风险与决策

- AppleLanguageDetector 依赖原 String+OCR 的 wordComponents/englishWordCount，
  以私有扩展形式补回至该文件
- 静默截图 OCR 复制行为随功能删除（用户确认删全家）

## 进度

- [x] 全部完成

## 验证

- `xcodebuild build`：BUILD SUCCEEDED。
- `xcodebuild test`：138 用例，失败仅剩系统时序/环境 flake（AppleScript、提示音量、
  超时边界，单独复跑通过），无功能性失败。
- `plutil -lint`、`jq`、`swiftc -parse`、`git diff --check`：通过。
- 符号残留扫描（OCR/Screenshot/snip/pasteboardOCR/AppleOCREngine/EZOCRResult）：无残留。

## 完成条件

- 全部步骤完成、验证通过、history 完整、自动本地提交完成。
