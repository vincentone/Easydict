# 只保留侧悬浮窗口（删除迷你/主窗口）

- 状态：completed
- 创建日期：2026-09-02
- 负责人：Agent
- 关联 Issue/PR：none

## 背景

用户只需要侧悬浮窗口。排查确认：迷你窗口已不可达（显示迷你窗口入口已被改为
打开侧悬浮窗）、主窗口仅启动时可能显示。确认删除迷你/主窗口及全部相关逻辑。

## 任务摘要

- 意图模式：implementation
- 交付授权：auto-local-commit
- 安全状态：normal
- 允许修改路径：`Easydict/`、`EasydictTests/`、`Easydict.xcodeproj/`、
  `docs/exec-plans/`、`docs/histories/`
- 同任务 history：`docs/histories/2026-09/2026-09-02-remove-mini-main-windows.md`
- 禁止动作：push、pull、rebase、merge
- 验收标准：仅剩侧悬浮窗口；build/test 通过；服务配置收敛 fixed

## 写入前状态

- 写入前检查：pass
- 自动提交资格：eligible
- 初始 HEAD：e5d5bd0f（dev）
- 初始 unstaged：Localizable.xcstrings 格式噪声（随任务提交）
- Agent-owned paths：窗口类删除、EZWindowType 收敛、EZWindowManager/AppDelegate/
  设置页/LocalStorage 等跟随文件

## 工作计划

1. 删 MiniQueryWindow/MainQueryWindow；EZWindowType 枚举收敛 None/Fixed
2. EZWindowManager/AppDelegate 主/迷你窗口链路清理
3. ⌥F 显示迷你窗口快捷键删除；设置 picker/开关清理
4. LocalStorage/服务配置/调用点收敛 fixed
5. 字符串 + pbxproj；build/test 验证

## 风险与决策

- 老用户 mini/main 的服务启用配置为死数据，统一以 fixed 为准
- applicationShouldHandleReopen 不再显示主窗口（菜单栏应用行为）

## 进度

- [x] 全部完成

## 验证

- 见 history。

## 完成条件

- 全部步骤完成、验证通过、history 完整、自动本地提交完成。
