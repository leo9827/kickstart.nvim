-- Minimal standalone contract consumed by Base46 integrations.
return {
  base46 = {
    theme = 'flexoki-light',
    transparency = true,
    hl_override = {},
    hl_add = {},
    integrations = {},
    changed_themes = {},
    excluded = {
      'cmp',
      'mason',
      'nvcheatsheet',
      'nvimtree',
      'statusline',
      'tbline',
    },
  },
  ui = {
    cmp = { style = 'default' },
    telescope = { style = 'borderless' },
  },
}
