-- plugin loading
require("config.lazy")

-- theme
--require('wombat').setup({ ansi_colors_name = "ghostty" })
--vim.cmd.colorscheme("wombat")
vim.cmd.colorscheme("doom-one")

-- numbers, ruler, etc
vim.opt.modeline = true
vim.opt.ruler = true
vim.opt.number = true
vim.opt.autoindent = true

-- tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- indenting
vim.api.nvim_set_keymap('v', '<Tab>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', '<C-o><<', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- keybinds for netrw
vim.api.nvim_create_user_command('E', 'Ex', {})
