-- indenting
vim.api.nvim_set_keymap("v", "<Tab>", ">gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<S-Tab>", "<C-o><<", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<S-Tab>", "<gv", { noremap = true, silent = true })

-- custom :indent command for manual indenting
vim.api.nvim_create_user_command("Indent", function()
	local view = vim.fn.winsaveview()
	vim.cmd([[silent! normal! gg=G]])
	vim.fn.winrestview(view)
end, {})

-- restore ":E" command for netrw
vim.api.nvim_create_user_command("E", "Ex", {})
