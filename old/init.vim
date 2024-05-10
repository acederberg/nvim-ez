set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc



" =============================================================================
"  LUA
"
source /home/adrian/.config/nvim/extra.lua
lua <<EOF


  -- UTILITY FUNCTIONS --------------------------------------------------------

  function updateTable(t1, t2)
    for key,value in pairs(t2) do
      if type(value or false) == "table" then
        updateTable(t1[key] or {}, t2[key] or {})
      else
        t1[key] = value
      end
    end
  end


  -- PACKER INSTALLS ----------------------------------------------------------

  require('packer').startup(
    function(use)
      -- For quarto.lua
      use 'benlubas/molten-nvim'
      use 'byuki/nabla.nvim'
      use 'HakonHarnes/img-clip.nvim'
      use 'jpalardy/vim-slime'
      use 'GCBallesteros/jupytext.nvim'
      use 'jpalardy/vim-slime'
      use 'wbthomason/packer.nvim'
      use 'quarto-dev/quarto-nvim'
      use 'jmbuhr/otter.nvim' -- dependency of quarto ^^^

      -- Colors ---------------------------------------------------------------

      use 'rebelot/kanagawa.nvim'
      use 'folke/tokyonight.nvim'
      use 'vim-airline/vim-airline'
      use 'vim-airline/vim-airline-themes'
      use 'nvim-treesitter/nvim-treesitter'
      use 'nvim-treesitter/playground'
      use "terrortylor/nvim-comment"


      -- Git ------------------------------------------------------------------

      use 'tpope/vim-fugitive'
      use 'sindrets/diffview.nvim'
      use 'nvim-tree/nvim-web-devicons'


      -- Autocompletion And Suggestions ---------------------------------------

      use 'nvim-lua/plenary.nvim'
      use({
        -- Isort, black
        "jose-elias-alvarez/null-ls.nvim",
        config = function() require("null-ls").setup() end,
        requires = { "nvim-lua/plenary.nvim" },
      })
      use 'nvim-telescope/telescope.nvim'


      use 'neovim/nvim-lspconfig'
      use 'hrsh7th/cmp-nvim-lsp'
      use 'hrsh7th/cmp-buffer'
      use 'hrsh7th/cmp-path'
      use 'hrsh7th/cmp-cmdline'
      use 'hrsh7th/nvim-cmp'
      use 'hrsh7th/cmp-vsnip'
      use 'hrsh7th/vim-vsnip'
      use 'saadparwaiz1/cmp_luasnip' -- Snippets source for nvim-cmp
      use 'L3MON4D3/LuaSnip' -- Snippets plugin


      -- ETC ------------------------------------------------------------------

      use 'preservim/tagbar'

    end
  )

  -- IMPORTS ==================================================================

  -- Treesitter ---------------------------------------------------------------
  --
  -- Custom queries must be defined in runtime queries folder. For more
  -- information please see the following links:
  --
  -- https://github.com/nvim-treesitter/nvim-treesitter#advanced-setup
  -- https://alpha2phi.medium.com/neovim-tips-for-a-better-coding-experience-3d0f782f034e

  require'nvim-treesitter.configs'.setup{
    ensure_installed={"terraform", "python", "c", "lua", "vim"},
    highlight={
      enable=true,
      custom_captures = {["import_statement"] = "pythonDecorators"}
    },
    playground = {
      enable = true,
      disable = {},
      updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = 'o',
        toggle_hl_groups = 'i',
        toggle_injected_languages = 't',
        toggle_anonymous_nodes = 'a',
        toggle_language_display = 'I',
        focus_language = 'f',
        unfocus_language = 'F',
        update = 'R',
        goto_node = '<cr>',
        show_help = '?',
      }
    }
  }

  -- Language Server, Comments, And Autocompletion ----------------------------
  -- Read the following:
  -- https://github.com/hrsh7th/nvim-cmp/
  -- https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion
  -- https://github.com/neovim/nvim-lspconfig
  -- https://github.com/mjlbach/starter.nvim/blob/master/init.lua

  require('nvim_comment').setup()
  require'null-ls'

  local lspconfig = require('lspconfig')
  local cmp = require('cmp')

  local luasnip = require('luasnip')
  luasnip.config.setup{}
  vim.lsp.set_log_level("info")

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
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(
        function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
        end,
        { 'i', 's' }
      ),
      ['<S-Tab>'] = cmp.mapping(
        function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end,
        { 'i', 's' }
      ),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        {name = 'buffer'},
      }
    )
  })


  -- `/` cmdline setup.
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- `:` cmdline setup.
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  local lspservers = {'pyright', 'jedi_language_server', 'tsserver', }

  for _, lsp in ipairs(lspservers) do
    lspconfig[lsp].setup {
      capabilities = capabilities,
    }
  end


  -- Show line diagnostics automatically in hover window
  -- vim.o.updatetime = 10
  -- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]


  -- ==========================================================================
  -- LSP Config for GO
  -- https://www.getman.io/posts/programming-go-in-neovim/

  lspconfig.gopls.setup{
    cmd = {'gopls'},
    -- for postfix snippets and analyzers
    capabilities = capabilities,
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = {
          unusedparams = true,
          shadow = true,
       },
       staticcheck = true,
      },
    }
  }


  -- Theme --------------------------------------------------------------------

  require("kanagawa").setup{
    commentStyle = { italic = true },
    overrides = function(colors)

      base = {
          -- Text.
          Boolean = { fg = colors.palette.autumnYellow, italic = false, bold = true },
          String = { fg = colors.palette.oniViolet, italic = true},
          Keyword = { fg = colors.palette.boatYellow2, bold = false, italic = false },
          Normal = {fg = colors.palette.boatYellow1, bold = false, italic = false},
          Constant = {fg = colors.palette.carpYellow, bold = true, italic = true},
          Identifier = {fg = colors.palette.oldWhite},
          PreProc = {fg = colors.palette.boatYellow2, bold = true},
          Statement = {fg = colors.palette.roninYellow, bold = true},
          Type = {fg = colors.palette.springGreen, bold = true},
          Function = {fg = colors.palette.autumnYellow, bold = false},
          Special = {fg=colors.palette.sakuraPink, bold = true}

          -- Airline

      }

      amendments = {
        python = {
          Constant = {fg = colors.palette.lotusYellow3, bold = true, italic = true},
        },
        terraform = {
          Type = {fg = colors.palette.springGreen, bold = true},
          String = { fg = colors.palette.autumnGreen},
          Identifier = {fg = colors.palette.surimiOrange},
          Normal = {fg = colors.palette.samuraiRed},
          Keyword = {fg=colors.palette.lightBlue, bold = true},
          Function = {fg=colors.palette.peachRed, bold = true},
        }
      }

      -- ft = vim.bo.filetype
      updateTable(base, amendments["terraform"])
      return base

    end,
  }


EOF


" =============================================================================
" VIMSCRIPT

nnoremap &a :call<SPACE>SourceConfig()<CR>


" Output the current syntax group

highlight pythonDecorators guifg=Red guibg=Red
highlight pythonImportStatements guibg=Orange ctermbg=202
colorscheme kanagawa-wave

set termguicolors
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE




" -----------------------------------------------------------------------------
" Airline
"
" Themes here:
" - https://github.com/vim-airline/vim-airline/wiki/Screenshots

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts=1
let g:airline_theme='wombat'
" let g:airline_solarized_bg='dark'
" let g:airline_theme='solarized'



