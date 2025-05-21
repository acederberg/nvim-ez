-- local on_attach2 = function(client, bufnr)
--   local function buf_set_keymap(...)
--     vim.api.nvim_buf_set_keymap(bufnr, ...)
--   end
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
--   local opts = { noremap = true, silent = true }
--
--   buf_set_keymap("n", "gD", "<cmd>Telescope lsp_type_definitions<CR>", opts)
--   buf_set_keymap("n", "gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
--   buf_set_keymap("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
--   buf_set_keymap("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
--   buf_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
--   buf_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
--   buf_set_keymap("n", "<Leader>ll", "<cmd>lua vim.lsp.codelens.run()<CR>", opts)
--
--   client.server_capabilities.document_formatting = true
-- end

return {
  {
    "nvim-telescope/telescope.nvim",
    -- tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "jmbuhr/otter.nvim",
    -- tag="v1.15.1",
    dependencies = {
      {
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
        "hrsh7th/nvim-cmp",
        "onsails/lspkind-nvim",
      },
    },
    config = function()
      -- NOTE: For otter to appear under cmp status, a nested document must be
      --       loaded.
      local otter = require("otter")
      otter.setup({
        -- debug = true,
        -- buffers = { write_to_disk = true, set_filetype = true },
        -- verbose = { -- set to false to disable all verbose messages
        --   no_code_found = true, -- warn if otter.activate is called, but no injected code was found
        -- },
      })
      -- lsp = {
      --   diagnostics_update_events = { "BuffWritePost" },
      --   root_dir = function(_, bufnr)
      --     return vim.fs.root(bufnr or 0, {
      --       ".git",
      --       "_quarto.yml",
      --       "package.json",
      --     }) or vim.fn.getcwd(0)
      --   end,
      -- },
      -- buffers = {
      --   set_filetype = true,
      --   write_to_disk = false,
      -- },
      -- handle_leading_whitespace = true,

      -- NOTE: From the readme. This can be used to show the current languages
      --       in the raft.
      local function get_otter_symbols_lang()
        local otterkeeper = require("otter.keeper")
        local main_nr = vim.api.nvim_get_current_buf()
        local langs = {}
        for i, l in ipairs(otterkeeper.rafts[main_nr].languages) do
          langs[i] = i .. ": " .. l
        end
        vim.print("langs", langs)
      end

      -- vim.keymap.set("n", "@@ps", get_otter_symbols_lang, { desc = "otter [s]ymbols" })
    end,
  },
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()

      local mason= require("mason-registry")
      local pkg = mason.get_package("debugpy")
      if (not pkg:is_installed()) then pkg:install() end
    end
  },
  {
    "neovim/nvim-lspconfig",
    -- tag="v0.1.9",
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "WhoIsSethDaniel/mason-tool-installer.nvim" },
      { -- nice loading notifications
        -- PERF: but can slow down startup
        "j-hui/fidget.nvim",
        enabled = false,
        opts = {},
      },
      { "folke/neodev.nvim", opts = {}, enabled = true },
      { "folke/neoconf.nvim", opts = {}, enabled = false },
      "folke/which-key.nvim",
    },
    config = function()
      -------------------------------------------------------------------------
      -- NOTE: Install dependencies.
      local wk = require("which-key")
      local settings = require("conf.settings").default_settings()


      -- vim.print(settings.default_settings())
      -- vim.print(settings)

      require("mason-lspconfig").setup({ automatic_installation = true });
      require("mason-tool-installer").setup({
        ensure_installed = {
          "mypy",
          "black",
          "stylua",
          "shfmt",
          "isort",
          "tree-sitter-cli",
          "ruff",
          "terraform-ls",
          "jupytext",
          "yamlfmt",
          "jq",
          -- "magick",
          "prettier", -- If you want plugins, they must be installed locallaly. https://github.com/williamboman/mason.nvim/issues/392
        },
      })

      -- NOTE: According to the documentation this should run automaticlly when
      --       any file is opened with nvim. For more on the topic see the
      --       following:
      --
      --       .. code:: txt
      --
      --          [1] https://neovim.io/doc/user/autocmd.html#autocommand
      --          [2] https://neovim.io/doc/user/api.html#nvim_create_autocmd()
      --
      --       From [1] it is evident that the group is used to not reproduce
      --       the command every time nvim configuration is sourced. Autocommands
      --       defined below may be listed in normal mode using
      --       ``:autocmd config-plugins-lsp``
      --
      --
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("config-plugins-lsp", { clear = true }),
        callback = function(event)
          local telescope = require("telescope.builtin")
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          vim.diagnostic.config({
            virtual_text = {
              source = true,
            },
            open_float = {
              source = true,
            },
            severity_sort = true,
          })

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, "LSP client not found")

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          map("gS", telescope.lsp_document_symbols, "[g]o so [S]ymbols")
          map("gD", telescope.lsp_type_definitions, "[g]o to type [D]efinition")
          map("gd", telescope.lsp_definitions, "[g]o to [d]efinition")

          wk.add({
            -- lsp
            {
              { "@@l", group = "[l]sp" },
              {
                { "@@lg", group = "[l]sp [g]o." },
                { "@@lgi", telescope.lsp_implementations, desc = "[l]sp [g]o to [I]mplementation", mode = "in" },
                { "@@lgr", telescope.lsp_references, desc = "[l]sp [g]o to [r]eferences", mode = "in" },
              },
              { "@@lsd", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "[l]sp [s]how [d]ocumentation", mode = "in" },
              {
                "@@lsh",
                function()
                  vim.lsp.buf.signature_help()
                end,
                desc = "[l]sp [s]ignature [h]elp",
                mode = "in",
              },
              { "@@ll", vim.lsp.codelens.run, desc = "[l]sp [l]ens run", mode = "in" },
              { "@@lr", vim.lsp.buf.rename, desc = "[l]sp [r]ename", mode = "in" },
              { "@@lf", vim.lsp.buf.format, desc = "[l]sp [f]ormat", mode = "in" },
            },
            -- diagnostics
            {
              { "@@d", group = "[d]iagnostic" },
              { "@@dn", vim.diagnostic.goto_next, desc = "[d]iagnostic [n]ext", mode = "in" },
              { "@@dp", vim.diagnostic.goto_prev, desc = "[d]iagnostic [p]rev", mode = "in" },
              { "@@ds", vim.diagnostic.open_float, desc = "[d]iagnostic [s]how", mode = "in" },
              { "@@df", vim.diagnostic.setqflist, desc = "[l]sp diagnostic [q]uickfix", mode = "in" },
              -- { "@@lds", telescope.diagnostics, desc = "[d]iagnositics [s]how", mode = "in" },
            },
          })
        end,
      })

      -------------------------------------------------------------------------
      -- NOTE: LSP Startup and Configuration.

      local lspconfig = require("lspconfig")
      local luasnip = require("luasnip")
      local util = require("lspconfig.util")

      luasnip.config.setup({})
      vim.lsp.set_log_level("info")

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }
      vim.lsp.handlers["textDocument/hover"] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = require("misc.style").border })
      vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = require("misc.style").border })

      -- NOTE: Author removed this from their readme. Still does not work.
      --       To see that it does not work, notice that ``:CmpStatus`` does
      --       shows ``nvim_lsp`` as an unknown completion source.
      --
      --       Calling setup does not seem to resolve these issues either.
      --
      --       What seems to (spontaniously) lead to this loading is writing to
      --       the current buffer.
      --
      -- local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
      --
      --
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      if settings.languages.lua then
        lspconfig.lua_ls.setup({
          capabilities = capabilities,
          flags = lsp_flags,
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
              runtime = {
                version = "LuaJIT",
                -- plugin = lua_plugin_paths,
              },
              diagnostics = {
                globals = { "vim", "quarto", "pandoc", "io", "string", "print", "require", "table" },
                disable = { "trailing-space" },
              },
              workspace = {
                -- library = lua_library_files,
                checkThirdParty = false,
              },
              telemetry = {
                enable = false,
              },
            },
          },
        })
      end

      lspconfig.bashls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "sh", "bash" },
      })

      if settings.languages.haskell then
      require("lspconfig")["hls"].setup({
        filetypes = { "haskell", "lhaskell", "cabal" },
      })
      end

      if settings.languages.css then
        lspconfig.cssls.setup({
          capabilities = capabilities,
          flags = lsp_flags,
        })
        lspconfig.somesass_ls.setup({})
      end

      if settings.languages.html then
        lspconfig.html.setup({
          capabilities = capabilities,
          flags = lsp_flags,
        })
        lspconfig.emmet_language_server.setup({
          capabilities = capabilities,
          flags = lsp_flags,
        })

      end

      if settings.languages.markdown or settings.languages.quarto  then
        lspconfig.marksman.setup({
          capabilities = capabilities,
          lsp_flags = lsp_flags,
          filetypes = { "markdown", "quarto" },
          root_dir = util.root_pattern(".git", ".marksman.toml", "_quarto.yml"),
        })
      end

      if settings.languages.yaml then
        lspconfig.yamlls.setup({
          capabilities = capabilities,
          flags = lsp_flags,
        })
      end
      if settings.languages.quarto then
        lspconfig.dotls.setup({
          capabilities = capabilities,
          flags = lsp_flags,
        settings = {
          yaml = {
            schemas = {
              ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.0-standalone-strict/all.json"] = "k8s*.yaml",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "compose.yaml",
            },
            schemaStore = {
              enable = false, -- disable built-in schema store to avoid applying unrelated schemas
            },
          },
        },
        })
      end

      if settings.languages.typescript then
        lspconfig.ts_ls.setup({
          capabilities = capabilities,
          flags = lsp_flags,
          filetypes = { "js", "javascript", "typescript", "ojs", "typescriptreact" },
        })
      end


      if settings.languages.prisma then
        lspconfig.prismals.setup({})
      end

      if settings.languages.go then
        lspconfig.gopls.setup({
          -- on_attach = on_attach,
          capabilities = capabilities,
          cmd = { "gopls" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          root_dir = util.root_pattern("go.work", "go.mod", ".git"),
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = true,
              analyses = {
                unusedparams = true,
              },
            },
          },
        })
      end

      if settings.languages.csharp then
        lspconfig.csharp_ls.setup({})
      end

      -- turning this on breaks python diagnostics in nvim.
      -- lspconfig.pylsp.setup({
      --   settings = {
      --     pylsp = {
      --       plugins = {
      --         pycodestyle = { enabled = false },
      --         -- type checker
      --         pylsp_mypy = {
      --           enabled = true,
      --           report_progess = true,
      --         },
      --         -- auto-completion options
      --         jedi_completion = { enabled = true, fuzzy = true },
      --         -- import sorting
      --         pyls_isort = { enabled = true },
      --       },
      --     },
      --   },
      -- })

      local function get_quarto_resource_path()
        local function strsplit(s, delimiter)
          local result = {}
          for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
            table.insert(result, match)
          end
          return result
        end

        local f = assert(io.popen("quarto --paths", "r"))
        local s = assert(f:read("*a"))
        f:close()
        return strsplit(s, "\n")[2]
      end

      local lua_library_files = vim.api.nvim_get_runtime_file("", true)
      local lua_plugin_paths = {}
      local resource_path = get_quarto_resource_path()
      if resource_path == nil then
        vim.notify_once("quarto not found, lua library files not loaded")
      else
        table.insert(lua_library_files, resource_path .. "/lua-types")
        table.insert(lua_plugin_paths, resource_path .. "/lua-plugin/plugin.lua")
      end

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      -- Too lags on linux for python projects
      -- because pyright and nvim both create too many watchers otherwise

      lspconfig.somesass_ls.setup({})
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

      if settings.languages.python then
        vim.print("blah blah blah")

        -- lspconfig.ruff.setup({
        --   init_options = {
        --     settings = {
        --       args = {},
        --     },
        --   },
        -- })
        -- lspconfig.mypy.setup({})

        lspconfig.pyright.setup({
          capabilities = capabilities,
          flags = lsp_flags,
          settings = {
            python = {
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace",
              },
            },
          },
          root_dir = function(fname)
            return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
              or util.fs.dirname(fname)
          end,
        })
      end
    end,
  },
  -------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "f3fora/cmp-spell",
      "ray-x/cmp-treesitter",
      "kdheepak/cmp-latex-symbols",
      "jmbuhr/cmp-pandoc-references",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "onsails/lspkind-nvim",
      "jmbuhr/otter.nvim",
      "petertriho/cmp-git",
    },
    config = function()
      -- NOTE: Setup completion now that the LSP servers have been configured.
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol",
            menu = {
              otter = "[🦦]",
              nvim_lsp = "[LSP]",
              luasnip = "[snip]",
              buffer = "[buf]",
              path = "[path]",
              spell = "[spell]",
              pandoc_references = "[ref]",
              tags = "[tag]",
              treesitter = "[TS]",
              calc = "[calc]",
              latex_symbols = "[tex]",
              emoji = "[emoji]",
            },
          }),
        },
        sources = {
          -- { name = "otter" }, -- for code chunks in quarto
          { name = "path" },
          { name = "nvim_lsp" }, -- NOTE: Not loading. Why?
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip", keyword_length = 3, max_item_count = 3 },
          { name = "pandoc_references" },
          { name = "buffer", keyword_length = 5, max_item_count = 3 },
          { name = "spell" },
          { name = "treesitter", keyword_length = 5, max_item_count = 3 },
          { name = "calc" },
          { name = "latex_symbols" },
          { name = "emoji" },
        },
        view = {
          entries = "native",
        },
      })

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "git" },
        }, {
          { name = "buffer" },
        }),
      })

      require("cmp_git").setup()
      require("lspconfig").terraformls.setup({})
      vim.api.nvim_create_autocmd({ "BufWritePre" }, {
        pattern = { "*.tf", "*.tfvars" },
        callback = function()
          vim.lsp.buf.format()
        end,
      })

      -- `/` cmdline setup.
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      luasnip.filetype_extend("quarto", { "markdown", "markdown_inline" })
      luasnip.filetype_extend("rmarkdown", { "markdown", "markdown_inline" })
      -- `:` cmdline setup.
      -- cmp.setup.cmdline(":", {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources({
      --     { name = "path" },
      --   }, {
      --     { name = "cmdline" },
      --   }),
      --   ---@diagnostic disable-next-line: missing-fields
      --   matching = { disallow_symbol_nonprefix_matching = false },
      -- })
    end,
  },
  -- {
  --   "iabdelkareem/csharp.nvim",
  --   dependencies = {
  --     "williamboman/mason.nvim", -- Required, automatically installs omnisharp
  --     "mfussenegger/nvim-dap",
  --     "Tastyep/structlog.nvim", -- Optional, but highly recommended for debugging
  --   },
  --   config = function()
  --     require("mason")
  --     local config = {
  --       logging = {
  --         level = "TRACE",
  --       },
  --       lsp = {
  --         omnisharp = {
  --           enable = true,
  --           enable_editor_config_support = true,
  --           organize_imports = true,
  --           load_projects_on_demand = false,conf
  --           enable_analyzers_support = true,
  --           enable_import_completion = true,
  --           include_prerelease_sdks = true,
  --           analyze_open_documents_only = false,
  --           default_timeout = 1000,
  --           enable_package_auto_restore = true,
  --           debug = false,
  --           --- @type string?
  --           cmd_path = "",
  --         },
  --       },
  --     }
  --
  --     -- local cs = require("csharp")
  --     -- -- ~/.local/state/nvim/csharp.log
  --     --
  --     -- local logger = require("structlog").get_logger("csharp_logger")
  --     -- logger:warn("It works!")
  --     --
  --     -- vim.keymap.set("n", "@@dbgr", function()
  --     --   -- cs.debug_project()
  --     --   local it = require("csharp.modules.lsp.omnisharp")
  --     --   it.start_omnisharp(vim.api.nvim_get_current_buf())
  --     -- end, { desc = "dotnet[dbgr]." })
  --     --
  --     -- -- vim.keymap.set("n", "@@cslogs", function()
  --     -- --   vim.fn.stdpath("log") .. "/csharp.log"
  --     -- -- end, {desc = ""})
  --     -- vim.print(config)
  --
  --     csharp_config = require("csharp.config")
  --     config = csharp_config.set_defaults(config)
  --     csharp_config.save(config)
  --
  --     -- vim.print("=-----------------------------------------")
  --     -- vim.print(csharp_config.get_config())
  --
  --     vim.api.nvim_create_autocmd("FileType", {
  --       pattern = "cs",
  --       callback = function(args)
  --         local it = require("csharp.modules.lsp.omnisharp")
  --         it.setup()
  --       end,
  --     })
  --   end,
  -- },
}
