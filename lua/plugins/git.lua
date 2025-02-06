return {
  {
    "lewis6991/gitsigns.nvim",
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require("gitsigns").setup()
    end,
  },
  { "sindrets/diffview.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  {
    "NeogitOrg/neogit",
    lazy = true,
    cmd = "Neogit",
    keys = {
      { "<leader>gg", ":Neogit<cr>", desc = "neo[g]it" },
    },
    config = function()
      require("neogit").setup({
        kind = "split",
        integrations = {
          diffview = true,
        },
      })
    end,
  },
}
