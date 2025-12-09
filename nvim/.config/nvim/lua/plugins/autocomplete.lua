return {
  -- 1. Neovim's built-in LSP configuration manager (required for LSP)
  'neovim/nvim-lspconfig',

  -- 2. Autocomplete Engine (required for the UI)
  'hrsh7th/nvim-cmp',

  -- 3. LSP Installer (highly recommended for managing language servers)
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  
  -- Optional but highly recommended components:
  'hrsh7th/cmp-nvim-lsp', -- Source for LSP suggestions
  'hrsh7th/cmp-buffer',   -- Source for current buffer words
  'L3MON4D3/LuaSnip',     -- Snippet engine
  'saadparwaiz1/cmp_luasnip', -- Source for snippet suggestions
}
