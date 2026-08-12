-----------------------------------------------------------------------------
---
--- Mason For Lsp Package Installation.
---
---
--- If you want `prettier` plugins, they must be installed locallaly. https://github.com/williamboman/mason.nvim/issues/392
---
return {
  {
    "mason-org/mason.nvim",
    tag = "v2.2.1",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    tag = "v2.1.0",
    opts = {},
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
    },
    config = function()
      --- Should these be moved to their individual lsp configurations?
      require("mason-tool-installer").setup({
        ensure_installed = {
          "ansible-language-server",
          "ansiblels",
          "ansible-lint",
          "black",
          "clangd",
          "isort",
          "jq",
          "jupytext",
          "lemminx",
          "lua-language-server",
          "lua_ls",
          "mypy",
          "prettier",
          "ruff",
          "shfmt",
          "stylua",
          "terraform-ls",
          "terraformls",
          "tree-sitter-cli",
          "yamlfix",
          "yamlfmt",
          "yaml-language-server",
          "yamlls",
        },
      })
    end,
  },
}
