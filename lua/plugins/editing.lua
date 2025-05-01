return {
  {
    "johnfrankmorgan/whitespace.nvim",
    dependencies = {
      "folke/which-key.nvim",
    },
    config = function()
      local wk = require("which-key")
      local ws = require("whitespace-nvim")

      ws.setup({
        highlight = "DiffDelete",
        ignored_filetypes = { "TelescopePrompt", "Trouble", "help", "dashboard" },
        ignore_terminal = true,
        return_cursor = true,
      })

      -- remove trailing whitespace with a keybinding
      wk.add({
        { "@@w", group = "[w]hitespace." },
        {
          "@@wt",
          ws.trim,
          mode = "n",
          desc = "[w]hitespace [t]rim.",
        },
      })
    end,
  },
  {
    "numToStr/Comment.nvim",
    -- NOTE: Disable these settings so that toggling can be defined directly.
    opts = {
      basic = false,
      extra = false,
    },
    lazy = false,
    config = function()
      local comment = require("Comment")
      comment.setup()
    end,
  },
  {
    "stevearc/conform.nvim",
    enabled = true,
    config = function()
      -------------------------------------------------------------------------
      local conform = require("conform")
      conform.setup({
        notify_on_error = false,
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          html = { "prettier" },
          lua = { "mystylua" },
          python = { "isort", "black" },
          quarto = { "injected", "prettier" },
          json = { "jq" },
          yaml = { "yamlfmt" },
          toml = { "prettier" },
          md = { "injected", "prettier" },
        },
        formatters = {
          mystylua = {
            command = "stylua",
            args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
          },
          prettier = {
            options = {
              ext_parsers = {
                qmd = "markdown",
              },
            },
          },
        },
      })

      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })

      -------------------------------------------------------------------------
      -- NOTE: Customize the "injected" formatter.
      --       Based on https://github.com/jmbuhr/uarto-nvim-kickstarter/blob/main/lua/plugins/editing.lua
      --       Look at this extremely obscure blog post: https://vm70.neocities.org/posts/2024-04-11-quarto-prettier/
      --       And this github issue: https://github.com/jmbuhr/otter.nvim/issues/140
      conform.formatters.injected = {
        options = {
          ignore_errors = false,
          -- NOTE: Map of treesitter language to file extension A temporary
          --       file name with this extension will be generated during
          --       formatting because some formatters care about the filename.
          lang_to_ext = {
            bash = "sh",
            c_sharp = "cs",
            elixir = "exs",
            javascript = "js",
            julia = "jl",
            latex = "tex",
            markdown = "md",
            python = "py",
            ruby = "rb",
            rust = "rs",
            teal = "tl",
            r = "r",
            typescript = "ts",
          },
          lang_to_formatters = {
            python = { "black", "isort" },
            json = { "jq" },
            yaml = { "yamlfmt" },
            lua = { "mystylua" },
          },
        },
      }
    end,
  },
  --[[ {
    "kylechui/nvim-surround",
    version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      local surround = require("nvim-surround")
      local wk = require("which-key")

      surround.setup({})
    end
  } ]]
}
