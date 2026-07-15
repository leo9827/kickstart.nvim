local M = {}

local patched = false

function M.patch()
  if patched or vim.fn.has 'nvim-0.12' == 0 then
    return
  end

  local query = require 'vim.treesitter.query'
  local info_string_aliases = {
    ex = 'elixir',
    pl = 'perl',
    sh = 'bash',
    ts = 'typescript',
    uxn = 'uxntal',
  }
  local script_type_languages = {
    ['application/ecmascript'] = 'javascript',
    importmap = 'json',
    module = 'javascript',
    ['text/ecmascript'] = 'javascript',
  }

  local function capture_node(match, capture_id)
    local node = match[capture_id]
    return type(node) == 'table' and node[#node] or node
  end

  local function capture_text(match, capture_id, bufnr, metadata)
    local node = capture_node(match, capture_id)
    if not node then
      return
    end
    return vim.treesitter.get_node_text(node, bufnr, { metadata = metadata and metadata[capture_id] or nil })
  end

  query.add_directive('set-lang-from-mimetype!', function(match, _, bufnr, pred, metadata)
    local value = capture_text(match, pred[2], bufnr, metadata)
    if not value or value == '' then
      return
    end

    local configured = script_type_languages[value]
    if configured then
      metadata['injection.language'] = configured
      return
    end

    local parts = vim.split(value, '/', {})
    metadata['injection.language'] = parts[#parts]
  end, { force = true, all = false })

  query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
    local alias = capture_text(match, pred[2], bufnr, metadata)
    if not alias or alias == '' then
      return
    end

    alias = alias:lower()
    metadata['injection.language'] = vim.filetype.match { filename = 'a.' .. alias } or info_string_aliases[alias] or alias
  end, { force = true, all = false })

  query.add_directive('downcase!', function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local text = capture_text(match, capture_id, bufnr, metadata)
    if text == nil then
      return
    end

    metadata[capture_id] = metadata[capture_id] or {}
    metadata[capture_id].text = text:lower()
  end, { force = true, all = false })

  patched = true
end

return M
