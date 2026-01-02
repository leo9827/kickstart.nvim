# 📦 Neovim 插件总览 / Plugins Overview

本配置共有 **35** 个自定义插件，按功能分为 10 个类别。

---

## 🔀 Git 相关 (4)

| 插件 | 功能 | 快捷键 |
|------|------|--------|
| **lazygit** | LazyGit 集成，完整的 Git UI | `<leader>gg` `<leader>gf` |
| **diffview** | Diff 查看和文件历史 | `<leader>gd` `<leader>gh` `<leader>gH` `<leader>gq` |
| **git-blame** | 显示每行的 Git blame 信息 | `<leader>gb` |
| **octo** | GitHub PR/Issue 管理 | `<leader>gpr` `<leader>gpc` `<leader>gis` `<leader>gic` |

**使用场景**: Git 提交、查看改动、代码审查、PR 管理

---

## 🎨 UI 增强 (9)

| 插件 | 功能 | 说明 |
|------|------|------|
| **alpha-nvim** | 启动页面美化 | 显示快捷入口和项目列表 |
| **lualine** | 状态栏美化 | 显示文件信息、Git 状态等 |
| **noice** | 命令行和通知美化 | 现代化的消息界面 |
| **bufferline** | Buffer 标签栏 | 顶部显示打开的文件 |
| **dressing** | 输入/选择界面美化 | 美化各种输入框 |
| **auto-dark-mode** | 自动切换主题 | 根据系统自动切换亮/暗色 |
| **neoscroll** | 平滑滚动 | 滚动动画效果 |
| **zenmode** | 专注模式 | 隐藏干扰元素 `<leader>za/zf/zm/zn` |
| **treesitter-context** | 上下文显示 | 显示当前代码所在的类/函数 |

**使用场景**: 界面美化、提升视觉体验、专注编码

---

## 🧭 导航 (6)

| 插件 | 功能 | 快捷键 |
|------|------|--------|
| **aerial-nvim** | 代码大纲浏览器 | `<leader>o` `<leader>so` |
| **harpoon** | 文件快速标记和跳转 | `<leader>ma/mf/md` `<C-1/2/3>` `<C-n/p>` |
| **flash-nvim** | 光标快速跳转 | `s` `S` `r` `R` |
| **dropbar** | 面包屑导航栏 | `<leader>;` `[;` `];` |
| **nvim-navic** | 显示当前代码上下文 | 在状态栏显示位置 |
| **oil-nvim** | 文件管理器 | 像编辑 buffer 一样管理文件 |

**使用场景**: 快速定位代码、文件跳转、浏览项目结构

---

## ✏️ 编辑增强 (5)

| 插件 | 功能 | 快捷键/说明 |
|------|------|-----------|
| **nvim-surround** | 快速修改包围符号 | `ys` `ds` `cs` (添加/删除/修改引号、括号等) |
| **nvim-ufo** | 代码折叠增强 | `zR/zM/za/zo/zc` |
| **refactoring** | 代码重构工具 | `<leader>r` (提取函数、变量等) |
| **hardtime** | Vim 习惯训练 | 防止过度使用方向键 |
| **undotree** | 可视化撤销树 | `<leader>u` |

**使用场景**: 代码重构、快速编辑、撤销管理、提升 Vim 技能

---

## 🤖 AI 工具 (2)

| 插件 | 功能 | 说明 |
|------|------|------|
| **copilot** | GitHub Copilot | AI 代码补全 |
| **avante-nvim** | AI 对话助手 | 代码解释、生成、优化 |

**使用场景**: AI 辅助编程、代码生成、问题解答

---

## 💻 终端 (2)

| 插件 | 功能 | 快捷键 |
|------|------|--------|
| **fterm** | 浮动终端 | `<C-t>` `<leader>tf` |
| **toggleterm** | 终端管理器 | `<C-\>` `<leader>tt/tf/tl` |

**使用场景**: 在 Neovim 中运行命令、集成终端工作流

---

## 🐛 调试 (1)

| 插件 | 功能 | 快捷键 |
|------|------|--------|
| **dap** | Debug Adapter Protocol | `<leader>b` `<F5>` `<F1/2/3>` `<F7>` |

**使用场景**: 断点调试、单步执行、变量查看

---

## 📝 语言特定 (1)

