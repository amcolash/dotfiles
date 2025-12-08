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

-- fzf-lua

-- open fzf if no file passed in
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local is_empty_session = #vim.api.nvim_list_bufs() == 1 and vim.api.nvim_buf_get_name(0) == ""

    if is_empty_session then
      require("fzf-lua").files()
    end
  end,
})

vim.api.nvim_set_keymap('n', '<leader>e', ':lua require("fzf-lua").files()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ':E', ':lua require("fzf-lua").files()<CR>', { noremap = true, silent = true })
