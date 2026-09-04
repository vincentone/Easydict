## 2026-09-04 | 任务：配置 GitHub Actions Release 自动打包工作流

### 用户请求

配置方式二：通过 GitHub Actions 实现当推送版本 Tag 或手动触发时，自动在云端打包 macOS 应用并发布到 GitHub Releases。

### 变更

- 新增 `.github/workflows/release.yml`：
  - 触发机制：监听 `v*` 格式的 Git Tag 推送，同时支持 `workflow_dispatch` 手动输入 tag 触发。
  - 运行环境：使用 `macos-14`（Apple Silicon runner）。
  - 构建流程：通过 `xcodebuild archive` 导出无签名的 Release 归档包。
  - 打包分发：利用 `ditto` 封装 `Easydict.zip`，通过系统内置 `hdiutil` 封装 `Easydict.dmg`，并生成 SHA256 校验清单 `sha256sums.txt`。
  - 发布交付：使用 `softprops/action-gh-release@v2` 自动创建 GitHub Release 并上传 dmg、zip 及校验文件作为产物附件。

### 设计意图

为仓库提供开箱即用的云端打包方案，无需本地开发者证书即可在 GitHub 上直接生成可下载的 DMG 和 ZIP，同时支持安全校验与自动生成发布说明。

### 验证

- `git diff --check`：无多余空白字符。
- `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/release.yml")'`：YAML 语法解析验证通过。
- 本地预先验证 `xcodebuild archive` 参数组合，通过 `EASYDICT_RELEASE_PACKAGING=YES` 跳过格式化/Lint 脚本并使用 `CODE_SIGN_IDENTITY="-"` 适配 CocoaPods 脚本，避免云端 exit code 74 失败。

### 受影响文件

- 新增：`.github/workflows/release.yml`
- 新增：`docs/histories/2026-09/2026-09-04-github-actions-release-workflow.md`
