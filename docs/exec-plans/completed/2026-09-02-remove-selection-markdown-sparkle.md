# 删除划词翻译子系统、Markdown 渲染与 Sparkle 更新

- 状态：active
- 创建日期：2026-09-02
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户确认（选项均为推荐项）：
1. 划词翻译连功能一起删除（含设置、⌥D 快捷键、自动查询图标、SelectedTextKit）
2. Markdown 渲染设置删除（流式服务已删，功能已死）
3. 更新相关连 Sparkle 一起删除（设置页/主菜单/About/自动更新）

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 允许修改路径：`Easydict/`、`Easydict.xcodeproj/`、`Easydict.xcworkspace/`、
  `docs/exec-plans/`、`docs/histories/`
- 同任务 history：`docs/histories/2026-09/2026-09-02-remove-selection-markdown-sparkle.md`
- 禁止动作：push、pull、rebase、merge
- 验收标准：划词/Markdown/更新零残留；输入/粘贴板/截图 OCR/TTS/HTTP Server 保留；
  build/test 通过

## 语义与范围

- 保留：输入翻译、粘贴板翻译、截图 OCR（snip/静默/粘贴板 OCR/OCR 窗口）、TTS、
  查询文本自动处理三项设置（作用于输入管线）、selectQueryTextWhenWindowActivate、
  固定/迷你窗口、状态栏、HTTP Server（去掉 /selectedText 路由）
- 删除：EventMonitor 子系统、弹按钮窗口、强制取词、替换文本按钮、
  SelectedTextKit/AXSwift(传递)、Sparkle、Markdown 渲染、DisabledAppTab、
  AppTriggerConfig、MMEventMonitor、EZRightClickDetector
- 歧义：无（两个范围决策均已确认）

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：21c201cf（dev）
- 初始 staged：无；unstaged：无；untracked：本计划文件
- 初始冲突：无
- Agent-owned paths：本任务涉及全部删除/修改文件

## 工作计划

1. 删除 EventMonitor 目录、PopButtonWindow、EZRightClickDetector、MMEventMonitor
2. EZWindowManager 划词链路（selectTextTranslate/popButton/windowType）
3. SystemUtility（Selection/AX/Shortcut/FocusedElementInfo/Browser cases）+
   HTTPServer /selectedText
4. EZReplaceTextButton + showReplaceButton + 配置 wrapper/observer
5. 快捷键 selectTranslate/toggleAutoSelectText
6. 设置页：AdvancedTab 鼠标查询图标区 + 文本选择替换区、GeneralTab 三开关、
   DisabledAppTab、窗口类型 picker
7. Markdown 全链路；Sparkle 全链路；SelectedTextKit SPM
8. pbxproj 同步 + 字符串清理
9. build/test 验证

## 风险与决策

- 截图 OCR 有本地独立事件监听（Screenshot+EventMonitor），不受影响
- 老用户 UserDefaults 残留键为死数据，后续版本清理

## 进度

- [ ] 实施中

## 验证

- history 完成时填写。

## 完成条件

- 全部删除完成、验证通过、history 完整、自动本地提交完成。
