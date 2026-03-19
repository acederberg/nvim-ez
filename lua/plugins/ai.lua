return {
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    config = function()
      require("which-key").add({ "@@a", group = "[a]vante" })
      require("avante").setup({
        instructions_file = "avante.md",
        provider = "openai",
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      file_types = { "markdown", "quarto", "Avante" },
      disabled = true,
      completions = {
        lsp = {
          enabled = true,
        },
      },
    },
    ft = { "markdown", "Avante" },
    config = function()
      local wk = require("which-key")
      local renderMd = require("render-markdown")

      wk.add({
        {
          {
            "@@M",
            group = "[M]arkdown preview.",
          },
          {
            "@@Mt",
            function()
              renderMd.toggle()
            end,
            desc = "Markdown preview [t]oggle.",
            mode = "in",
          },
          {
            "@@Me",
            function()
              renderMd.enable()
            end,
            desc = "Markdown preview [e]nable.",
            mode = "in",
          },
          {
            "@@Md",
            function()
              renderMd.disable()
            end,
            desc = "Markdown preview [d]isable.",
            mode = "in",
          },
        },
      })
    end,
  },
}
