return {
  {
    "rebelot/kanagawa.nvim",
    commentStyle = { italic = true },
    -- overrides = function(colors)
    --   base = {
    --     -- Text.
    --     Boolean = { fg = colors.palette.autumnYellow, italic = false, bold = true },
    --     String = { fg = colors.palette.oniViolet, italic = true },
    --     Keyword = { fg = colors.palette.boatYellow2, bold = false, italic = false },
    --     Normal = { fg = colors.palette.boatYellow1, bold = false, italic = false },
    --     Constant = { fg = colors.palette.carpYellow, bold = true, italic = true },
    --     Identifier = { fg = colors.palette.oldWhite },
    --     PreProc = { fg = colors.palette.boatYellow2, bold = true },
    --     Statement = { fg = colors.palette.roninYellow, bold = true },
    --     Type = { fg = colors.palette.springGreen, bold = true },
    --     Function = { fg = colors.palette.autumnYellow, bold = false },
    --     Special = { fg = colors.palette.sakuraPink, bold = true },
    --
    --     -- Airline
    --   }
    --
    --   amendments = {
    --     python = {
    --       Constant = { fg = colors.palette.lotusYellow3, bold = true, italic = true },
    --     },
    --     terraform = {
    --       Type = { fg = colors.palette.springGreen, bold = true },
    --       String = { fg = colors.palette.autumnGreen },
    --       Identifier = { fg = colors.palette.surimiOrange },
    --       Normal = { fg = colors.palette.samuraiRed },
    --       Keyword = { fg = colors.palette.lightBlue, bold = true },
    --       Function = { fg = colors.palette.peachRed, bold = true },
    --     },
    --   }
    --
    --   -- ft = vim.bo.filetype
    --   updateTable(base, amendments["terraform"])
    --   return base
    -- end,
  },
  {
    "sainnhe/gruvbox-material",
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_dim_inactive_windows = true
    end,
  },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    config = function()
      vim.g.moonflyItalics = true
    end,
  },
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized").setup({
        styles = {
          comments = { italic = true, bold = false },
          functions = { italic = true, bold = true },
          types = { italic = true },
          keywords = { italic = true },
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {},
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox-material" },
      })
    end,
  },
}
