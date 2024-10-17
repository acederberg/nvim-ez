require("conf.global")
local keymap_helpers = require("conf.keymap")

-- NOTE: These must occur in this specific order since changing the colorscheme
--       cancles out any existing transperency.
require("lazy").setup("plugins", {})

vim.cmd.colorscheme("gruvbox-material")

-- vim.treesitter.language.add(
keymap_helpers.background_transp()
