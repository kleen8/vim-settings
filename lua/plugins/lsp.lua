return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        "nvim-java/nvim-java",
    },

    config = function()
        require("java").setup()
        require("conform").setup({
            formatters_by_ft = {
            }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
	        	"gopls",
                "jdtls",
                "svelte",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,

                zls = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0

                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,

                ["svelte"] = function ()
                    require("lspconfig").svelte.setup({
                        capabilities = capabilities,
                        on_attach = function (client, bufnr)
                            -- add custom key bindings if needed
                        end,
                    })
                end,

                ["jdtls"] = function()
                    local lspconfig = require("lspconfig")
                    local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
                    local jdtls_path = require("mason-registry").get_package("jdtls"):get_install_path()
                     -- Paths to debug and test JARs
                    local java_debug_path = "/home/jelle-jacobs/.config/nvim/com.microsoft.java.debug.plugin-*.jar"
                    local java_test_path = "/home/jelle-jacobs/.config/nvim/server/*.jar"

                    -- Prepare the bundles
                    local bundles = {
                        vim.fn.glob(java_debug_path, true), -- Debugging JAR
                    }
                    vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path, true), "\n")) -- Testing JARs

                    lspconfig.jdtls.setup({
                        cmd = {
                            "java", -- Adjust if needed
                            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
                            "-Dosgi.bundles.defaultStartLevel=4",
                            "-Declipse.product=org.eclipse.jdt.ls.core.product",
                            "-Dlog.level=ALL",
                            "-javaagent:" .. jdtls_path .. "/lombok.jar",
                            "-Xms1g",
                            "--add-modules=ALL-SYSTEM",
                            "--add-opens", "java.base/java.util=ALL-UNNAMED",
                            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
                            "-jar", vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
                            "-configuration", jdtls_path .. "/config_" .. vim.loop.os_uname().sysname:lower(),
                            "-data", workspace_dir,
                        },
                        root_dir = require("lspconfig.util").root_pattern(".git", "mvnw", "gradlew", "pom.xml", "build.gradle"),
                        capabilities = capabilities,
                        init_options = {
                            bundles = bundles,
                        },
                        settings = {
                            java = {
                                configuration = {
                                    runtimes = {
                                        {
                                            name = "JavaSE-21",
                                            path = "/usr/lib/jvm/java-21-openjdk-amd64",
                                        },
                                        {
                                            name = "JavaSE-17",
                                            path = "/usr/lib/jvm/java-17-openjdk-amd64", -- Update to your Java 17 path
                                        },
                                    }
                                }
                            }
                        },
                    })
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
