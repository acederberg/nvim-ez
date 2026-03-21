--- Functionality common accross all markdown.
--- For something more specific to a flavor of markdown, modify or create the
--- existing associated file. For instance, `quarto.lua` or `obsidian.lua`.

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto" },
  callback = function(args)
    local bo = vim.bo[args.buf]
    bo.tabstop = 2
    bo.shiftwidth = 2
    bo.softtabstop = 2
    bo.expandtab = true
  end,
})

return {
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
      renderMd.disable()

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
