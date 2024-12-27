-- Reserve a space in the gutter
vim.opt.signcolumn = 'yes'

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body) -- Use LuaSnip for snippet support
		end,
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept completion
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' }, -- LSP-based completions
		{ name = 'path' },     -- Filesystem paths
	}, {
		{ name = 'buffer' },   -- Current buffer completions
	}),
})

-- Link nvim-cmp to LSP servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').pyright.setup({
	capabilities = capabilities, -- Add nvim-cmp capabilities
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})
-- Add cmp_nvim_lsp capabilities settings to lspconfig
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
'force',
lspconfig_defaults.capabilities,
require('cmp_nvim_lsp').default_capabilities()
)

-- Set up keybindings for LSP actions
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'LSP actions',
	callback = function(event)
		local opts = { buffer = event.buf }

		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
		vim.keymap.set({ 'n', 'x' }, '<F3>', function() vim.lsp.buf.format({ async = true }) end, opts)
		vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, opts)
	end,
})

-- Mason setup
require('mason').setup({})

-- Mason-LSPConfig setup
require('mason-lspconfig').setup({
	ensure_installed = { 'pyright', 'gopls', 'jdtls', 'lua_ls' }, -- Ensure the right LSP's are installed
	handlers = {
		function(server_name)
			require('lspconfig')[server_name].setup({})
		end,
	},
})

-- Configure Pyright specifically
require('lspconfig').pyright.setup({
	root_dir = require('lspconfig').util.root_pattern('main.py', '.git', 'setup.py'),
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "off",  -- Options: off, basic, strict
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
			},
		},
	},
})

-- configure java lang support
local jdtls = require('jdtls')

-- Function to set up JDTLS for Java files
local function setup_jdtls()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
	local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name

	local config = {
		cmd = {
			'jdtls', -- Make sure `jdtls` is in your PATH or provide its absolute path
			'-data', workspace_dir
		},
		root_dir = require('lspconfig').util.root_pattern('.git', 'pom.xml', 'build.gradle'),
		settings = {
			java = {
				configuration = {
					runtimes = {
						-- Add any additional JDKs you use here
						{
							name = "JavaSE-17",
							path = "/usr/lib/jvm/java-17-openjdk-amd64/bin/java"
						}
					}
				}
			}
		},
		init_options = {
			bundles = {} -- Add any custom debug bundles here
		}
	}

	jdtls.start_or_attach(config)
end

-- Automatically start JDTLS for Java files
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'java',
	callback = setup_jdtls,
})

require('lspconfig').gopls.setup({
	capabilities = require('cmp_nvim_lsp').default_capabilities(),
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
		},
	},
})


local lspconfig = require('lspconfig')

lspconfig.yamlls.setup {
    on_attach = function(client, bufnr)
        -- Add keybindings or other custom on-attach behavior here
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        yaml = {
            schemas = {
                -- Define schemas here, for example:
                ["https://json.schemastore.org/github-workflow"] = "/.github/workflows/*",
                ["https://json.schemastore.org/kubernetes"] = "/*.k8s.yaml"
            },
            validate = true, -- Enable validation
            completion = true, -- Enable autocompletion
            hover = true -- Enable hover documentation
        }
    }
}


local lspconfig = require('lspconfig')

lspconfig.lemminx.setup {
    on_attach = function(client, bufnr)
        -- Add keybindings or other custom on-attach behavior here
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        xml = {
            completion = {
                enabled = true
            },
            validation = {
                enabled = true
            }
        }
    }
}

require('lspconfig').lua_ls.setup({
	capabilities = require('cmp_nvim_lsp').default_capabilities(),
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
				path = vim.split(package.path, ';'),
			},
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})




