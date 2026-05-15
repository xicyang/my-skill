---
name: git-workflow-manager
description: 将 git 工作流规范写入项目 CLAUDE.md，让 agent 在整个项目生命周期中遵循一致的版本控制纪律。适用于新项目、已有项目补充 git 规范、或升级现有 git 规则。当用户提到"设置 git 规范"、"添加 git 工作流"、"初始化 git 管理"、"配置 git commit 规则"、"git 规范化"时使用，即使没有明确说"git workflow"也应触发。
---

# Git Workflow Manager

将 git 工作流规则写入项目的 CLAUDE.md，确保 agent 在每个 session 中遵循一致的版本控制纪律。

## 触发条件

- 新项目需要设置 git 规范
- 已有项目需要补充 git 工作流规则
- 已有项目需要升级/更新 git 规则
- 用户提到"git 规范"、"git 工作流"、"commit 规则"等关键词

## 执行步骤

### 步骤 1: 检查项目状态

1. 确认当前目录是否为 git 仓库（`git status`）
2. 检查项目 CLAUDE.md 是否存在
3. 如果 CLAUDE.md 存在，检查是否已有 `## Git 工作流规则` section
4. 扫描项目目录结构，识别项目类型（Python/Node/Go 等）

### 步骤 2: 扫描需要 .gitignore 的内容

根据项目类型和目录结构，识别需要加入 .gitignore 的文件/目录：

- 依赖/环境目录: node_modules, .venv, venv, __pycache__, dist, build, .next, target, vendor, Pods
- 模型权重/数据集: *.pt, *.pth, *.bin, data/, datasets/, models/
- IDE/editor: .idea, .vscode
- 环境变量/密钥: .env, .env.local, .env.*.local, credentials
- OS: .DS_Store, Thumbs.db
- 编译产物/二进制: *.o, *.so, *.exe, *.dll

按文件**类型**判断，不按大小阈值。

### 步骤 3: 生成 CLAUDE.md 内容

根据扫描结果和项目类型，生成以下规则文本（根据项目实际情况调整 .gitignore 部分）：

```markdown
## Git 工作流规则

### 责任边界
- **用户负责**: git init、远程仓库设置、push 决策、branch 主动决策
- **agent 负责**: staging、committing、.gitignore 维护、commit 整理
- **agent 按需执行**: branch 创建与合并 — 仅当用户明确要求时

### Commit 规则
1. 每完成一个语义单元后 commit，语义单元 = 所有服务于同一个"为什么"的改动
2. 只 commit 已确认可运行或已确认修复目标 bug 的代码（agent 自行验证或用户确认）
3. Commit 格式: `type(scope): 中文描述`
   - type: feat, fix, refactor, docs, style, test, chore
   - scope: 可选，标明影响模块
   - 描述: 中文，简明扼要
   - 示例: `feat(auth): 添加JWT验证`, `fix: 修正超时处理`
4. 一次用户请求中产生多个 commit 时，在任务结束后整理：
   - 过程性 commit（修正拼写、调试尝试、WIP checkpoint）squash 进对应的语义 commit
   - 语义性 commit（独立功能增量）保留
   - 操作方式: `git reset --soft` 到语义 commit 前，重新 commit

### .gitignore 规则
每次 commit 前（`git add` 之前）检查是否有新出现的大文件/目录需要忽略：
[此处根据项目扫描结果填入具体的 .gitignore 条目]

### Branch 规则（仅用户要求时执行）
- 策略: GitHub Flow — main + feature branches
- 命名: `feat/xxx`, `fix/xxx`, `refactor/xxx`, `docs/xxx`
- agent 不自主创建或合并 branch，仅在用户明确要求时操作

### Push 规则
- agent 不自动 push，push 由用户决定
```

### 步骤 4: 写入 CLAUDE.md

- 已有 `## Git 工作流规则` section → 更新替换该 section
- CLAUDE.md 存在但无 git 规则 → 用 `---` 分隔后追加
- CLAUDE.md 不存在 → 创建新文件

### 步骤 5: 生成/更新 .gitignore

根据步骤 2 的扫描结果，在项目根目录创建或更新 .gitignore。

### 步骤 6: 验证

1. 确认 CLAUDE.md 中规则正确写入
2. 确认 .gitignore 内容正确
3. 向用户汇报完成情况，列出写入的规则概要