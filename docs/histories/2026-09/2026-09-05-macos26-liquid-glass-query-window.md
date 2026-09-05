## 2026-09-05 | 任务：浮动查询弹框切换为 macOS 26 液态玻璃效果

### 用户请求

弹框切换为 macOS 26 的液态玻璃（Liquid Glass）效果。

### 变更

- `EZBaseQueryWindow`:
  - 引入 `#if __has_include(<AppKit/NSGlassEffectView.h>)` 与 `NSGlassEffectView.h`。
  - 在初始化时将窗口设为透明无边框阴影状态：`self.opaque = NO`，`self.backgroundColor = [NSColor clearColor]`，`self.hasShadow = YES`，移除原有的写死纯色背景逻辑。
  - 在 `setupUI` 中向 `themeView`（`self.contentView.superview`，即 `NSThemeFrame`）底层插入自适应全景效果底板：macOS 26.0+ 启用 `NSGlassEffectView`（样式为 `NSGlassEffectViewStyleRegular`，圆角为 16.0）；低版本系统自动回退为 `NSVisualEffectView`（材质为 `NSVisualEffectMaterialPopover`，圆角 16.0）。
  - 在 `EZBaseQueryWindow.h` 增加 `glassBackgroundView` 属性。
  - 修复标题栏挂载机制：不再挂载到可能被 AppKit 内部重组拆解的 `themeView.subviews.lastObject`（私有 `NSTitlebarContainerView`），而是将 `self.titleBar` 直接以 `positioned:NSWindowAbove relativeTo:nil` 添加到 `themeView` 顶层，并启用 `wantsLayer = YES`，通过 Masonry 顶部约束 `make.top.left.right.equalTo(themeView)` 与 `make.height.mas_equalTo(EZTitlebarHeight_28)` 牢固锚定在窗口最上层，解决液态玻璃启用后左上角钉住按钮（`pinButton`）脱落消失的问题。
- `EZTitlebar`:
  - 在 `setup` 中增加 `self.wantsLayer = YES`，确保标题栏在 Core Animation 图层树中明确置于背景效果层之上。
- `EZBaseQueryViewController`:
  - `loadView`: 将 `self.view` 背景改为透明，关闭 `masksToBounds`，使整窗外层液态玻璃圆角自然呈现。
  - `scrollView` & `tableView`: 背景色全部设为 `clearColor`，关闭 `drawsBackground`，使底层液态玻璃材质通透展现。
  - `updateWindowHeightWithLock:`: 动态调整窗口几何尺寸后显式调用 `[window invalidateShadow]`，保证阴影轮廓实时更新。
- `EZTableRowView`:
  - 确保行背景为透明，重写 `drawBackgroundInRect:` 为空实现，避免 AppKit 绘制默认纯色底色。
- `NSColor+MyColors`:
  - 增加微透磨砂浮岛卡片配色：`ez_glassCardBgLightColor`（48% 白）、`ez_glassCardBgDarkColor`（36% 黑）、`ez_glassTopBarBgLightColor`（25% 白）、`ez_glassTopBarBgDarkColor`（20% 黑）、`ez_glassBorderLightColor`（60% 白描边）、`ez_glassBorderDarkColor`（12% 白描边）。
- `EZQueryView` & `EZTextView`:
  - 输入框卡片切换为 `ez_glassCardBgLightColor` / `ez_glassCardBgDarkColor`，并配置 0.5px 微光描边。
  - `scrollView`、`textView` 与 `placeholderTextField` 背景统一置透（`drawsBackground = NO; backgroundColor = clearColor;`），让底层液态玻璃自然透入文字背景。
- `EZSelectLanguageCell`:
  - 语言栏切换为半透明 `ez_glassTopBarBgLightColor` / `ez_glassTopBarBgDarkColor`，配置 0.5px 微光描边。
- `EZResultView` & `EZWordResultView`:
  - 结果卡片背景切换为 `ez_glassCardBgLightColor` / `ez_glassCardBgDarkColor`，配置 0.5px 微光描边；顶部工具栏切换为 `ez_glassTopBarBgLightColor` / `ez_glassTopBarBgDarkColor`。
  - 词典结果视图 `EZWordResultView` 背景置为 `clearColor`，消除二次遮盖；`tagScrollView` 及标签容器背景置透。
  - `EZWebViewManager`：配置 `_webView.drawsBackground = NO`，JS 注入 body 背景为 `transparent`，支持 WebKit 页面全景玻璃透出。

### 设计意图

1. **全景液态玻璃与磨砂浮岛分层**：浮动窗底板采用 macOS 26 原生 Liquid Glass 材质；内部输入框与结果卡片打破原本生硬的实色色块阻隔，采用半透明微透材质与 0.5px 微光描边，既让底层液态玻璃的折射、流动与桌面高光自然透入文字区域，又通过适度衬底阻断壁纸高频杂讯，保持查词文字与翻译排版的极致清晰度。
2. **向下兼容与构建安全**：保持 Deployment Target 14.1/13.0，使用宏预编译与运行时版本判断双重保护，保证低版本 Xcode 与旧 macOS 环境均能安全编译与平稳降级运行。
3. **顶层稳定锚定**：摆脱对 AppKit 私有窗框子视图索引的脆弱依赖，避免系统在引入玻璃视图或隐藏系统三色按钮时重构内部容器导致自定义组件丢失。

### 验证

- `git diff --check`：通过，无多余空格或格式问题。
- `xcodebuild build`：构建成功。

### 受影响文件

- `Easydict/objc/Utility/EZCategory/NSColor+MyColors/NSColor+MyColors.h`
- `Easydict/objc/Utility/EZCategory/NSColor+MyColors/NSColor+MyColors.m`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.h`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.m`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryViewController.m`
- `Easydict/objc/ViewController/View/Titlebar/EZTitlebar.m`
- `Easydict/objc/ViewController/View/QueryView/EZQueryView.m`
- `Easydict/objc/ViewController/View/TextView/EZTextView.m`
- `Easydict/objc/ViewController/Cell/EZSelectLanguageCell.m`
- `Easydict/objc/ViewController/View/ResultView/EZResultView.m`
- `Easydict/objc/ViewController/View/WordResultView/EZWordResultView.m`
- `Easydict/objc/ViewController/View/WordResultView/EZWebViewManager.m`
- `Easydict/objc/ViewController/Cell/EZTableRowView.m`
- `docs/histories/2026-09/2026-09-05-macos26-liquid-glass-query-window.md`
