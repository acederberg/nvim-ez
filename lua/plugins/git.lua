return {
  {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "folke/which-key.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local wk = require("which-key")

      wk.add({
        { "@@g", group = "[g]it" },
        { "@@gd", group = "[g]it [d]iffview." },
        { "@@gdo", ":DiffviewOpen<CR>", mode = "n", desc = "[g]it [d]iffview [o]pen." },
        { "@@gdx", ":DiffviewClose<CR>", mode = "n", desc = "[g]it [d]iffview e[x]it." },
        { "@@gdh", ":DiffviewFileHistory<CR>", mode = "n", desc = "[g]it [d]iffview file [h]istory." },
      })
    end,
  },
  { "nvim-tree/nvim-web-devicons", config = require("nvim-web-devicons").setup({}) },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    config = function()
      local wk = require("which-key")
      require("neogit").setup({
        kind = "split",
        integrations = {
          diffview = true,
        },
      })

      wk.add({
        { "@@g", group = "[g]it" },
        { "@@go", ":Neogit<cr>", desc = "neo[g]it [o]pen" },
        { "@@gb", ":Neogit branch<cr>", desc = "[g]it [b]ranch." },
        { "@@gc", ":Neogit commit<cr>", desc = "[g]it [c]ommit." },
        { "@@gs", ":Neogit stash<cr>", desc = "[g]it [s]tash." },
        { "@@gps", ":Neogit pull<cr>", desc = "[g]it [p]u[s]h." },
        { "@@gpl", ":Neogit push<cr>", desc = "[g]it [p]u[l]l." },
        { "@@gl", ":Neogit log<cr>", desc = "[g]it [l]og." },
      })
    end,
  },
}
