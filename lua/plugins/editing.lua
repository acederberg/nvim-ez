return {
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
      require("conform").setup({
        notify_on_error = false,
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        -- Look at this extremely obscure blog post: https://vm70.neocities.org/posts/2024-04-11-quarto-prettier/
        formatters_by_ft = {
          lua = { "mystylua" },
          python = { "isort", "black" },
          quarto = { "prettier" },
        },
        formatters = {
          mystylua = {
            command = "stylua",
            args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
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
      -- NOTE: Customize the "injected" formatter. See
      --
      --       .. code:: txt
      --
      --          https://github.com/jmbuhr/uarto-nvim-kickstarter/blob/main/lua/plugins/editing.lua
      --
      require("conform").formatters.injected = {
        -- NOTE: Set the options field
        options = {
          -- NOTE: Set to true to ignore errors
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
          -- Map of treesitter language to formatters to use
          -- (defaults to the value from formatters_by_ft)
          lang_to_formatters = {},
        },
      }
    end,
  },
}
