# AI 与 Agent 工程手册

以 AI 基础与大模型原理为主线，系统整理训练、推理、评测和应用知识；Agent 独立并行学习。内容同时服务理解、实践与面试，不以框架调用代替原理。

线上地址：[AI 与 Agent 工程手册](https://changjian-wang.github.io/ai-agent-engineering-handbook/)。本轮目录重编仅在本地，未提交、推送或更新线上站点。

## 当前内容

- [学习首页](index.md)：从 AI 基本认识入手，区分主线与并行线。
- [学习目录草案](roadmap.md)：AI00–AI14 与 AG00–AG09 的六个学习阶段、先修关系、核心与进阶范围、主读章节、面试主题索引及待补缺口。
- [AI00.1 试写稿](chapters/ai00-1-ai-ml-dl.md)：AI、机器学习、表示学习与深度学习的关系，关键判断均标注 D2L、《Deep Learning》或 McCarthy 的出处，待审阅。

2026-09-23 经确认清空旧正文、三篇导读、旧覆盖表及配套实验与概念图，保留站点框架和 Git 历史。目前有目录草案和 AI00.1 试写稿，其余章节正文待写，不把规划或资料链接标记为已完成课程。

清理前的 33 个源文件已备份至仓库外，并逐文件核对 SHA-256。备份包含未提交的三篇样稿，不包含可重新生成的依赖和缓存。恢复位置为 `C:\github\ai-agent-engineering-handbook-backups\before-content-reset-20260923-103015.zip`；恢复时应选择需要的文件，避免覆盖后续工作。该归档不进入 Git 或 Pages。2026-09-24 审查修订前的目录草案另存于 `C:\github\ai-agent-engineering-handbook-backups\curriculum-draft-before-review-20260924-145937`。

学习顺序以先修关系为依据：《动手学深度学习》补基础，Happy-LLM 串起模型原理，EasyRL 补强化学习基础，Hello-Agents 为并行线，其他资料按主题补充。面试题附在相应知识点后。完成目录审阅后，才从 AI00 的小节开始编写正文。

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

## 发布

目录阶段没有配套实验任务；旧实验已经移除。后续新增可运行示例时，应同时恢复对应 CI 测试门禁，再声明实验已验证。

数学章节通过 `math: true` 启用 KaTeX 0.18.7，使用带完整性校验的固定版本 CDN 资源；其他页面不加载。CDN 不可访问时公式可能保留 TeX 文本，正文与实验本身不依赖该网络服务。

[发布工作流](.github/workflows/deploy-pages.yml)在 Pull Request 上运行构建和站点校验；推送到 `main` 或在 `main` 手动运行时，构建及校验通过后才部署。当前没有执行提交或发布。

首次发布需将仓库 Settings → Pages → Source 设为 **GitHub Actions**。只上传生成的站点，不上传依赖、脚本或仓库配置。线上 URL 的项目路径由 [站点配置](_config.yml)中的 `baseurl` 决定。

GitHub Skills 原课程流程保留作历史参考，但已移除自动触发并禁用入口任务，避免重写首页或仓库说明。它们不是本站发布入口。

## 内容维护

1. 先审阅目录和资料映射，再确定每篇小节的范围；不要直接批量生成正文。
2. 按先修关系安排内容；进阶推导、框架 API 与生产优化不挤进入门解释。
3. 正文包含核心问题、先修、解释、例子、边界、自测及来源；每个主题只选一份主读资料。
4. 关键判断查论文、官方文档或实现，记录版本和核验日期；未知内容先列为资料缺口。
5. 未运行实验与未完成内容明确标记，不编造结果或完成状态。
6. 校验器在目录阶段要求两页、八个目录分区和 25 个模块锚点，检查每个模块按先修、核心、进阶、主读、验收五项编写，并拒绝六个已撤下页面残留；新增章节时同步更新规则和测试。
7. 构建、链接及桌面/手机阅读检查通过后，再考虑提交与发布。

仓库原有 [LICENSE](LICENSE) 保留。外部论文、文档及原文图片仍遵守各自许可，引用链接不等于获得整套转载授权。

