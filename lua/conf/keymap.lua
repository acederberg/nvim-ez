-- NOTE: These are general keymaps. For key maps associated with a particular 
--       plugin, look for it under `./lua/plugins`. It is is important to note 
--       that the diagnostic windows associated with plugins will be included 
--       in this file since this is part vim and not the plugins themselves.
--
--

-------------------------------------------------------------------------------
-- Miscillanious.
-- 
local keymap_helpers = {}
local function background_transp()
	vim.cmd [[
		hi! Normal ctermbg=NONE guibg=NONE
		hi! NonText ctermbg=NONE guibg=NONE
	]]
end

vim.keymap.set('n', '&&a', ':source ~/.config/nvim/init.lua<CR>', {})
vim.keymap.set('n', '&&ts', background_transp, {})


-------------------------------------------------------------------------------
-- NOTE: Diagnostics.

vim.diagnostic.config({
	virtual_text={
		source=true,
	},
	open_float={
		source=true,
	},
	severity_sort=true,
})
opts_open_float=nil

-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()
local function diagnostic_show()
	vim.diagnostic.open_float(opts_open_float, {focus=false})
	return
end

-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()
local function diagnostic_next()
	vim.diagnostic.goto_next(opts_open_float)
end

local function diagnostic_prev()
	vim.diagnostic.goto_prev(opts_open_float)
end

vim.keymap.set({"i", "n", "v"}, "@@!", diagnostic_show)
vim.keymap.set({"i", "n", "v"}, "@@n", diagnostic_next)
vim.keymap.set({"i", "n", "v"}, "@@N", diagnostic_prev)


return {
	background_transp=background_transp,
	diagnostic_show=diagnostic_show,
	diagnostic_next=diagnostic_next,
	diagnostic_prev=diagnostic_prev,

}
