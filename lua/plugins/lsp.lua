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

      vim.keymap.set("n", "@@ps", get_otter_symbols_lang, { desc = "otter [s]ymbols" })
    end,
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
    },
    config = function()
      -------------------------------------------------------------------------
      -- NOTE: Install dependencies.
      require("mason").setup()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
      require("mason-tool-installer").setup({
        ensure_installed = {
          "mypy",
          "black",
          "stylua",
          "shfmt",
          "isort",
          "tree-sitter-cli",
          "ruff",
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

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, "LSP client not found")

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          map("gS", telescope.lsp_document_symbols, "[g]o so [S]ymbols")
          map("gD", telescope.lsp_type_definitions, "[g]o to type [D]efinition")
          map("gd", telescope.lsp_definitions, "[g]o to [d]efinition")
          map("K", "<cmd>lua vim.lsp.buf.hover()<CR>", "[K] hover documentation")
          map("gh", "<cmd>lua vim.lsp.buf.signature_help()<CR>", "[g]o to signature [h]elp")
          map("gI", telescope.lsp_implementations, "[g]o to [I]mplementation")
          map("gr", telescope.lsp_references, "[g]o to [r]eferences")
          map("[d", vim.diagnostic.goto_prev, "previous [d]iagnostic ")
          map("]d", vim.diagnostic.goto_next, "next [d]iagnostic ")
          map("<leader>ll", vim.lsp.codelens.run, "[l]ens run")
          map("<leader>lR", vim.lsp.buf.rename, "[l]sp [R]ename")
          map("<leader>lf", vim.lsp.buf.format, "[l]sp [f]ormat")
          map("<leader>lq", vim.diagnostic.setqflist, "[l]sp diagnostic [q]uickfix")
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

      lspconfig.bashls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "sh", "bash" },
      })

      lspconfig.cssls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.html.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.emmet_language_server.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.marksman.setup({
        capabilities = capabilities,
        lsp_flags = lsp_flags,
        filetypes = { "markdown", "quarto" },
        root_dir = util.root_pattern(".git", ".marksman.toml", "_quarto.yml"),
      })

      lspconfig.yamlls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "",
            },
          },
        },
      })
      -- lspconfig.ruff.setup({
      --   init_options = {
      --     settings = {
      --       args = {},
      --     },
      --   },
      -- })
      -- lspconfig.mypy.setup({})

      lspconfig.dotls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
      })

      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { "js", "javascript", "typescript", "ojs" },
      })

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
      if capabilities.workspace == nil then
        capabilities.workspace = {}
        capabilities.workspace.didChangeWatchedFiles = {}
      end
      capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false

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
            or util.path.dirname(fname)
        end,
      })

      lspconfig.somesass_ls.setup({})
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
}
