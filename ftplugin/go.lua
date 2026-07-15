local function map(lhs, rhs, desc)
  vim.keymap.set('n', lhs, rhs, { buffer = true, desc = desc })
end

map('<leader>ge', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>', '[G]o [E]rror return')
map('<leader>ga', 'oassert.NoError(err, "")<Esc>F";a', '[G]o [A]ssert no error')
map('<leader>gf', 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj', '[G]o error [F]atalf')
map('<leader>gl', 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i', '[G]o error [L]ogger')
