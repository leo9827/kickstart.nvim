# avante-lite.nvim

一个极简的 Avante 风格 Neovim AI 侧边栏插件（MVP）：只实现 `Ask + 选区上下文 + 侧边结果窗口`。

## 依赖

- Neovim 0.10+（使用 `vim.ui.input`、`vim.json` 等）
- `curl`（用于请求 OpenAI）
- 环境变量：`OPENAI_API_KEY`

## 命令

- `:AvanteLiteAsk [question]`：提问；可在可视模式下选择一段文本后再执行（会把选区作为上下文一起发送）
- `:AvanteLiteClear`：清空侧边栏与会话
- `:AvanteLiteStop`：停止当前请求

## 配置

```lua
require("avante_lite").setup({
  openai = {
    model = "gpt-4o-mini",
  },
  ui = {
    position = "right",
    width = 50,
  },
})
```

## 测试

在仓库根目录运行（避免写入默认 shada 路径）：

```sh
XDG_DATA_HOME=/tmp/nvim-data XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache \
  nvim --headless -u local/avante-lite.nvim/tests/minimal_init.lua
```

### 集成测试（会真实请求 OpenAI）

默认会跳过；需要显式开启并提供 API key：

```sh
AVANTE_LITE_RUN_INTEGRATION=1 OPENAI_API_KEY=... \
XDG_DATA_HOME=/tmp/nvim-data XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache \
  nvim --headless -u local/avante-lite.nvim/tests/minimal_init.lua
```

可选环境变量：
- `AVANTE_LITE_OPENAI_MODEL`（默认 `gpt-4o-mini`）
- `AVANTE_LITE_OPENAI_ENDPOINT`（默认 `https://api.openai.com/v1/chat/completions`）
