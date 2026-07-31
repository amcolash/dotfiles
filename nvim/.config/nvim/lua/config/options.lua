-- theme
vim.cmd.colorscheme("doom-one")
--require('wombat').setup({ ansi_colors_name = "ghostty" })
--vim.cmd.colorscheme("wombat")

-- ensure term gui colors are on
vim.opt.termguicolors = true

-- set ruler color
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#444444" })

-- numbers, ruler, etc
vim.opt.modeline = true
vim.opt.ruler = true
vim.opt.number = true
vim.opt.autoindent = true

-- tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
