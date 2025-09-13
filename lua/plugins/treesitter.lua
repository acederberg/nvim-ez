return {
  "nvim-treesitter/nvim-treesitter",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter-textobjects" },
  },
  run = ":TSUpdate",
  config = function()
    local config = {
      ensure_installed = {
        "cpp",
        "comment",
        "hcl",
        "python",
        "markdown",
        "markdown_inline",
        "bash",
        "yaml",
        "query",
        "css",
        "html",
        "javascript",
        "go",
        "c",
        "lua",
        "vim",
        "embedded_template",
        "mermaid",
        "dot",
      },
      embedded_template = { enable = true },
      highlight = {
        enable = true,
      },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
        },
      },
      query_linter = {
        enable = true,
      },
      playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
    }
    require("nvim-treesitter.configs").setup(config)
  end,
}
