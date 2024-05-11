function updateTable(t1, t2)
  for key, value in pairs(t2) do
    if type(value or false) == 'table' then
      updateTable(t1[key] or {}, t2[key] or {})
    else
      t1[key] = value
    end
  end
end

return {
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },
  {
    -- for lsp features in code cells / embedded code
    'jmbuhr/otter.nvim',
    dev = false,
    dependencies = {
      {
        'neovim/nvim-lspconfig',
        'nvim-treesitter/nvim-treesitter',
        'hrsh7th/nvim-cmp',
        'onsails/lspkind-nvim',
      },
    },
    opts = {
      lsp = {
        hover = {
          -- border = require('misc.style').border.
        },
      },
      buffers = {
        set_filetype = true,
        write_to_disk = false,
      },
      handle_leading_whitespace = true,
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { -- nice loading notifications
        -- PERF: but can slow down startup
        'j-hui/fidget.nvim',
        enabled = false,
        opts = {},
      },
      { 'folke/neodev.nvim', opts = {}, enabled = true },
      { 'folke/neoconf.nvim', opts = {}, enabled = false },
    },
    config = function()
      -------------------------------------------------------------------------
      -- NOTE: Setup and activae otter.
      local otter = require 'otter'
      otter.setup()
      otter.activate({ 'python', 'javascript' }, true, true, nil)

      -------------------------------------------------------------------------
      -- NOTE: Install dependencies.
      require('mason').setup()
      require('mason-lspconfig').setup {
        automatic_installation = true,
      }
      require('mason-tool-installer').setup {
        ensure_installed = {
          'black',
          'stylua',
          'shfmt',
          'isort',
          'tree-sitter-cli',
        },
      }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local telescope = require 'telescope.builtin'
          local function map(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          assert(client, 'LSP client not found')

          ---@diagnostic disable-next-line: inject-field
          client.server_capabilities.document_formatting = true

          map('gS', telescope.lsp_document_symbols, '[g]o so [S]ymbols')
          map('gD', telescope.lsp_type_definitions, '[g]o to type [D]efinition')
          map('gd', telescope.lsp_definitions, '[g]o to [d]efinition')
          map('K', '<cmd>lua vim.lsp.buf.hover()<CR>', '[K] hover documentation')
          map('gh', '<cmd>lua vim.lsp.buf.signature_help()<CR>', '[g]o to signature [h]elp')
          map('gI', telescope.lsp_implementations, '[g]o to [I]mplementation')
          map('gr', telescope.lsp_references, '[g]o to [r]eferences')
          map('[d', vim.diagnostic.goto_prev, 'previous [d]iagnostic ')
          map(']d', vim.diagnostic.goto_next, 'next [d]iagnostic ')
          map('<leader>ll', vim.lsp.codelens.run, '[l]ens run')
          map('<leader>lR', vim.lsp.buf.rename, '[l]sp [R]ename')
          map('<leader>lf', vim.lsp.buf.format, '[l]sp [f]ormat')
          map('<leader>lq', vim.diagnostic.setqflist, '[l]sp diagnostic [q]uickfix')
        end,
      })

      -------------------------------------------------------------------------
      -- NOTE: LSP Startup and Configuration.

      local lspconfig = require 'lspconfig'
      local luasnip = require 'luasnip'
      local util = require 'lspconfig.util'

      luasnip.config.setup {}
      vim.lsp.set_log_level 'info'

      local lsp_flags = {
        allow_incremental_sync = true,
        debounce_text_changes = 150,
      }
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = require('misc.style').border })
      vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = require('misc.style').border })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      lspconfig.lua_ls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            runtime = {
              version = 'LuaJIT',
              -- plugin = lua_plugin_paths,
            },
            diagnostics = {
              globals = { 'vim', 'quarto', 'pandoc', 'io', 'string', 'print', 'require', 'table' },
              disable = { 'trailing-space' },
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
      }

      lspconfig.bashls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'sh', 'bash' },
      }

      lspconfig.cssls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.html.setup {
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.emmet_language_server.setup {
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.yamlls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = '',
            },
          },
        },
      }

      lspconfig.dotls.setup {
        capabilities = capabilities,
        flags = lsp_flags,
      }

      lspconfig.tsserver.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        filetypes = { 'js', 'javascript', 'typescript', 'ojs' },
      }

      local function get_quarto_resource_path()
        local function strsplit(s, delimiter)
          local result = {}
          for match in (s .. delimiter):gmatch('(.-)' .. delimiter) do
            table.insert(result, match)
          end
          return result
        end

        local f = assert(io.popen('quarto --paths', 'r'))
        local s = assert(f:read '*a')
        f:close()
        return strsplit(s, '\n')[2]
      end

      local lua_library_files = vim.api.nvim_get_runtime_file('', true)
      local lua_plugin_paths = {}
      local resource_path = get_quarto_resource_path()
      if resource_path == nil then
        vim.notify_once 'quarto not found, lua library files not loaded'
      else
        table.insert(lua_library_files, resource_path .. '/lua-types')
        table.insert(lua_plugin_paths, resource_path .. '/lua-plugin/plugin.lua')
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

      lspconfig.pyright.setup {
        capabilities = capabilities,
        flags = lsp_flags,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'workspace',
            },
          },
        },
        root_dir = function(fname)
          return util.root_pattern('.git', 'setup.py', 'setup.cfg', 'pyproject.toml', 'requirements.txt')(fname) or util.path.dirname(fname)
        end,
      }
    end,
  },
  -------------------------------------------------------------------------
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-emoji',
      'f3fora/cmp-spell',
      'ray-x/cmp-treesitter',
      'kdheepak/cmp-latex-symbols',
      'jmbuhr/cmp-pandoc-references',
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
      'onsails/lspkind-nvim',
      'jmbuhr/otter.nvim',
    },
    config = function()
      -- NOTE: Setup completion now that the LSP servers have been configured.
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      local lspkind = require 'lspkind'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm { select = true },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        formatting = {
          format = lspkind.cmp_format {
            mode = 'symbol',
            menu = {
              otter = '[🦦]',
              nvim_lsp = '[LSP]',
              luasnip = '[snip]',
              buffer = '[buf]',
              path = '[path]',
              spell = '[spell]',
              pandoc_references = '[ref]',
              tags = '[tag]',
              treesitter = '[TS]',
              calc = '[calc]',
              latex_symbols = '[tex]',
              emoji = '[emoji]',
            },
          },
        },
        sources = {
          { name = 'otter' }, -- for code chunks in quarto
          { name = 'path' },
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
          { name = 'luasnip', keyword_length = 3, max_item_count = 3 },
          { name = 'pandoc_references' },
          { name = 'buffer', keyword_length = 5, max_item_count = 3 },
          { name = 'spell' },
          { name = 'treesitter', keyword_length = 5, max_item_count = 3 },
          { name = 'calc' },
          { name = 'latex_symbols' },
          { name = 'emoji' },
        },
        view = {
          entries = 'native',
        },
      }

      -- `/` cmdline setup.
      -- cmp.setup.cmdline('/', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = {
      --     { name = 'buffer' },
      --   },
      -- })

      -- `:` cmdline setup.
      -- cmp.setup.cmdline(':', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources {
      --     { name = 'path' },
      --   },
      -- })
    end,
  },
}
