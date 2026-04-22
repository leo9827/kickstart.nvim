# Neovim 快捷键速查表 / Keymaps Cheat Sheet

> 本文档收集了所有自定义快捷键配置，方便查阅和记忆
> This document collects all custom keymaps for quick reference

**快捷键前缀说明 / Prefix Notation:**
- `<leader>` = Space (空格键)
- `<C-x>` = Ctrl + x
- `<S-x>` = Shift + x
- `n` = Normal   mode (普通模式)
- `v` = Visual   mode (可视模式)
- `x` = Visual   mode (可视模式)
- `i` = Insert   mode (插入模式)
- `t` = Terminal mode (终端模式)

---

## 📑 目录 / Table of Contents

1. [基础编辑 / Basic Editing](#基础编辑--basic-editing)
2. [文件导航 / File Navigation](#文件导航--file-navigation)
3. [窗口管理 / Window Management](#窗口管理--window-management)
4. [Git 操作 / Git Operations](#git-操作--git-operations)
5. [代码导航 / Code Navigation](#代码导航--code-navigation)
6. [代码编辑与重构 / Code Editing & Refactoring](#代码编辑与重构--code-editing--refactoring)
7. [终端 / Terminal](#终端--terminal)
8. [调试 / Debugging](#调试--debugging)
9. [工作区会话 / Workspace Sessions](#工作区会话--workspace-sessions)
10. [主题与界面 / Theme & UI](#主题与界面--theme--ui)
11. [其他工具 / Other Tools](#其他工具--other-tools)

---

## 基础编辑 / Basic Editing

### 行移动 / Line Movement
| 快捷键  | 模式   | 功能                                             | 使用场景       |
| ------- | ------ | ------------------------------------------------ | -------------- |
| `J` (v) | Visual | 向下移动选中行 / Move selected lines down        | 调整代码顺序时 |
| `K` (v) | Visual | 向上移动选中行 / Move selected lines up          | 调整代码顺序时 |
| `J` (n) | Normal | 合并行（光标居中）/ Join lines (cursor centered) | 合并多行为一行 |

### 滚动与搜索 / Scrolling & Search
| 快捷键  | 模式   | 功能                                               | 使用场景                 |
| ------- | ------ | -------------------------------------------------- | ------------------------ |
| `<C-d>` | Normal | 向下滚动（居中）/ Scroll down (centered)           | 浏览长文件时保持视线居中 |
| `<C-u>` | Normal | 向上滚动（居中）/ Scroll up (centered)             | 浏览长文件时保持视线居中 |
| `n`     | Normal | 下一个搜索结果（居中）/ Next search (centered)     | 搜索时快速定位           |
| `N`     | Normal | 上一个搜索结果（居中）/ Previous search (centered) | 搜索时快速定位           |
| `<Esc>` | Normal | 清除搜索高亮 / Clear search highlight              | 搜索后清除高亮           |

### 剪贴板操作 / Clipboard Operations
| 快捷键       | 模式          | 功能                                                 | 使用场景           |
| ------------ | ------------- | ---------------------------------------------------- | ------------------ |
| `<leader>p`  | Visual        | 粘贴不覆盖寄存器 / Paste without yanking             | 多次粘贴同一内容   |
| `y`          | Normal/Visual | 复制到系统剪贴板 / Yank to system clipboard          | 与其他应用共享内容 |
| `<leader>y`  | Normal/Visual | 复制到系统剪贴板 / Yank to system clipboard          | 与其他应用共享内容 |
| `<leader>Y`  | Normal        | 复制整行到系统剪贴板 / Yank line to system clipboard | 快速复制整行       |
| `<leader>d`  | Normal/Visual | 删除到黑洞寄存器 / Delete to black hole              | 删除但不影响剪贴板 |
| `<leader>cc` | Normal/Visual | 修改到黑洞寄存器 / Change to black hole              | 修改但不影响剪贴板 |

### 快速替换 / Quick Substitution
| 快捷键      | 模式   | 功能                                            | 使用场景       |
| ----------- | ------ | ----------------------------------------------- | -------------- |
| `<leader>S` | Normal | 替换光标下的单词 / Substitute word under cursor | 批量重命名变量 |

### 其他编辑操作 / Other Editing
| 快捷键      | 模式   | 功能                                      | 使用场景       |
| ----------- | ------ | ----------------------------------------- | -------------- |
| `=ap`       | Normal | 格式化段落 / Format paragraph             | 调整文本格式   |
| `<leader>x` | Normal | 为文件添加执行权限 / Make file executable | 创建脚本文件后 |

---

## 文件导航 / File Navigation

### Telescope 模糊查找 / Telescope Fuzzy Finder
| 快捷键             | 模式   | 功能                                        | 使用场景                 |
| ------------------ | ------ | ------------------------------------------- | ------------------------ |
| `<leader>sh`       | Normal | 搜索帮助文档 / Search help                  | 查找 Vim 帮助            |
| `<leader>sk`       | Normal | 搜索快捷键 / Search keymaps                 | 查找已配置的快捷键       |
| `<leader>sf`       | Normal | 搜索文件 / Search files                     | 快速打开文件             |
| `<leader>ss`       | Normal | 选择 Telescope 功能 / Select Telescope      | 浏览所有 Telescope 功能  |
| `<leader>sw`       | Normal | 搜索当前单词 / Search current word          | 在项目中查找当前词       |
| `<leader>sg`       | Normal | 实时搜索 / Live grep                        | 在项目中搜索内容         |
| `<leader>sd`       | Normal | 搜索诊断信息 / Search diagnostics           | 查找所有错误和警告       |
| `<leader>sr`       | Normal | 恢复上次搜索 / Resume search                | 继续上次的搜索           |
| `<leader>s.`       | Normal | 搜索最近文件 / Search recent files          | 打开最近编辑的文件       |
| `<leader><leader>` | Normal | 查找已打开缓冲区 / Find buffers             | 在已打开文件间切换       |
| `<leader>/`        | Normal | 在当前缓冲区搜索 / Search in buffer         | 搜索当前文件内容         |
| `<leader>s/`       | Normal | 在已打开缓冲区搜索 / Search in open files   | 在所有打开文件中搜索     |
| `<leader>sn`       | Normal | 搜索 Neovim 配置文件 / Search Neovim config | 快速修改配置             |
| `<leader>sO`       | Normal | 搜索文档符号 / Search document symbols      | 查看当前文件的函数、类等 |
| `<leader>sW`       | Normal | 搜索工作区符号 / Search workspace symbols   | 在整个项目中搜索符号     |

### Harpoon 文件标记 / Harpoon File Marks
| 快捷键       | 模式   | 功能                                     | 使用场景                 |
| ------------ | ------ | ---------------------------------------- | ------------------------ |
| `<leader>ma` | Normal | 添加文件到 Harpoon / Add file to Harpoon | 标记常用文件             |
| `<leader>mf` | Normal | 打开 Harpoon 菜单 / Open Harpoon menu    | 查看和选择标记的文件     |
| `<leader>md` | Normal | 移除当前文件 / Remove current file       | 从 Harpoon 中移除文件    |
| `<C-1>`      | Normal | 跳转到文件 1 / Jump to file 1            | 快速切换到第一个标记文件 |
| `<C-2>`      | Normal | 跳转到文件 2 / Jump to file 2            | 快速切换到第二个标记文件 |
| `<C-3>`      | Normal | 跳转到文件 3 / Jump to file 3            | 快速切换到第三个标记文件 |
| `<C-n>`      | Normal | 下一个 Harpoon 文件 / Next Harpoon file  | 循环切换标记文件         |
| `<C-p>`      | Normal | 上一个 Harpoon 文件 / Prev Harpoon file  | 反向循环切换标记文件     |

### Neo-tree 文件树 / Neo-tree File Explorer
| 快捷键      | 模式   | 功能                               | 使用场景         |
| ----------- | ------ | ---------------------------------- | ---------------- |
| `<C-n>`     | Normal | 打开/关闭文件树 / Toggle file tree | 浏览项目结构     |
| `<leader>e` | Normal | 聚焦文件树 / Focus file tree       | 将光标移到文件树 |

---

## 窗口管理 / Window Management

### 窗口聚焦 / Window Focus
| 快捷键  | 模式   | 功能                              | 使用场景         |
| ------- | ------ | --------------------------------- | ---------------- |
| `<C-h>` | Normal | 聚焦左侧窗口 / Focus left window  | 在分屏间快速移动 |
| `<C-l>` | Normal | 聚焦右侧窗口 / Focus right window | 在分屏间快速移动 |
| `<C-j>` | Normal | 聚焦下方窗口 / Focus lower window | 在分屏间快速移动 |
| `<C-k>` | Normal | 聚焦上方窗口 / Focus upper window | 在分屏间快速移动 |

### 终端窗口移动 / Terminal Window Movement
| 快捷键      | 模式     | 功能                                      | 使用场景             |
| ----------- | -------- | ----------------------------------------- | -------------------- |
| `<C-h>` (t) | Terminal | 从终端移动到左窗口 / Move to left window  | 在终端和编辑器间切换 |
| `<C-j>` (t) | Terminal | 从终端移动到下窗口 / Move to lower window | 在终端和编辑器间切换 |
| `<C-k>` (t) | Terminal | 从终端移动到上窗口 / Move to upper window | 在终端和编辑器间切换 |
| `<C-l>` (t) | Terminal | 从终端移动到右窗口 / Move to right window | 在终端和编辑器间切换 |

### 专注模式 / Focus Modes
| 快捷键       | 模式   | 功能                                   | 使用场景             |
| ------------ | ------ | -------------------------------------- | -------------------- |
| `<leader>zn` | Normal | 聚焦到当前区域/函数 / Narrow to region | 专注于特定代码块     |
| `<leader>zn` | Visual | 聚焦到选中文本 / Narrow to selection   | 专注于选中的代码     |
| `<leader>zf` | Normal | 最大化当前窗口 / Focus window          | 临时全屏当前窗口     |
| `<leader>zm` | Normal | 极简模式 / Minimalist mode             | 隐藏界面元素专注编码 |
| `<leader>za` | Normal | 禅模式 / Zen mode (Ataraxis)           | 完整的专注模式体验   |

---

## Git 操作 / Git Operations

### LazyGit 集成 / LazyGit Integration
| 快捷键       | 模式   | 功能                                | 使用场景           |
| ------------ | ------ | ----------------------------------- | ------------------ |
| `<leader>gg` | Normal | 打开 LazyGit / Open LazyGit         | 管理所有 Git 操作  |
| `<leader>gf` | Normal | 当前文件历史 / Current file history | 查看文件的提交历史 |

### Diffview 差异查看 / Diffview
| 快捷键               | 模式   | 功能                               | 使用场景             |
| -------------------- | ------ | ---------------------------------- | -------------------- |
| `<leader>gd`         | Normal | 打开 Diff 视图 / Open diff view    | 查看工作区的所有改动 |
| `<leader>gh`         | Normal | 当前文件历史 / File history        | 浏览文件的提交历史   |
| `<leader>gH`         | Normal | 分支历史 / Branch history          | 浏览整个分支的改动   |
| `<leader>gq`         | Normal | 关闭 Diff 视图 / Close diff view   | 返回正常编辑模式     |
| `q` (Diffview)       | Normal | 关闭 Diffview / Close Diffview     | 在 diff 视图中关闭   |
| `<Tab>` (Diffview)   | Normal | 下一个改动文件 / Next changed file | 在改动文件间切换     |
| `<S-Tab>` (Diffview) | Normal | 上一个改动文件 / Prev changed file | 在改动文件间切换     |

### Gitsigns (Hunk 操作) / Gitsigns (Hunk Operations)
| 快捷键       | 模式   | 功能                                   | 使用场景                   |
| ------------ | ------ | -------------------------------------- | -------------------------- |
| `<leader>hs` | Normal | 暂存 hunk / Stage hunk                 | 暂存当前代码块的改动       |
| `<leader>hs` | Visual | 暂存选中 hunk / Stage selected hunk    | 暂存选中的改动             |
| `<leader>hr` | Normal | 重置 hunk / Reset hunk                 | 撤销当前代码块的改动       |
| `<leader>hr` | Visual | 重置选中 hunk / Reset selected hunk    | 撤销选中的改动             |
| `<leader>hS` | Normal | 暂存整个文件 / Stage buffer            | 暂存当前文件的所有改动     |
| `<leader>hu` | Normal | 撤销暂存 hunk / Undo stage hunk        | 取消暂存                   |
| `<leader>hR` | Normal | 重置整个文件 / Reset buffer            | 撤销文件的所有改动         |
| `<leader>hp` | Normal | 预览 hunk / Preview hunk               | 在弹窗中查看改动           |
| `<leader>hb` | Normal | Blame 当前行 / Blame line              | 查看当前行的提交信息       |
| `<leader>hd` | Normal | Diff 对比索引 / Diff against index     | 对比当前文件和索引         |
| `<leader>hD` | Normal | Diff 对比 HEAD / Diff against HEAD     | 对比当前文件和 HEAD        |
| `<leader>tb` | Normal | 切换行 blame / Toggle line blame       | 显示/隐藏每行的 blame 信息 |
| `<leader>tD` | Normal | 切换显示删除内容 / Toggle show deleted | 显示/隐藏被删除的行        |

### Git Blame 显示 / Git Blame Display
| 快捷键       | 模式   | 功能                              | 使用场景                   |
| ------------ | ------ | --------------------------------- | -------------------------- |
| `<leader>gb` | Normal | 切换 Git Blame / Toggle git blame | 显示每行代码的提交者和时间 |

### Octo (GitHub PR/Issue) / Octo (GitHub PR/Issue)
| 快捷键        | 模式   | 功能                      | 使用场景                    |
| ------------- | ------ | ------------------------- | --------------------------- |
| `<leader>gpr` | Normal | 列出 PR / List PRs        | 查看仓库的所有 Pull Request |
| `<leader>gpc` | Normal | 创建 PR / Create PR       | 创建新的 Pull Request       |
| `<leader>gis` | Normal | 列出 Issue / List issues  | 查看仓库的所有 Issue        |
| `<leader>gic` | Normal | 创建 Issue / Create issue | 创建新的 Issue              |

---

## 代码导航 / Code Navigation

### LSP 导航 / LSP Navigation
| 快捷键      | 模式   | 功能                               | 使用场景                  |
| ----------- | ------ | ---------------------------------- | ------------------------- |
| `gd`        | Normal | 跳转到定义 / Go to definition      | 查看函数/变量定义         |
| `gr`        | Normal | 查找引用 / Go to references        | 查看函数/变量被调用的地方 |
| `gI`        | Normal | 跳转到实现 / Go to implementation  | 查看接口的实现            |
| `<leader>D` | Normal | 类型定义 / Type definition         | 查看类型定义              |
| `K`         | Normal | 显示悬浮文档 / Hover documentation | 查看函数/变量的文档       |
| `gD`        | Normal | 跳转到声明 / Go to declaration     | 查看变量声明              |

### 代码大纲 / Code Outline
| 快捷键       | 模式   | 功能                           | 使用场景                   |
| ------------ | ------ | ------------------------------ | -------------------------- |
| `<leader>o`  | Normal | 打开/关闭大纲 / Toggle outline | 查看文件结构（函数、类等） |
| `<leader>so` | Normal | 搜索大纲 / Search outline      | 在大纲中模糊搜索符号       |

### Dropbar 面包屑导航 / Dropbar Breadcrumb Navigation
| 快捷键      | 模式   | 功能                                    | 使用场景              |
| ----------- | ------ | --------------------------------------- | --------------------- |
| `<leader>;` | Normal | 选择面包屑符号 / Pick breadcrumb symbol | 快速跳转到上层结构    |
| `[;`        | Normal | 跳转到上下文开始 / Go to context start  | 跳转到当前函数/类开始 |
| `];`        | Normal | 选择下一个上下文 / Select next context  | 跳转到下一个同级结构  |

### Flash 快速跳转 / Flash Quick Jump
| 快捷键  | 模式            | 功能                                           | 使用场景                       |
| ------- | --------------- | ---------------------------------------------- | ------------------------------ |
| `f`     | Normal/Operator | 向右字符跳转 / Flash char motion               | 查找后续字符，可跨行继续跳转   |
| `F`     | Normal/Operator | 向左字符跳转 / Flash reverse char motion       | 反向查找前面的字符             |
| `t`     | Normal/Operator | 跳到目标前 / Flash till motion                 | 精确停在目标字符前一位         |
| `T`     | Normal/Operator | 反向跳到目标后 / Flash reverse till motion     | 反向精确停位                   |
| `;`     | Normal/Operator | 继续上次 `f/F/t/T` 跳转 / Repeat char motion   | 连续跳到下一个匹配             |
| `,`     | Normal/Operator | 反向重复上次 `f/F/t/T` / Reverse repeat motion | 返回上一个匹配                 |
| `s`     | Normal/Operator | 独立跳转 / Flash jump                          | 屏幕内快速跳到任意可见位置     |
| `S`     | Normal/Operator | 语法树跳转 / Flash treesitter                  | 跳转到语法节点                 |

### Trouble 诊断列表 / Trouble Diagnostics
| 快捷键       | 模式   | 功能                              | 使用场景           |
| ------------ | ------ | --------------------------------- | ------------------ |
| `<leader>xx` | Normal | 诊断列表 / Diagnostics list       | 查看所有错误和警告 |
| `<leader>xX` | Normal | 当前文件诊断 / Buffer diagnostics | 查看当前文件的问题 |
| `<leader>cs` | Normal | 符号列表 / Symbols list           | 查看符号定义       |
| `<leader>cl` | Normal | LSP 信息 / LSP info               | 查看 LSP 相关信息  |
| `<leader>xL` | Normal | 位置列表 / Location list          | 打开位置列表       |
| `<leader>xQ` | Normal | 快速修复列表 / Quickfix list      | 打开快速修复列表   |

### 快速修复导航 / Quickfix Navigation
| 快捷键 | 模式   | 功能                               | 使用场景             |
| ------ | ------ | ---------------------------------- | -------------------- |
| `[q`   | Normal | 上一个快速修复 / Previous quickfix | 在快速修复列表中导航 |
| `]q`   | Normal | 下一个快速修复 / Next quickfix     | 在快速修复列表中导航 |
| `[l`   | Normal | 上一个位置 / Previous location     | 在位置列表中导航     |
| `]l`   | Normal | 下一个位置 / Next location         | 在位置列表中导航     |

---

## 代码编辑与重构 / Code Editing & Refactoring

### LSP 代码操作 / LSP Code Actions
| 快捷键       | 模式          | 功能                                  | 使用场景              |
| ------------ | ------------- | ------------------------------------- | --------------------- |
| `<leader>rn` | Normal        | 重命名 / Rename                       | 重命名变量/函数       |
| `<leader>ca` | Normal/Visual | 代码动作 / Code action                | 执行代码修复建议      |
| `<leader>e`  | Normal        | 显示行诊断 / Show line diagnostics    | 查看当前行的错误详情  |
| `<leader>ti` | Normal        | 切换 Inlay Hints / Toggle inlay hints | 查看/隐藏内联类型提示 |
| `<leader>f`  | Normal        | 格式化代码 / Format code              | 格式化当前文件        |

### Refactoring 重构工具 / Refactoring Tools
| 快捷键      | 模式   | 功能                              | 使用场景                        |
| ----------- | ------ | --------------------------------- | ------------------------------- |
| `<leader>r` | Visual | 打开重构菜单 / Open refactor menu | 选择重构操作（提取函数/变量等） |

### 代码折叠 / Code Folding (nvim-ufo)
| 快捷键 | 模式   | 功能                                       | 使用场景               |
| ------ | ------ | ------------------------------------------ | ---------------------- |
| `zR`   | Normal | 展开所有折叠 / Open all folds              | 查看完整代码           |
| `zM`   | Normal | 折叠所有代码 / Close all folds             | 查看代码整体结构       |
| `zr`   | Normal | 展开指定类型折叠 / Open folds except kinds | 逐层展开代码           |
| `zm`   | Normal | 折叠指定类型 / Close folds with kinds      | 逐层折叠代码           |
| `zo`   | Normal | 打开当前折叠 / Open current fold           | 展开光标处的折叠       |
| `zc`   | Normal | 关闭当前折叠 / Close current fold          | 折叠光标处的代码       |
| `za`   | Normal | 切换折叠状态 / Toggle fold                 | 切换当前折叠的开关状态 |

### Go 语言快捷键 / Go Language Shortcuts
| 快捷键       | 模式   | 功能                                    | 使用场景               |
| ------------ | ------ | --------------------------------------- | ---------------------- |
| `<leader>ge` | Normal | 插入 error return / Insert error return | 快速插入 Go error 处理 |
| `<leader>ga` | Normal | 插入 assert / Insert assert             | 插入测试断言           |
| `<leader>gf` | Normal | 插入 error Fatalf / Insert error Fatalf | 插入 fatal 错误处理    |
| `<leader>gl` | Normal | 插入 error logger / Insert error logger | 插入日志记录           |

---

## 终端 / Terminal

### ToggleTerm 终端管理 / ToggleTerm Terminal
| 快捷键       | 模式     | 功能                              | 使用场景                |
| ------------ | -------- | --------------------------------- | ----------------------- |
| `<c-\>`      | Normal   | 切换终端 / Toggle terminal        | 打开/关闭上次使用的终端 |
| `<leader>tt` | Normal   | 水平终端 / Horizontal terminal    | 打开水平分屏终端        |
| `<leader>tf` | Normal   | 浮动终端 / Floating terminal      | 打开浮动窗口终端        |
| `<esc>` (t)  | Terminal | 退出终端模式 / Exit terminal mode | 从终端切换到普通模式    |
| `jk` (t)     | Terminal | 退出终端模式 / Exit terminal mode | 从终端切换到普通模式    |

### FTerm 终端 / FTerm Terminal
| 快捷键       | 模式            | 功能                         | 使用场景                 |
| ------------ | --------------- | ---------------------------- | ------------------------ |
| `<C-t>`      | Normal/Terminal | 切换 FTerm / Toggle FTerm    | 打开/关闭 FTerm 浮动终端 |
| `<leader>tf` | Normal/Terminal | 浮动终端 / Floating terminal | 打开 FTerm 浮动终端      |

---

## 调试 / Debugging

### DAP 调试器 / DAP Debugger
| 快捷键      | 模式   | 功能                                     | 使用场景              |
| ----------- | ------ | ---------------------------------------- | --------------------- |
| `<leader>b` | Normal | 设置断点 / Set breakpoint                | 在当前行设置/移除断点 |
| `<leader>B` | Normal | 条件断点 / Conditional breakpoint        | 设置条件断点          |
| `<F5>`      | Normal | 开始/继续调试 / Start/Continue debugging | 启动或继续调试会话    |
| `<F1>`      | Normal | 单步进入 / Step into                     | 进入函数内部          |
| `<F2>`      | Normal | 单步跳过 / Step over                     | 执行下一行            |
| `<F3>`      | Normal | 单步跳出 / Step out                      | 跳出当前函数          |
| `<F7>`      | Normal | 打开调试 UI / Open debug UI              | 打开调试界面          |

---

## 工作区会话 / Workspace Sessions

### Auto-session 会话管理 / Auto-session Management
| 快捷键       | 模式   | 功能                       | 使用场景               |
| ------------ | ------ | -------------------------- | ---------------------- |
| `<leader>ws` | Normal | 搜索会话 / Search sessions | 查找并加载已保存的会话 |
| `<leader>wr` | Normal | 恢复会话 / Restore session | 恢复当前目录的会话     |
| `<leader>ww` | Normal | 保存会话 / Save session    | 保存当前工作区状态     |
| `<leader>wd` | Normal | 删除会话 / Delete session  | 删除已保存的会话       |

---

## 主题与界面 / Theme & UI

### 主题切换 / Theme Switching
| 快捷键       | 模式   | 功能                    | 使用场景             |
| ------------ | ------ | ----------------------- | -------------------- |
| `<leader>th` | Normal | 切换主题 / Switch theme | 更换 Neovim 配色主题 |

### 撤销历史 / Undo History
| 快捷键      | 模式   | 功能                        | 使用场景           |
| ----------- | ------ | --------------------------- | ------------------ |
| `<leader>u` | Normal | 打开撤销树 / Open undo tree | 查看和恢复历史更改 |

---

## 其他工具 / Other Tools

### 诊断信息 / Diagnostics
| 快捷键      | 模式   | 功能                                            | 使用场景         |
| ----------- | ------ | ----------------------------------------------- | ---------------- |
| `<leader>q` | Normal | 打开诊断快速修复列表 / Open diagnostic quickfix | 查看所有诊断信息 |

### 终端模式快捷退出 / Terminal Mode Quick Exit
| 快捷键       | 模式     | 功能                              | 使用场景               |
| ------------ | -------- | --------------------------------- | ---------------------- |
| `<Esc><Esc>` | Terminal | 退出终端模式 / Exit terminal mode | 从内置终端返回普通模式 |

---

## 📝 常用工作流示例 / Common Workflow Examples

### Git 工作流 / Git Workflow
1. `<leader>gg` - 打开 LazyGit 查看状态
2. `<leader>gd` - 查看详细的代码改动
3. `<leader>hs` - 暂存特定 hunk
4. `<leader>gg` - 返回 LazyGit 提交

### 代码浏览 / Code Navigation
1. `<leader>sf` - 搜索文件
2. `<leader>o` - 查看文件大纲
3. `gd` - 跳转到定义
4. `<C-o>` - 返回上一位置

### 重构工作流 / Refactoring Workflow
1. 选中代码 (Visual 模式)
2. `<leader>r` - 打开重构菜单
3. 选择重构操作（提取函数/变量等）
4. `<leader>f` - 格式化代码

### 调试工作流 / Debugging Workflow
1. `<leader>b` - 设置断点
2. `<F5>` - 开始调试
3. `<F2>` - 单步执行
4. `<F7>` - 查看变量值

---

## 💡 提示 / Tips

- 按 `<leader>sk` 可以搜索所有快捷键
- 在 Normal 模式按 `:Telescope keymaps` 可以查看所有映射
- 大部分插件支持在其界面内按 `?` 查看帮助
- 使用 `:checkhealth` 检查配置健康状态

---

**最后更新 / Last Updated:** 2026-01-04
