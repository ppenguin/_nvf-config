
-- mostly default 
-- https://notashelf.github.io/nvf/options.html#opt-vim.statusline.lualine.activeSection.b
-- but we want full path (path=1)
{
  "filetype",
  colored = true,
  icon_only = true,
  icon = { align = 'left' }
},
{
  "filename",
  path = 1,
  symbols = {modified = ' ', readonly = ' '},
  separator = {right = ''}
},
{
  "",
  draw_empty = true,
  separator = { left = '', right = '' }
}
