return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/nvim-cmp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      -- Utility: Filter servers based on hardware to avoid overloading weak devices
      local function filter_hardware_servers(server_list)
        local f = io.open("/sys/class/dmi/id/product_name", "r")
        local product = f and f:read("*l"):gsub("%s+", "") or "unknown"
        if f then f:close() end

        local ignored = {
          ["DS216+"] = { "clangd", "lua_ls", "arduino_language_server" },
        }
        
        local to_ignore = ignored[product] or {}
        return vim.tbl_filter(function(s) return not vim.tbl_contains(to_ignore, s) end, server_list)
      end

      -- 2. Setup Mason
      require("mason").setup()

      -- Core components
      local cmp = require("cmp")
      local cmp_lsp = require("cmp_nvim_lsp")
      local lspconfig = require("lspconfig")

      -- Full list of desired servers (filtered by hardware)
      local final_servers = filter_hardware_servers({
        'ts_ls',                    -- TypeScript/JavaScript/React
        'pyright',                  -- Python
        'html',                     -- HTML
        'cssls',                    -- CSS
        'tailwindcss',              -- Tailwind CSS
        'clangd',                   -- C/C++ (also works for PlatformIO)
        'arduino_language_server',  -- Arduino
        'lua_ls',                   -- Lua
        'bashls',                   -- Bash/Shell scripts
        'yamlls',                   -- YAML
        'jsonls',                   -- JSON
        'taplo',                    -- TOML
      })

      -- Prepare LSP capabilities
      local capabilities = cmp_lsp.default_capabilities()

      -- 3. Setup Mason-LSPCONFIG
      require("mason-lspconfig").setup({
        ensure_installed = final_servers,
        automatic_installation = true,

        handlers = {
          function(server_name)
            local opts = {
              capabilities = capabilities,
            }

            if server_name == "lua_ls" then
              opts.settings = {
                Lua = {
                  runtime = { version = "LuaJIT" },
                  diagnostics = { globals = { "vim" } },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = { enable = false },
                },
              }
            end

            lspconfig[server_name].setup(opts)
          end,
        },
      })

      -- 4. nvim-cmp Setup
      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
      })
    end,
  }
}
