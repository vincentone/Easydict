## 2026-09-05 | 任务：浮动查询弹框切换为 macOS 26 液态玻璃效果

### 用户请求

弹框切换为 macOS 26 的液态玻璃（Liquid Glass）效果。

### 变更

- `EZBaseQueryWindow`:
  - 引入 `#if __has_include(<AppKit/NSGlassEffectView.h>)` 与 `NSGlassEffectView.h`。
  - 在初始化时将窗口设为透明无边框阴影状态：`self.opaque = NO`，`self.backgroundColor = [NSColor clearColor]`，`self.hasShadow = YES`，移除原有的写死纯色背景逻辑。
  - 在 `setupUI` 中向 `themeView`（`self.contentView.superview`，即 `NSThemeFrame`）底层插入自适应全景效果底板：macOS 26.0+ 启用 `NSGlassEffectView`（样式为 `NSGlassEffectViewStyleRegular`，圆角为 16.0）；低版本系统自动回退为 `NSVisualEffectView`（材质为 `NSVisualEffectMaterialPopover`，圆角 16.0）。
  - 在 `EZBaseQueryWindow.h` 增加 `glassBackgroundView` 属性。
- `EZBaseQueryViewController`:
  - `loadView`: 将 `self.view` 背景改为透明，关闭 `masksToBounds`，使整窗外层液态玻璃圆角自然呈现。
  - `scrollView` & `tableView`: 背景色全部设为 `clearColor`，关闭 `drawsBackground`，使底层液态玻璃材质通透展现。
  - `updateWindowHeightWithLock:`: 动态调整窗口几何尺寸后显式调用 `[window invalidateShadow]`，保证阴影轮廓实时更新。
- `EZTableRowView`:
  - 确保行背景为透明，重写 `drawBackgroundInRect:` 为空实现，避免 AppKit 绘制默认纯色底色。

### 设计意图

1. **分层视觉设计**：浮动窗底板采用 macOS 26 原生 Liquid Glass 材质，标题栏区域与卡片边距自然融入背景；内部查词输入框（`EZQueryView`）与词典结果卡片（`EZResultView`）保留独立卡片底色与层级，确保查词文本与 WKWebView 渲染具备高对比度与字形清晰度。
2. **向下兼容与构建安全**：保持 Deployment Target 14.1/13.0，使用宏预编译与运行时版本判断双重保护，保证低版本 Xcode 与旧 macOS 环境均能安全编译与平稳降级运行。

### 验证

- `git diff --check`：通过，无多余空格或格式问题。
- `xcodebuild build`：构建成功。

### 受影响文件

- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.h`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.m`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryViewController.m`
- `Easydict/objc/ViewController/Cell/EZTableRowView.m`
- `docs/histories/2026-09/2026-09-05-macos26-liquid-glass-query-window.md`
