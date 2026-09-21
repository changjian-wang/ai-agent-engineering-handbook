# AI 与 Agent 工程手册

以 AI 基础与大模型原理为主线，系统整理训练、推理、评测和应用知识；Agent 独立并行学习。内容同时服务理解、实践与面试，不以框架调用代替原理。

站点地址：[AI 与 Agent 工程手册](https://changjian-wang.github.io/ai-agent-engineering-handbook/)（首次成功部署后生效）。

## 当前内容

- [学习首页](index.md)：AI 优先的学习顺序和真实章节状态。
- [完整知识目录](roadmap.md)：M00–M13，共 14 个模块及其验收目标。
- [原文覆盖与资料核验](coverage.md)：重新核对 17 张图，登记 45 条来源映射、9 项补充范围与全文缺口；映射条目可能交叉。
- [M00：LLM 概念](chapters/00-ai-foundations.md)：按原文的预训练模型、语言模型概率定义和 Prefix/Causal LM 整理，附模型对照与掩码表。
- [M01：前置知识](chapters/01-math-and-programming.md)：按原文的 Python、PyTorch、线性代数、概率论、微积分展开；进阶补充单独折叠，保留 [CPU 实验与 11 个测试](examples/m01/math_basics.py)。

M00、M01 已成稿，M02–M13 正文仍在规划中。没有取得微信标题所称的完整 48 页资料，不宣称逐页复现或已经完成全部知识整理。

正文以知识点和问题为单位，先给定义，再说明模型中的用途与关键区别。原文确定主题，论文和官方文档校正技术事实；不照搬截图、未经核验的绝对化说法或过期代码。

## 本地构建与预览

站点使用 Jekyll 4.4、Ruby 3.3 和锁定的 Gem 依赖。校验器通过 Nokogiri 解析生成的 HTML，检查站内路径、锚点、图片、页面结构和发布文件边界，不用正则代替 HTML 解析。

已有 Ruby 3.3 环境时，在仓库根目录运行：

```sh
bundle install
bundle exec jekyll build --trace
bundle exec ruby scripts/check_site.rb
bundle exec jekyll serve --host 127.0.0.1 --port 4174
```

预览地址：<http://127.0.0.1:4174/ai-agent-engineering-handbook/>。

Windows 没有 Ruby 时，可用已经启动的 Docker Desktop，在 PowerShell 中执行：

```powershell
Set-Location C:\github\ai-agent-engineering-handbook
docker run --rm --mount "type=bind,source=$PWD,target=/site" --mount type=volume,source=ai-handbook-bundle,target=/usr/local/bundle --workdir /site ruby:3.3 bundle install
docker run --rm --mount "type=bind,source=$PWD,target=/site" --mount type=volume,source=ai-handbook-bundle,target=/usr/local/bundle --workdir /site ruby:3.3 bundle exec jekyll build --trace
docker run --rm --mount "type=bind,source=$PWD,target=/site" --mount type=volume,source=ai-handbook-bundle,target=/usr/local/bundle --workdir /site ruby:3.3 bundle exec ruby scripts/check_site.rb
docker run --rm -p 127.0.0.1:4174:4000 --mount "type=bind,source=$PWD,target=/site" --mount type=volume,source=ai-handbook-bundle,target=/usr/local/bundle --workdir /site ruby:3.3 bundle exec jekyll serve --host 0.0.0.0 --port 4000 --no-watch
```

Docker 的 `--no-watch` 预览不会自动重建。修改正文后重新执行构建命令，再刷新页面；若 4174 端口被占用，换一个本地端口。

概念图是本仓库原创 PNG。可在 Windows PowerShell 中运行 [生成脚本](scripts/render-diagram.ps1) 重新生成；日常构建直接使用已提交的图片，不需要 Windows 图形库。

## 发布

M01 实验在 Python 3.11 虚拟环境中安装 [固定直接依赖](examples/m01/requirements.txt)，通过 `python examples/m01/math_basics.py` 运行。Windows/Linux 的 CPU 安装命令、真实验证记录与数据范围见 [M01 正文](chapters/01-math-and-programming.md)。实验源码、虚拟环境和缓存不会进入 Pages 产物。

数学章节通过 `math: true` 启用 KaTeX 0.18.7，使用带完整性校验的固定版本 CDN 资源；其他页面不加载。CDN 不可访问时公式可能保留 TeX 文本，正文与实验本身不依赖该网络服务。

[发布工作流](.github/workflows/deploy-pages.yml)在 Pull Request 上运行 CPU 实验、构建和校验；推送到 `main` 或在 `main` 手动运行时，实验与站点校验均通过后才部署。

首次发布需将仓库 Settings → Pages → Source 设为 **GitHub Actions**。只上传生成的站点，不上传依赖、脚本或仓库配置。线上 URL 的项目路径由 [站点配置](_config.yml)中的 `baseurl` 决定。

GitHub Skills 原课程流程保留作历史参考，但已移除自动触发并禁用入口任务，避免重写首页或仓库说明。它们不是本站发布入口。

## 内容维护

1. 先把知识点加入覆盖表和目录，明确来自原文还是本手册补充。
2. 新章节放在 `chapters/`，使用 `layout`、`title`、`description`、`permalink`、`chapter`、`last_verified` 元数据。
3. 正文包括核心问题、先修知识、原理、例子、边界、误区、自测与参考答案。
4. 关键判断优先查论文、官方文档或官方实现；记录论文版本或页面核验日期。
5. 未运行的实验、未核实的结论和规划章节明确标记，不编造服务响应、评测数字或完成状态。
6. 构建、链接、图片及桌面/手机阅读检查通过后，再更新章节状态并发布。

仓库原有 [LICENSE](LICENSE) 保留。外部论文、文档及原文图片仍遵守各自许可，引用链接不等于获得整套转载授权。

