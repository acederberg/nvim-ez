-- local mason = require("mason-registry")
--
-- function installIfNotInstalled(name)
--   local pkg = mason.get_package("debugpy")
--   if not pkg:is_installed() then
--     pkg:install()
--   end
-- end

return {
  -----------------------------------------------------------------------------
  ---
  --- LUA neovim configuration helpers.
  ---
  --- Defines the `LazyDev` command.
  ---
  {
    "folke/lazydev.nvim",
    tag = "v1.10.0",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- {
  --   "folke/neoconf.nvim",
  --   opts = {},
  --   enabled = false,
  -- },
  {
    "jmbuhr/otter.nvim",
    -- tag="v1.15.1",
    filetypes = { "markdown", "html", "quarto" },
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
      otter.setup({})
    end,
  },

  {
    "neovim/nvim-lspconfig",
    tag = "v2.7.0",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "folke/lazydev.nvim",
      "folke/which-key.nvim",
      -- "folke/neoconf",
    },
    config = function()
      -------------------------------------------------------------------------
      -- NOTE: Install dependencies.

      local wk = require("which-key")
      local settings = require("conf.settings").default_settings()

      -- require("mason-lspconfig").setup({ automatic_installation = true })

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

          map("gd", telescope.lsp_definitions, "[g]o to [d]efinition")

          wk.add({
            -- lsp
            {
              { "@@l", group = "[l]sp" },
              {
                { "@@lg", group = "[l]sp [g]o." },
                { "@@lgi", telescope.lsp_implementations, desc = "[l]sp [g]o to [I]mplementation", mode = "in" },
                { "@@lgr", telescope.lsp_references, desc = "[l]sp [g]o to [r]eferences", mode = "in" },
                { "@@lgS", telescope.lsp_document_symbols, desc = "[l]sp [g]o so [S]ymbols" },
                { "@@lgD", telescope.lsp_type_definitions, desc = "[l]sp [g]o to [T]ype definition" },
                { "@@lgd", telescope.lsp_definitions, desc = "[l]sp [g]o to [d]efinition" },
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
              {
                "@@dn",
                function()
                  vim.diagnostic.jump({ count = 1 })
                end,
                desc = "[d]iagnostic [n]ext",
                mode = "in",
              },
              {
                "@@dp",
                function()
                  vim.diagnostic.jump({ count = -1 })
                end,
                desc = "[d]iagnostic [p]rev",
                mode = "in",
              },
              { "@@ds", vim.diagnostic.open_float, desc = "[d]iagnostic [s]how", mode = "in" },
              { "@@df", vim.diagnostic.setqflist, desc = "[l]sp diagnostic [q]uickfix", mode = "in" },
              { "@@dl", telescope.diagnostics, desc = "[d]iagnositics [l]ist", mode = "in" },
            },
          })
        end,
      })

      -------------------------------------------------------------------------
      -- NOTE: LSP Startup and Confsiguration.

      local luasnip = require("luasnip")
      local util = require("lspconfig.util")

      luasnip.config.setup({})

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
        vim.lsp.config("lua_ls", {
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

      vim.lsp.config("bashls", {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "sh", "bash" },
      })

      if settings.languages.haskell then
        vim.lsp.config("hls", {
          filetypes = { "haskell", "lhaskell", "cabal" },
        })
      end

      if settings.languages.css then
        vim.lsp.config("cssls", {
          capabilities = capabilities,
          flags = lsp_flags,
        })
        vim.lsp.config("somesass_ls", {})
      end

      if settings.languages.html then
        vim.lsp.config("html", {
          capabilities = capabilities,
          flags = lsp_flags,
        })
        vim.lsp.config("emmet_language_server", {
          capabilities = capabilities,
          flags = lsp_flags,
        })
      end

      if settings.languages.markdown or settings.languages.quarto then
        vim.lsp.config("marksman", {
          capabilities = capabilities,
          lsp_flags = lsp_flags,
          filetypes = { "markdown", "quarto" },
          root_dir = util.root_pattern(".git", ".marksman.toml", "_quarto.yml"),
        })
      end

      if settings.languages.quarto then
        vim.lsp.config("dotls", {
          capabilities = capabilities,
          flags = lsp_flags,
          settings = {
            yaml = {
              schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.27.0-standalone-strict/all.json"] = "k8s*.yaml",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
                  "compose.yaml",
                  "compose.*.yaml",
                  "_compose.*.yaml",
                },
                ["https://raw.githubusercontent.com/SchemaStore/schemastore/refs/heads/master/src/schemas/json/traefik-v3-file-provider.json"] = {
                  "traefik.ya?ml",
                  "traefik.*.ya?ml",
                },
              },
              schemaStore = {
                enable = false, -- disable built-in schema store to avoid applying unrelated schemas
              },
            },
          },
        })
      end

      if settings.languages.typescript then
        vim.lsp.config("ts_ls", {
          capabilities = capabilities,
          flags = lsp_flags,
          filetypes = { "js", "javascript", "typescript", "ojs", "typescriptreact" },
        })
      end

      if settings.languages.prisma then
        vim.lsp.config("prismals", {})
      end

      if settings.languages.go then
        vim.lsp.config("gopls", {
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
        vim.lsp.config("csharp_ls", {})
      end

      vim.lsp.config("clangd", {
        cmd = { "nc", "localhost", "2087" },
        capabilities = capabilities,
      })

      if settings.languages.sass then
        vim.lsp.config("somesass_ls", {})
        if capabilities.workspace == nil then
          capabilities.workspace = {}
          capabilities.workspace.didChangeWatchedFiles = {}
        end
        capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
      end

      if settings.languages.terraform then
        vim.lsp.config("terraformls", {
          capabilities = capabilities,
          settings = {},
        })

        vim.api.nvim_create_autocmd({ "BufWritePre" }, {
          pattern = { "*.tf", "*.tfvars" },
          callback = function()
            vim.lsp.buf.format()
          end,
        })
      end

      -- See https://github.com/neovim/neovim/issues/23291
      -- disable lsp watcher.
      if settings.languages.python then
        vim.lsp.config("ruff", {
          init_options = {
            settings = {
              args = {},
            },
          },
        })
        vim.lsp.enable("ruff")
        --
        -- vim.lsp.config("mypy",{})
        -- turning this on breaks python diagnostics in nvim.
        -- vim.lsp.config("pylsp",{
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

        vim.lsp.config("pyright", {
          enabled = true,
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
          -- root_dir = function(fname)
          --   return util.root_pattern(".git", "setup.py", "setup.cfg", "pyproject.toml", "requirements.txt")(fname)
          --     or vim.fs.dirname(fname)
          -- end,
        })
      end
      vim.lsp.enable("pyright")
    end,
  },
}
