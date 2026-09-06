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

---

## 2026-09-06 | 第二轮：内层文字卡片升级为第二层真玻璃（对齐 ai-usage-menubar）

### 用户请求

参考 vincentone/ai-usage-menubar 的双层玻璃结构（系统 `NSPopover` 液态玻璃 + 每个 section 卡片 `.glassEffect(.regular, in: .rect(cornerRadius: 18))`，卡片包在 `GlassEffectContainer(spacing: 10)` 中），把浮动弹框内层文字背景改成一样的真玻璃。

### 变更

- `EZConst.h`: 新增 `EZCornerRadius_12` / `EZCornerRadius_18` / `EZCornerRadius_22`。
- 新增 `NSView+EZGlassCard` 分类：`ez_addGlassBackgroundWithStyle:cornerRadius:` 封装 `#if __has_include(<AppKit/NSGlassEffectView.h>)` 与 `@available(macOS 26.0, *)` 双重保护，创建 `NSGlassEffectView` 铺满自身并以 `positioned:NSWindowBelow` + Masonry 四边约束置于内容底层；条件不满足返回 `nil` 供调用方回退。头文件以自定义 `EZGlassStyle` 枚举镜像系统 `NSGlassEffectViewStyle` 原始值，保证旧 SDK 可编译。
- `EZBaseQueryWindow`：macOS 26 分支窗口玻璃底板圆角 16 → 22；`NSVisualEffectView` 回退分支保持 16 不变。
- `EZQueryView`：输入框卡片在 macOS 26+ 改为 Regular 玻璃卡片（圆角 18），不再设置 layer 半透明底色与 0.5px 描边；旧系统保留原有半透明 CALayer 卡片。
- `EZResultView`：结果卡片同上（Regular 玻璃、圆角 18）；`topBarView` 在玻璃模式下去掉半透明底色条，改为底部 0.5pt 分隔线（沿用 `ez_glassBorder*` 颜色），点击手势与布局锚点不变；旧系统保留原有样式。
- `EZSelectLanguageCell`：语言栏在 macOS 26+ 改为 Clear 玻璃（`NSGlassEffectViewStyleClear`，圆角 12）；旧系统保留半透明描边样式。
- `Easydict.xcodeproj/project.pbxproj`：注册新分类文件到 Easydict target。

### 设计意图

1. **双层真玻璃**：对齐参考应用——窗口底板玻璃之上，每张文字卡片再嵌一层真实 `NSGlassEffectView`（AppKit 版 `.glassEffect(.regular)`），形成层间折射与边缘高光，替代此前"半透明色块模拟浮岛"的做法。
2. **内容直接坐玻璃**：结果卡顶栏不再垫色条，仅保留 0.5pt 分隔线；语言栏用 Clear 玻璃制造层次差。
3. **向下兼容**：低版本系统完整保留第一轮半透明 CALayer 方案；`EZGlassStyle` 枚举隔离 SDK 差异。

### 明确不做

- 不引入 `NSGlassEffectContainerView`（AppKit 版 `GlassEffectContainer`）：卡片分散于 tableView 各 row，重构滚动层级风险大且仅为渲染合并优化。
- 不动 `EZWordResultView`、tag/model 小按钮、WebView 透明逻辑、`intercellSpacing` 与旧系统回退样式。

### 验证

- `git diff --check`：通过。
- `xcodebuild build`（Easydict scheme，外部临时 DerivedData）：构建成功。
- 运行 debug 版目测：URL scheme（`easydict://query?text=`）唤出浮动窗口，浅色模式下输入框卡片、Clear 语言栏、结果卡片与 topBar 0.5pt 分隔线均正确渲染，窗口底板圆角 22 生效；切换系统深色模式后重新查询，全套卡片稳定为深色玻璃 + 浅色文字，无回归。验证后已恢复系统浅色外观。已知非缺陷：系统外观切换瞬间 WebView 词典内容存在过渡态混排，重新查询后恢复稳定。

### 受影响文件（第二轮）

- `Easydict/App/EZConst.h`
- `Easydict/objc/Utility/EZCategory/NSView+EZGlassCard/NSView+EZGlassCard.h`（新增）
- `Easydict/objc/Utility/EZCategory/NSView+EZGlassCard/NSView+EZGlassCard.m`（新增）
- `Easydict.xcodeproj/project.pbxproj`
- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.m`
- `Easydict/objc/ViewController/View/QueryView/EZQueryView.m`
- `Easydict/objc/ViewController/View/ResultView/EZResultView.m`
- `Easydict/objc/ViewController/Cell/EZSelectLanguageCell.m`
- `docs/histories/2026-09/2026-09-05-macos26-liquid-glass-query-window.md`

---

## 2026-09-06 | 第三轮：窗口背景玻璃 Regular → Clear

### 用户请求

用户观察到浮动弹框顶部图钉行和底部留白露出一层白色，询问实现情况。确认那是窗口级 `NSGlassEffectView`（Regular）在浅色模式的亮白霜层——中间区域被卡片玻璃二次叠加显得更深，顶部/底部裸露区只有单层玻璃所以更白。用户选择把窗口背景玻璃改透。

### 变更

- `EZBaseQueryWindow.m`（`setupGlassEffectInView:`）：macOS 26 分支窗口底板 `glassView.style` 由 `NSGlassEffectViewStyleRegular` 改为 `NSGlassEffectViewStyleClear`；圆角 22 与低版本 `NSVisualEffectView` 回退分支不动；卡片（Regular）与语言栏（Clear）样式不动。

### 受影响文件（第三轮）

- `Easydict/objc/ViewController/Window/BaseQueryWindow/EZBaseQueryWindow.m`
- `docs/histories/2026-09/2026-09-05-macos26-liquid-glass-query-window.md`
