# 设置页大瘦身：删服务配置/精简快捷键/删高级-隐私-关于

- 状态：completed
- 创建日期：2026-09-02
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户要求：
1. 删除整个服务（Service）设置及其相关逻辑（已有道单服务，无需配置）
2. 快捷键设置只保留「输入翻译」一个快捷键
3. 高级设置仅把「窗口管理」（侧悬浮窗口位置/固定置顶/最大高度）挪到通用，其余删除
4. 删除隐私、关于设置及其相关逻辑

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 允许修改路径：`Easydict/`、`EasydictTests/`、`Easydict.xcodeproj/`、
  `Easydict.xcworkspace/`、`docs/exec-plans/`、`docs/histories/`
- 同任务 history：`docs/histories/2026-09/2026-09-02-settings-slim-down.md`
- 禁止动作：push、pull、rebase、merge
- 验收标准：设置仅剩 通用（含窗口管理）/收藏/快捷键（仅输入翻译）；服务配置、
  HTTP Server、分析统计（Firebase/Sentry）、About/Acknow、Privacy 全部移除；
  build/test 通过

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：8c39a34f（dev）
- 初始 unstaged：Localizable.xcstrings 格式噪声
- Agent-owned paths：设置页全部相关文件、服务配置层、分析统计、Vapor、pbxproj 等

## 工作计划

1. 删服务配置层：ServiceTab/ServiceTabListViews/ServiceConfigurationView/
   WindowConfigurationView/QueryServiceFactory/QueryServiceConfiguration/
   ServiceUsageStatus/ServiceConfigurationKey/ServiceTests + LocalStorage 服务 API；
   EZBaseQueryViewController latestServices 直返 YoudaoService；EZAudioPlayer/
   EZWordResultView TTS 直用 YoudaoService；EZSchemeParser 白名单简化
2. 快捷键：ShortcutAction 仅 inputTranslate；删 MainMenuShortcutCommand；
   ShortcutManager+Default/KeyHolderWrapper 仅 inputShortcut
3. 高级：窗口管理三设置挪 General；删 AdvancedTab 及 beta/tips/文言文长度/
   文本处理开关与 handleInputText 配置逻辑、HTTP Server(Vapor) 全家族
4. 隐私/关于：删 PrivacyTab/AboutTab/HostWindowManager/AcknowList/
   AnalyticsService/Firebase/Sentry/allowCrashLog/allowAnalytics 及日志调用
5. 字符串/pbxproj/Package.resolved 清理；build/test 验证

## 风险与决策

- QueryService 基类保留（有道服务与结果 UI 仍依赖），仅剥离配置项
- 收藏/历史（QueryRecordManager）未提及，保留
- allowCrashLog/allowAnalytics 与 AnalyticsService/Firebase/Sentry 一并删除
  （隐私页相关逻辑）；MMCrash 本地崩溃兜底保留

## 进度

- [x] 全部完成

## 验证

- 见 history。

## 完成条件

- 全部步骤完成、验证通过、history 完整、自动本地提交完成。
