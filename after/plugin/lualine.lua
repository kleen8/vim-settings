require('lualine').setup({
  options = {
    theme = 'auto',
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { 'filename', 'filetype' },
    lualine_x = {
      'encoding',
      'fileformat',
      { 'lsp', icon = '' },
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  extensions = { 'fugitive' },
})

