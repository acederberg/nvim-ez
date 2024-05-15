-- NOTE: These are general keymaps. For key maps associated with a particular
--       plugin, look for it under `./lua/plugins`. It is is important to note
--       that the diagnostic windows associated with plugins will be included
--       in this file since this is part vim and not the plugins themselves.
--
--
--
local nmap = function(key, effect)
  vim.keymap.set("n", key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
  vim.keymap.set("v", key, effect, { silent = true, noremap = true })
end

-------------------------------------------------------------------------------
-- Miscillanious.
--
local function background_transp()
  vim.cmd([[
		hi! Normal ctermbg=NONE guibg=NONE
		hi! NonText ctermbg=NONE guibg=NONE
	]])
end

vim.keymap.set("n", "&&a", ":source ~/.config/nvim/init.lua<CR>", {})
vim.keymap.set("n", "&&ts", background_transp, {})

-- keep selection after indent/dedent
vmap(">", ">gv")
vmap("<", "<gv")

-------------------------------------------------------------------------------
-- NOTE: Diagnostics.

vim.diagnostic.config({
  virtual_text = {
    source = true,
  },
  open_float = {
    source = true,
  },
  severity_sort = true,
})
local opts_open_float = nil

-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.open_float()
local function diagnostic_show()
  vim.diagnostic.open_float(opts_open_float, { focus = false })
  return
end

-- https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.goto_next()
local function diagnostic_next()
  vim.diagnostic.goto_next(opts_open_float)
end

local function diagnostic_prev()
  vim.diagnostic.goto_prev(opts_open_float)
end

vim.keymap.set({ "i", "n", "v" }, "@@!", diagnostic_show)
vim.keymap.set({ "i", "n", "v" }, "@@n", diagnostic_next)
vim.keymap.set({ "i", "n", "v" }, "@@N", diagnostic_prev)

-------------------------------------------------------------------------------
-- NOTE: Quarto
--

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
--- TODO: incorpoarate this into quarto-nvim plugin
--- such that QuartoRun functions get the same capabilities
--- TODO: figure out bracketed paste for reticulate python repl.
local function send_cell()
  if vim.b["quarto_is_r_mode"] == nil then
    vim.fn["slime#send_cell"]()
    return
  end
  if vim.b["quarto_is_r_mode"] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require("otter.tools.functions").is_otter_language_context("python")
    if is_python and not vim.b["reticulate_running"] then
      vim.fn["slime#send"]("reticulate::repl_python()" .. "\r")
      vim.b["reticulate_running"] = true
    end
    if not is_python and vim.b["reticulate_running"] then
      vim.fn["slime#send"]("exit" .. "\r")
      vim.b["reticulate_running"] = false
    end
    vim.fn["slime#send_cell"]()
  end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local slime_send_region_cmd = ":<C-u>call slime#send_op(visualmode(), 1)<CR>"
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)

local function send_region()
  -- if filetyps is not quarto, just send_region
  if vim.bo.filetype ~= "quarto" or vim.b["quarto_is_r_mode"] == nil then
    vim.cmd("normal" .. slime_send_region_cmd)
    return
  end
  if vim.b["quarto_is_r_mode"] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require("otter.tools.functions").is_otter_language_context("python")
    if is_python and not vim.b["reticulate_running"] then
      vim.fn["slime#send"]("reticulate::repl_python()" .. "\r")
      vim.b["reticulate_running"] = true
    end
    if not is_python and vim.b["reticulate_running"] then
      vim.fn["slime#send"]("exit" .. "\r")
      vim.b["reticulate_running"] = false
    end
    vim.cmd("normal" .. slime_send_region_cmd)
  end
end

nmap("<c-cr>", send_cell)

return {
  send_cell = send_cell,
  send_region = send_region,
  background_transp = background_transp,
  diagnostic_show = diagnostic_show,
  diagnostic_next = diagnostic_next,
  diagnostic_prev = diagnostic_prev,
}
