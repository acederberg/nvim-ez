return {
 'nvim-treesitter/nvim-treesitter',
	dependencies = {
		{ 'nvim-treesitter/nvim-treesitter-textobjects' },
	},
	run = ':TSUpdate',
	config = function()
		require("nvim-treesitter.configs").setup {
			ensure_installed={"python", "markdown", "markdown_inline", "bash", "yaml", "query", "css", "html", "javascript", "go", "c", "lua", "vim"},
			highlight={
				enable=true,
				custom_captures = {["import_statement"] = "pythonDecorators"}
			},
			indent={enable=true,},
			playground = {
				enable = true,
				disable = {},
				updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
				persist_queries = false, -- Whether the query persists across vim sessions
				keybindings = {
					toggle_query_editor = 'o',
					toggle_hl_groups = 'i',
					toggle_injected_languages = 't',
					toggle_anonymous_nodes = 'a',
					toggle_language_display = 'I',
					focus_language = 'f',
					unfocus_language = 'F',
					update = 'R',
					goto_node = '<cr>',
					show_help = '?',
				}
			}
		}
	end 
}
	

