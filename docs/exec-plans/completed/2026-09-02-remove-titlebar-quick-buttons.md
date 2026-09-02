# 删除弹框右上角四按钮与设置页失效逻辑

- 状态：active
- 创建日期：2026-09-02
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户要求：删除翻译弹框右上角四个按钮（快捷操作 ⚙️、Google、Apple 词典、Eudic）
及其相关逻辑；设置页清理已不存在功能的配置项；仅保留核心有道翻译弹框。
计划已获用户确认。

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 目标结果：titlebar 仅剩 pinButton；快捷键/设置开关/通知链/常量/字符串同步删除
- 允许修改路径：`Easydict/`、`docs/exec-plans/`、`docs/histories/`
- 同任务 history：`docs/histories/2026-09/2026-09-02-remove-titlebar-quick-buttons.md`
- 禁止动作：push、pull、rebase、merge
- 预期交付物：构建通过 + history + completed 计划
- 验收标准：弹框仅剩 pin 按钮；设置无失效项；build/test 通过

## 语义与范围

- 用户要求：按已确认计划实施（两轮既往修改为清理参照）
- 否定与范围限制：保留 pinButton、结果视图底部有道链接按钮、EZOpenLinkButton 类、
  全局划词/OCR/HTTP server 等存活功能；删除 ⚙️ 菜单含添加收藏入口（用户知悉）
- 歧义：无

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：656351e969e45105f70dd8a5d6018fdf57e33a09（dev）
- 初始 staged：无
- 初始 unstaged：`Easydict/App/Localizable.xcstrings`（Xcode 构建自动重排格式，
  随本任务一并提交）
- 初始 untracked：本计划文件
- 初始冲突：无
- Agent-owned paths：EZTitlebar.h/.m、EZBaseQueryViewController.m、EZOpenLinkButton.h/.m、
  ShortcutAction.swift、KeyHolderWrapper.swift、MainMenuShortcutCommand.swift、
  Defaults.Keys+Extension.swift、MyConfiguration.swift、GeneralTab.swift、
  Notification+Name.swift、EZConst.h、pbxproj（如有）、Localizable.xcstrings、history

## 目标与非目标

### 目标

- EZTitlebar 仅剩 pinButton；四按钮相关快捷键、设置开关、通知、常量、字符串全删
- 设置页无失效配置项
- xcodebuild build/test 通过

### 非目标

- 不动全局快捷键体系其余 action、不动结果视图底部有道链接、不动 Service/About 等 tab

## 工作计划

1. EZTitlebar 瘦身（属性/方法/菜单/通知观察者）+ EZBaseQueryViewController 赋值处
2. 快捷键链路：ShortcutAction、KeyHolderWrapper、MainMenuShortcutCommand、
   Defaults keys、MyConfiguration wrapper/observeKeys
3. 设置页 quick link 分区 + Defaults keys + MyConfiguration observers +
   linkButtonUpdated 通知链 + EZConst 常量
4. EZOpenLinkButton 死分支与 URL scheme 常量；字符串逐 key 确认后清理
5. 设置页全面复查（对照存活功能）
6. xcodebuild build/test 验证

## 风险与决策

- ⚙️ 菜单的添加收藏/文本处理入口删除为用户确认范围；文本处理自动模式仍生效
- EZGoogleWebSearchURL 分支仅 Google 按钮使用，随按钮删除

## 进度

- [ ] Phase 1-4 实施
- [ ] 验证
- [ ] history + 归档 + 自动提交

## 验证

- history 完成时填写。

## 完成条件

- 全部步骤完成、验证通过、history 完整、自动本地提交完成。
