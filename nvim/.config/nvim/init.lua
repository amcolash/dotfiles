-- plugin loading
require("config.lazy")

-- load language server configs
require("config.lsp")

-- theme
--require('wombat').setup({ ansi_colors_name = "ghostty" })
--vim.cmd.colorscheme("wombat")
vim.cmd.colorscheme("doom-one")

-- ensure term gui colors are on and highlight hex/rgba/css/etc colors
vim.opt.termguicolors = true
require('nvim-highlight-colors').setup({})

-- set ruler color
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#444444" })

-- numbers, ruler, etc
vim.opt.modeline = true
vim.opt.ruler = true
vim.opt.number = true
vim.opt.autoindent = true

-- Initial setup for the first time the buffer is entered
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("doautocmd BufEnter")
  end,
})

-- tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- indenting
vim.api.nvim_set_keymap('v', '<Tab>', '>gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<S-Tab>', '<C-o><<', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- LSP-based formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Only format if an LSP client is attached to the buffer
    if #vim.lsp.get_active_clients({ bufnr = 0 }) > 0 then
      vim.lsp.buf.format({ async = false })
    end
  end,
})

-- open netrw if no file passed on start
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("NetrwOpen", { clear = true }),
  callback = function()
    -- argc() returns the number of arguments (files) passed to nvim
    -- If no arguments were given (i.e., argc() is 0), run :Ex
    if vim.fn.argc() == 0 then
      vim.cmd("Ex")
    end
  end,
})

-- restore ":E" command for netrw
vim.api.nvim_create_user_command('E', 'Ex', {})

-- custom :indent command for manual indenting
vim.api.nvim_create_user_command('Indent', function()
  local view = vim.fn.winsaveview()
  vim.cmd([[silent! normal! gg=G]])
  vim.fn.winrestview(view)
end, {})
