-- LSP Setup: REQUIRE MASON FIRST

-- 1. Setup Mason: This must be done first!
require("mason").setup()

-- Core components
local cmp = require('cmp')
local cmp_lsp = require('cmp_nvim_lsp')
local lspconfig = require('lspconfig')

-- Define the list of servers you want Mason to manage/install
local servers = { 
  'tsserver', 
  'pyright',  
  'html',     
  'cssls',    
  'clangd',   
  'arduino_language_server', 
  'gdscript', 
  'lua_ls',
}

-- Prepare LSP capabilities for nvim-cmp integration
local capabilities = cmp_lsp.default_capabilities()


-- 2. Setup Mason-LSPCONFIG with Handlers (Modern Approach)
-- This single call handles both automatic installation AND configuration.
require('mason-lspconfig').setup({
  ensure_installed = servers,
  automatic_installation = true,

  -- Use the modern 'handlers' key instead of the deprecated 'setup_handlers'
  handlers = {
    -- Default handler for ALL servers defined in 'ensure_installed'
    ['*'] = function(server_name)
      local opts = {
        capabilities = capabilities,
      }

      -- Custom setup for lua_ls (with nvim support)
      if server_name == 'lua_ls' then
        opts.settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        }
      end

      -- This calls lspconfig.SERVER_NAME.setup()
      lspconfig[server_name].setup(opts)
    end,
  },
})


-- 3. nvim-cmp Setup (This remains the same)
cmp.setup({
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<CR>'] = cmp.mapping.confirm({ select = true }), 
    -- ... your other cmp mappings ...
  }),
})
