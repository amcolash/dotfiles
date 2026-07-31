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

-- open netrw (file explorer) if no file passed on start
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

-- Fully automatic, silent background updates for Lazy and Mason
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Wait 2 seconds after startup so it doesn't slow down your initial load
    vim.defer_fn(function()
      vim.notify("Running background updates for Lazy and Mason...", vim.log.levels.INFO)

      -- Silently update Lazy plugins
      require("lazy").update({ show = false })
      -- Silently update Mason tools
      vim.cmd("silent! MasonUpdate")
    end, 2000)
  end,
})
