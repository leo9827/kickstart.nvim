# 插件分类说明 / Plugin Categories

本配置按功能将插件分为以下 10 个类别，便于管理和查找。

---

## 📂 分类目录 / Category Structure

### 1. 🔀 Git 相关 / Git (4 plugins)

Git 版本控制相关的插件

- **lazygit.lua** - LazyGit 集成，完整的 Git UI 界面
- **diffview.lua** - VSCode 风格的 Diff 查看器，查看改动和历史
- **git-blame.lua** - 在行尾显示 Git Blame 信息
- **octo.lua** - GitHub PR/Issue 管理工具

**使用场景**: Git 提交、查看改动、代码审查、PR 管理

---

### 2. 🎨 UI 增强 / UI Enhancement (8 plugins)

界面美化和用户体验优化

- **alpha-nvim.lua** - 启动页面，显示快捷入口
- **lualine.lua** - 状态栏美化，显示文件信息和状态
- **noice.lua** - 命令行和通知界面美化
- **bufferline.lua** - Buffer 标签栏显示
- **dressing.lua** - 输入和选择界面美化
- **auto-dark-mode.lua** - 自动切换亮色/暗色主题
- **neoscroll.lua** - 平滑滚动效果
- **zenmode.lua** - 专注模式，隐藏干扰元素

**使用场景**: 美化界面、提升视觉体验、专注编码

---

### 3. 🧭 导航 / Navigation (6 plugins)

代码和文件导航工具

- **aerial-nvim.lua** - 代码大纲，显示函数/类结构
- **harpoon.lua** - 文件快速标记和跳转
- **flash-nvim.lua** - 光标快速跳转到任意位置
- **dropbar.lua** - 面包屑导航栏
- **nvim-navic.lua** - 显示当前代码上下文
- **oil-nvim.lua** - 文件管理器，类似 Vim buffer 的文件操作

**使用场景**: 快速定位代码、在文件间跳转、浏览项目结构

---

### 4. ✏️ 编辑增强 / Editing (5 plugins)

提升编辑效率的工具

- **nvim-surround.lua** - 快速添加/修改/删除包围符号（引号、括号等）
- **nvim-ufo.lua** - 增强的代码折叠功能
- **refactoring.lua** - 代码重构工具（提取函数、变量等）
- **hardtime.lua** - Vim 编辑习惯训练工具
- **undotree.lua** - 可视化撤销历史树

**使用场景**: 代码重构、快速编辑、撤销管理

---

### 5. 🤖 AI 工具 / AI Tools (2 plugins)

AI 辅助编程工具

- **copilot.lua** - GitHub Copilot 代码补全
- **avante-nvim.lua** - AI 对话助手

**使用场景**: AI 代码补全、AI 代码解释和生成

---

### 6. 💻 终端 / Terminal (2 plugins)

终端管理工具

- **fterm.lua** - 浮动终端窗口
- **toggleterm.lua** - 终端管理器，支持多个终端实例

**使用场景**: 在 Neovim 中运行命令、集成终端工作流

---

### 7. 🐛 调试 / Debugging (1 plugin)

代码调试工具

- **dap.lua** - Debug Adapter Protocol，支持多语言调试

**使用场景**: 断点调试、变量查看、单步执行

---

### 8. 📝 语言特定 / Language-Specific (1 plugin)

特定编程语言的增强功能

- **go-nvim.lua** - Go 语言开发增强

**使用场景**: Go 语言开发时的特殊功能

---

### 9. 🛠️ 工具 / Utils (4 plugins)

其他实用工具

- **trouble.lua** - 诊断信息管理，统一查看错误和警告
- **cloak.lua** - 隐藏敏感信息（如 API 密钥）
- **peek.lua** - Markdown 预览
- **vimbegood.lua** - Vim 操作练习游戏

**使用场景**: 错误诊断、敏感信息保护、文档预览、技能训练

---

### 10. 💾 会话 / Session (1 plugin)

工作区会话管理

- **auto-session.lua** - 自动保存和恢复工作区状态

**使用场景**: 在项目间切换、保存工作进度

---

## 📊 统计信息 / Statistics

- **总插件数 / Total Plugins**: 34
- **最大分类 / Largest Category**: UI Enhancement (8 plugins)
- **最小分类 / Smallest Category**: Debugging, Language-Specific, Session (1 plugin each)

---

## 🔍 快速查找 / Quick Find

### 按使用频率 / By Usage Frequency

**高频使用 / High Frequency**:
- Git 工具 (lazygit, diffview)
- 导航工具 (harpoon, flash, aerial)
- AI 工具 (copilot)
- 终端工具 (toggleterm, fterm)

**中频使用 / Medium Frequency**:
- 编辑工具 (nvim-surround, nvim-ufo, refactoring)
- UI 工具 (noice, lualine, zenmode)
- 工具类 (trouble)

**低频使用 / Low Frequency**:
- 调试工具 (dap)
- 会话管理 (auto-session)
- 训练工具 (hardtime, vimbegood)

---

## 🔧 加载方式 / Loading

所有插件通过 `lua/custom/plugins/init.lua` 自动加载：

```lua
-- Lazy.nvim 会自动加载 plugins 目录下所有 .lua 文件（包括子目录）
return {}
```

---

## 📝 添加新插件 / Adding New Plugins

将新插件配置文件放入对应分类目录：

```bash
# 例如添加新的 Git 插件
nvim lua/custom/plugins/git/new-git-plugin.lua

# 例如添加新的编辑工具
nvim lua/custom/plugins/editing/new-editor.lua
```

---

**最后更新 / Last Updated**: 2026-01-02
