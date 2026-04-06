return {
  -----------------------------------------------------------------------------
  ---
  --- Opening screen keyboard shortcuts and ASCII art.
  ---
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      local dashboard = require("alpha.themes.dashboard")

      -- NOTE: These should match the keymaps without the leaders (when keymaps exist).
      dashboard.section.buttons.val = {
        dashboard.button("pf", "󱑛 > Load a Session", ':lua require("persistence").select()<cr>'),
        dashboard.button("r", " > Recent", ":Telescope oldfiles<CR>"),
        dashboard.button("e", " > New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "󰈞 > Find file", ":Telescope find_files<CR>"),
        dashboard.button("s", " > Settings", ":e ~/.config/nvim/lua | :cd %:p:h<cr>"),
        dashboard.button("ze", "󱆃 > ZSH Settings", ":e ~/.zshrc<CR>"),
        dashboard.button("zo", " > Open a Terminal", ":e term://zsh<cr>"),
        dashboard.button("zs", " > Open a Terminal (Split)", ":split term://zsh<cr>"),
        dashboard.button("zv", " > Open a Terminal (Vertical)", ":vsplit term://zsh<cr>"),
        dashboard.button("gdo", " > Open Diffview", ":DiffviewOpen<CR>"),
        dashboard.button("gc", "󰜘 > Make a Commit", ":DiffviewOpen<CR>:Neogit commit<CR>ic"),
        dashboard.button("aa", "󱇯 Ask GPT", ":AvanteAsk<CR>"),
        dashboard.button("q", "󰅚 > Quit NVIM", ":qa<CR>"),
      }

      require("alpha").setup(dashboard.config)
    end,
  },
  -----------------------------------------------------------------------------
  ---
  --- General keyboard shortcuts.
  ---
  --- Put specific keyboard shortcuts with their respective plugins.
  ---
  {
    "folke/which-key.nvim",
    dependencies = {},
    config = function()
      local wk = require("which-key")
      wk.setup({
        triggers = {
          { "@@", mode = { "n", "v" } },
        },
      })

      wk.add({
        -- Helpful
        {
          { "@@z", group = "[z]sh" },
          { "@@zs", ":split term://zsh<CR>i", desc = "[z]sh [s]plit.", mode = "n" },
          { "@@zv", ":vsplit term://zsh<CR>i", desc = "[z]sh [v]split.", mode = "n" },
          { "@@zo", ":e term://zsh<CR>i", desc = "[z]sh [o]pen.", mode = "n" },
          { "@@ze", ":e ~/.zshrc", desc = "[z]shrc [e]dit.", mode = "n" },
        },
        {
          { "@@w", desc = "[w]indow" },
          {
            { "@@ws", group = "[w]indow [s]plit" },
            { "@@wsh", ":split .<CR>:Telescope oldfiles<CR>", desc = "[s]plit horizontal.", mode = "n" },
            { "@@wsv", ":vsplit .<CR>:Telescope oldfiles<CR>", desc = "[s]plit vertical.", mode = "n" },
          },
          {
            { "@@wm", group = "[w]indow [m]ove" },
            { "@@wml", ":wincmd H<CR>", desc = "[w]indow [m]ove [l]eft.", mode = "n" },
            { "@@wmr", ":wincmd L<CR>", desc = "[w]indow [m]ove [r]ight.", mode = "n" },
            { "@@wmu", ":wincmd K<CR>", desc = "[w]indow [m]ove [u]p.", mode = "n" },
            { "@@wmd", ":wincmd J<CR>", desc = "[w]indow [m]ove [d]own.", mode = "n" },
          },
        },
        {
          { "@@T", group = "[T]ab" },
          { "@@Tn", ":tabnext<cr>", desc = "[T]ab [n]ext.", mode = "n" },
          { "@@Tp", ":tabnext<cr>", desc = "[T]ab [p]revious.", mode = "n" },
          { "@@Tx", ":tabclose<cr>", desc = "[T]ab e[x]it.", mode = "n" },
        },
        {
          { "@@C", group = "[C]olors" },
          {
            "@@Ct",
            function()
              vim.cmd([[
                hi! Normal ctermbg=NONE guibg=NONE
                hi! NonText ctermbg=NONE guibg=NONE
              ]])
            end,
            desc = "[C]olors [t]ransparent bg.",
            mode = "n",
          },
          { "@@Cd", ":set bg=dark<cr>", desc = "[C]olors [d]ark mode.", mode = "n" },
          { "@@Cl", ":set bg=light<cr>", desc = "[C]olors [l]ight mode.", mode = "n" },
        },
      })

      -- https://neovim.io/doc/user/api.html#nvim_set_keymap()
    end,
  },
  {
    "folke/persistence.nvim",
    dependencies = {},
    config = function()
      local persistence = require("persistence")
      local wk = require("which-key")

      persistence.setup()

      wk.add({
        { "@@p", group = "[p]ersistence" },
        {
          "@@pl",
          function()
            persistence.load()
          end,
          desc = "[p]ersistence [l]oad",
          mode = "n",
        },
        {
          "@@pf",

          function()
            persistence.select()
          end,
          desc = "[p]ersistence [f]ind",
          mode = "n",
        },
        {
          "@@pp",
          function()
            persistence.load({ last = true })
          end,
          desc = "[p]ersistence [p]revious",
          mode = "n",
        },
        {
          "@@pS",
          function()
            if persistence.active() then
              vim.print("`persistence` is running.")
            else
              vim.print("`persistence` is not running.")
            end
          end,
          desc = "[p]ersistence [S]tatus",
          mode = "n",
        },
        {
          "@@pe",
          function()
            persistence.start()
          end,
          desc = "[p]ersistence [e]nter.",
          mode = "n",
        },
        {
          "@@ps",
          function()
            persistence.save()
          end,
          desc = "[p]ersistence [s]ave.",
          mode = "n",
        },
        {
          "@@px",
          function()
            persistence.save()
            persistence.stop()
          end,
          desc = "[p]ersistence e[x]it.",
          mode = "n",
        },
      })
    end,
  },
  -----------------------------------------------------------------------------
  ---
  --- FuzyFinder
  ---
  {
    "nvim-telescope/telescope.nvim",
    tag = "v0.2.1",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- optional but recommended
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope.builtin")

      --- NOTE(acederberg): There are also some commands that can be found within
      ---                   the `lspconfig` section.
      local wk = require("which-key")
      wk.add({
        { "@@f", group = "[f]ind (with telescope!)" },
        { "@@ff", telescope.find_files, desc = "[f]ind [f]ile." },
        { "@@fg", telescope.live_grep, desc = "[f]ind with [g]rep." }, -- needs ripgrep
        { "@@fb", telescope.buffers, desc = "[f]ind [b]uffer." },
        { "@@fB", telescope.builtin, desc = "[f]ind [B]uiltins." },
        { "@@fc", telescope.colorscheme, desc = "[f]ind [c]olorscheme." },
        { "@@fj", telescope.jumplist, desc = "[f]ind [j]umps." },
        { "@@fd", telescope.diagnostics, desc = "[f]ind [d]iagnostics." },
        { "@@fi", telescope.lsp_implementations, desc = "[f]ind [i]mplementations." },
        { "@@fr", telescope.lsp_references, desc = "[f]ind [i]mplementations." },
        {
          { "@@fg", group = "[f]ind [g]it (with telescope!)" },
          { "@@fgb", telescope.git_branches, desc = "[f]ind [g]it [b]ranch." },
          { "@@fgc", telescope.git_commits, desc = "[f]ind [g]it [c]ommits." },
          { "@@fgC", telescope.git_commits, desc = "[f]ind [g]it [C]ommits for buffer." },
          { "@@fgs", telescope.git_commits, desc = "[f]ind [g]it [s]tatus." },
        },
      })
    end,
  },
  -----------------------------------------------------------------------------
  ---
  --- Notifications
  ---
  {
    "j-hui/fidget.nvim",
    tag = "v1.7.0",
    opts = {},
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      --- TODO(acederberg): Add keybinds for telescope with fidget.
      require("telescope").load_extension("fidget")
    end,
  },
  -----------------------------------------------------------------------------
  ---
  --- File Outlines
  ---
  --- Defines the `Outline` command.
  ---
  {
    "hedyhli/outline.nvim",
    dependencies = { "folke/which-key.nvim" },
    config = function()
      local wk = require("which-key")
      local outline = require("outline")

      outline.setup()
      wk.add({
        { "@@o", group = "[o]utline." },
        {
          "@@os",
          function()
            outline.toggle()
          end,
          desc = "[o]utline [s]how/unshow.",
        },
        {
          { "@@of", desc = "[o]utline [f]ocus." },
          { "@@ofo", ":OutlineFocusOutline<cr>", desc = "[o]utline [f]ocus [o]utline." },
          { "@@ofc", ":OutlineFocusCode<cr>>", desc = "[o]utline [f]ocus [c]ode" },
        },
      })
    end,
    opts = {
      providers = {
        priority = { "markdown", "lsp", "norg" },
        -- Configuration for each provider (3rd party providers are supported)
        lsp = {
          -- Lsp client names to ignore
          blacklist_clients = {},
        },
        markdown = {
          -- List of supported ft's to use the markdown provider
          filetypes = { "markdown", "quarto" },
        },
      },
    },
  },
  -----------------------------------------------------------------------------
  ---
  --- URL Viewer
  --- For url viewing.
  ---
  --- Defines the `UrlView` command.
  ---
  {
    "axieax/urlview.nvim",
    opts = {
      default_picker = "telescope",
    },
    config = function()
      require("which-key").add({
        {
          "@@fu",
          "<ESC>:UrlView<CR>",
          desc = "[f]ind [u]rls.",
        },
      })
    end,
  },
  -----------------------------------------------------------------------------
  ---
  --- Twilight
  --- For focus.
  ---
  --- Defines the `Twilight` command.
  {
    "folke/twilight.nvim",
    opts = {},
    config = function()
      local tw = require("twilight")
      tw.disable()
      require("which-key").add({
        { "@@tw", group = "[tw]ighlight" },
        { "@@twe", tw.enable, desc = "[tw]ighlight [e]nable" },
        { "@@twd", tw.disable, desc = "[tw]ighlight [d]isable" },
        { "@@twt", tw.toggle, desc = "[tw]ighlight [t]oggle" },
      })
    end,
  },
  --- Tried it, but I don't think I need it. Twilight does what I need out of this.
  --[[ {
    "folke/zen-mode.nvim",
    opts = {},
  }, ]]
}