| 插件 | 功能 | 说明 |
|------|------|------|
| **go-nvim** | Go 语言增强 | Go 开发特性和快捷键 |

**使用场景**: Go 语言开发

---

## 🛠️ 工具 (4)

| 插件 | 功能 | 快捷键/说明 |
|------|------|-----------|
| **trouble** | 诊断信息管理 | `<leader>xx/xX/cs/cl/xL/xQ` |
| **cloak** | 隐藏敏感信息 | 自动隐藏 API 密钥等 |
| **peek** | Markdown 预览 | 实时预览 Markdown 文件 |
| **vimbegood** | Vim 练习游戏 | 练习 Vim 操作 |

**使用场景**: 错误诊断、敏感信息保护、文档预览、技能训练

---

## 💾 会话 (1)

| 插件 | 功能 | 快捷键 |
|------|------|--------|
| **auto-session** | 工作区会话管理 | `<leader>ws/wr/ww/wd` |

**使用场景**: 保存和恢复工作区状态、在项目间切换

---

## 📁 目录结构 / Directory Structure

```
lua/custom/plugins/
├── README.md                # 插件分类说明
├── init.lua                 # 插件加载入口
├── git/                     # Git 相关 (4)
│   ├── lazygit.lua
│   ├── diffview.lua
│   ├── git-blame.lua
│   └── octo.lua
├── ui-enhancement/          # UI 增强 (9)
│   ├── alpha-nvim.lua
│   ├── lualine.lua
│   ├── noice.lua
│   ├── bufferline.lua
│   ├── dressing.lua
│   ├── auto-dark-mode.lua
│   ├── neoscroll.lua
│   ├── zenmode.lua
│   └── treesitter-context.lua
├── navigation/              # 导航 (6)
│   ├── aerial-nvim.lua
│   ├── harpoon.lua
│   ├── flash-nvim.lua
│   ├── dropbar.lua
│   ├── nvim-navic.lua
│   └── oil-nvim.lua
├── editing/                 # 编辑增强 (5)
│   ├── nvim-surround.lua
│   ├── nvim-ufo.lua
│   ├── refactoring.lua
│   ├── hardtime.lua
│   └── undotree.lua
├── ai-tools/                # AI 工具 (2)
│   ├── copilot.lua
│   └── avante-nvim.lua
├── terminal/                # 终端 (2)
│   ├── fterm.lua
│   └── toggleterm.lua
├── debugging/               # 调试 (1)
│   └── dap.lua
├── language-specific/       # 语言特定 (1)
│   └── go-nvim.lua
├── utils/                   # 工具 (4)
│   ├── trouble.lua
│   ├── cloak.lua
│   ├── peek.lua
│   └── vimbegood.lua
└── session/                 # 会话 (1)
    └── auto-session.lua
```

---

## 🔍 按使用频率分类 / By Usage Frequency

### 🔥 高频使用 (日常必备)
- **Git**: lazygit, diffview
- **导航**: harpoon, flash, aerial
- **AI**: copilot
- **终端**: toggleterm, fterm
- **编辑**: nvim-surround

### ⭐ 中频使用 (常用功能)
- **编辑**: nvim-ufo, refactoring
- **UI**: noice, lualine, zenmode
- **工具**: trouble
- **Git**: git-blame

### 💡 低频使用 (特定场景)
- **调试**: dap
- **会话**: auto-session
- **训练**: hardtime, vimbegood
- **工具**: cloak, peek
- **Git**: octo

---

## 📊 统计信息 / Statistics

- **总插件数**: 35
- **最大分类**: UI Enhancement (9 plugins)
- **平均每个分类**: 3.5 plugins
- **包含快捷键的插件**: ~25 (74%)

---

## 💡 使用建议 / Tips

1. **新手入门**: 先熟悉导航类（harpoon, flash）和编辑类（nvim-surround）插件
2. **Git 工作流**: lazygit + diffview 组合使用效果最佳
3. **代码导航**: aerial + flash + harpoon 三者配合快速定位
4. **专注编码**: 使用 zenmode + noice 获得沉浸式体验
5. **按类别学习**: 每次专注学习一个分类的插件，避免信息过载

---

**查看详细快捷键**: 参考 [KEYMAPS.md](../../KEYMAPS.md)

**最后更新**: 2026-01-02
