vim.keymap.set("n", "$$t", ":tabnext<CR>", { desc = "Go to the next tab." })
vim.keymap.set("n", "$$T", ":tabprevious<CR>", { desc = "Go to the previous tab." })
vim.keymap.set({ "n" }, "$$py", ":split  term://python<cr>", { desc = "Split into python interactive mode." })
vim.keymap.set({ "n" }, "$$ipy", ":split  term://ipython<cr>", { desc = "Split into python interactive mode." })
vim.keymap.set({ "n" }, "$$sh", ":split  term://zsh<cr>", { desc = "Split into ZSH." })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})


require('quarto').setup{
  debug = false,
  closePreviewOnExit = true,
  lspFeatures = {
    enabled = true,
    chunks = "curly",
    languages = { "r", "python", "julia", "bash", "html" },
    diagnostics = {
      enabled = true,
      triggers = { "BufWritePost" },
    },
    completion = {
      enabled = true,
    },
  },
  codeRunner = {
    enabled = false,
    default_method = nil, -- 'molten' or 'slime'
    ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`.
    never_run = { "yaml" }, -- filetypes which are never sent to a code runner
  },
}

require()
