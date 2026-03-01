-- LSP Setup: REQUIRE MASON FIRST

-- 1. Hardware Detection Logic
local function get_product_name()
	local file = io.open("/sys/class/dmi/id/product_name", "r")
	if not file then
		return "unknown"
	end
	local name = file:read("*l"):gsub("%s+", "") -- Read and trim
	file:close()
	return name
end

local current_product = get_product_name()

-- Define which servers to ignore on specific hardware
-- Key: The string from /sys/class/dmi/id/product_name
-- Value: Table of LSP names to skip
local ignored_by_system = {
	["DS216+"] = { "clangd", "lua_ls" },
}

-- 2. Setup Mason
require("mason").setup()

-- Core components
local cmp = require("cmp")
local cmp_lsp = require("cmp_nvim_lsp")
local lspconfig = require("lspconfig")

-- Full list of desired servers
local servers = {
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
}

-- Filter the list based on current hardware
local final_servers = {}
local ignored_list = ignored_by_system[current_product] or {}

for _, server in ipairs(servers) do
	local is_ignored = false
	for _, ignored in ipairs(ignored_list) do
		if server == ignored then
			is_ignored = true
			break
		end
	end

	if not is_ignored then
		table.insert(final_servers, server)
	end
end

-- Prepare LSP capabilities
local capabilities = cmp_lsp.default_capabilities()

-- 3. Setup Mason-LSPCONFIG
require("mason-lspconfig").setup({
	ensure_installed = final_servers, -- Use the filtered list here
	automatic_installation = true,

	handlers = {
		["*"] = function(server_name)
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
