local nmap = function(key, effect)
  vim.keymap.set("n", key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
  vim.keymap.set("v", key, effect, { silent = true, noremap = true })
end

-- keep selection after indent/dedent
vmap(">", ">gv")
vmap("<", "<gv")
vim.keymap.set("t", "<ESC>", "<C-\\><C-n>")
