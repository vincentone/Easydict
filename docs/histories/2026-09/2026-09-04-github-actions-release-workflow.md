## 2026-09-04 | 任务：配置 GitHub Actions Release 自动打包工作流

### 用户请求

配置方式二：通过 GitHub Actions 实现当推送版本 Tag 或手动触发时，自动在云端打包 macOS 应用并发布到 GitHub Releases。

### 变更

- 新增并优化 `.github/workflows/release.yml`：
  - 触发机制：监听 `v*` 格式的 Git Tag 推送，同时支持 `workflow_dispatch` 手动输入 tag 触发。
  - 运行环境：升级为 `macos-15`，并显式配置 `xcode-select` 锁定 Xcode 16+ 工具链，满足 `Alamofire 5.12.0`、`swift-log 1.15.0` 等依赖包要求的 `swift-tools-version: 6.x` 解析需求。
  - 构建流程：通过 `xcodebuild archive` 导出 Release 归档包，注入 `CODE_SIGNING_ALLOWED=NO`、`CODE_SIGNING_REQUIRED=NO` 与 `EASYDICT_RELEASE_PACKAGING=YES` 绕过证书要求和代码检查脚本。
  - 签名兼容：对导出的 `Easydict.app` 进行 ad-hoc 签名（`codesign --force --deep -s -`），满足 Apple Silicon 系统启动限制。
  - 打包分发：利用 `ditto` 封装 `Easydict.zip`，通过系统内置 `hdiutil` 封装 `Easydict.dmg`，并生成 SHA256 校验清单 `sha256sums.txt`。
  - 发布交付：使用 `softprops/action-gh-release@v2` 自动创建 GitHub Release 并上传 dmg、zip 及校验文件作为产物附件。
  - 错误诊断：完善失败日志输出，自动提取 `xcodebuild.log` 中的错误行方便排查。

### 设计意图

为仓库提供开箱即用的云端打包方案，无需本地开发者证书即可在 GitHub 上直接生成可下载的 DMG 和 ZIP，解决 Swift 6 依赖包解析对 Xcode 16+ 的要求，同时支持安全校验与自动生成发布说明。

### 验证

- `git diff --check`：无多余空白字符。
- `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/release.yml")'`：YAML 语法解析验证通过。
- 确认 Swift 6 SPM 包依赖冲突根因（`macos-14` 默认 Xcode 15.4 无法解析 tools version 6.x），在工作流中升级至 `macos-15` 并自动选择 Xcode 16。
- 确认产物打包流程包含 ad-hoc 签名与动态应用路径检索。

### 受影响文件

- 新增：`.github/workflows/release.yml`
- 新增：`docs/histories/2026-09/2026-09-04-github-actions-release-workflow.md`
