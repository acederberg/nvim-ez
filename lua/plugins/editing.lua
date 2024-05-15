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
        formatters_by_ft = {
          lua = { "mystylua" },
          python = { "isort", "black" },
        },
        formatters = {
          mystylua = {
            command = "stylua",
            args = { "--indent-type", "Spaces", "--indent-width", "2", "-" },
          },
        },
      })
      -------------------------------------------------------------------------
      -- NOTE: Customize the "injected" formatter. See
      --
      --       .. code:: txt
      --
      --          https://github.com/jmbuhr/quarto-nvim-kickstarter/blob/main/lua/plugins/editing.lua
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
