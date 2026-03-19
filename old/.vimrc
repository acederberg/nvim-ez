" =========================================================================== #
" Plug Walk
" --------------------------------------------------------------------------- #

	

call plug#begin()

	" General syntax plugins.
  Plug 'hashivim/vim-terraform'
  Plug 'sheerun/vim-polyglot'
	Plug 'fladson/vim-kitty'
  Plug 'towolf/vim-helm'
  Plug 'glench/vim-jinja2-syntax'
	Plug 'stsewd/sphinx.nvim', { 'do': ':UpdateRemotePlugins' }

	" Nerdtree Plugins.
	Plug 'preservim/nerdtree'
	Plug 'ryanoasis/vim-devicons'
	Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
	Plug 'airblade/vim-gitgutter'

	" Other tools
	Plug 'dense-analysis/ale'

	" Color Schemes
	Plug 'altercation/vim-colors-solarized'
	Plug 'morhetz/gruvbox'
  Plug 'sonph/onehalf', {'rtp': 'vim/'}

call plug#end()


" =========================================================================== #
" Configuration for ColorSchemes
" --------------------------------------------------------------------------- #


" Solarized

let g:solarized_termtrans = 1
let g:solarized_bold = 1
let g:solarized_underline = 1
let g:solarized_italic = 1
let g:solarized_contrast = "high"
let g:solarized_visibility = "high"
let g:solarized_termcolors = 256


" Gruvbox

let g:gruvbox_bold=1
let g:gruvbox_underline=1
let g:gruvbox_italic=1
let g:gruvbox_termcolors = 256
let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_contrast_light = "medium"
let g:gruvbox_hls_cursor = "green"
let g:gruvbox_number_column = "bg0"
let g:gruvbox_sign_column = "bg1"
let g:gruvbox_italicize_strings = 1
let g:gruvbox_improved_strings = 1
let g:gruvbox_improved_warnings = 1


" =========================================================================== #
" Configuration for Other Tools
" --------------------------------------------------------------------------- #


let g:ale_linters = {
	\ 'go': ['gofmt', 'golint', ],
	\ 'python': ['flake8', 'mypy', ],
	\ 'typescriptreact': ['prettier', 'eslint',],
	\ 'typescript': ['prettier', 'eslint',],
	\ 'javascript': ['eslint', ],
	\ 'yaml': ['actionlint', 'circleci', 'yamllint',],
	\ 'json': ['jq',],
	\}
let g:ale_fixers = {
	\ 'go': ['gofmt', 'gopls'],
	\ 'python': ['isort', 'black',],
	\ 'typescriptreact': ['prettier', 'eslint',],
	\ 'typescript': ['prettier', 'eslint',],
	\ 'javascript': ['prettier', 'eslint',],
	\ '*': ['remove_trailing_lines', 'trim_whitespace',],
	\ 'yaml': ['yamlfix', ],
	\ 'json': ['fixjson',],
	\}
let g:ale_fix_on_save = 1
let g:ale_completion_enabled = 0


" =========================================================================== "
" Functions
" --------------------------------------------------------------------------- #



" --------------------------------------------------------------------------- #
" Quotation and commenting, to be implemented in the 'Mappings' section.
" --------------------------------------------------------------------------- #

function! ToggleWord(word, quote)
  let front_has_quote = split(a:word, "^" + a:quote)[0] " != a:word
  let end_has_quote = split(a:word, a:quote + "$")[0] " != a:word


  echom front_has_quote
  echom end_has_quote
  if front_has_quote == end_has_quote
    if front_has_quote
      echom "quoted""
      return a:word
    else
      echom "not quoted"
      return a:word
    endif
  endif
  echom "partially quoted."
  return a:word
endfunction






" function! quotations#toggleLine(line, quote)
" endfunction
" function! quotations#toggleLineAsymetic(line, quote)
" endfunction
" function! quotations#toggleSelection(block, quote)
" endfunction

" =========================================================================== #
" Mappings
" --------------------------------------------------------------------------- #

let remapLeader = "`"
let altRemapLeader = "&"

nnoremap `j 80\|bi<CR><TAB><ESC>w

" Quoting and dequoting.
nnoremap `" ciw""<Esc>P
nnoremap `' ciw''<Esc>P
nnoremap `` ciw``<Esc>P
nnoremap &" ciw<Esc>Pwxx

" Comments
nnoremap # :CommentToggle<CR>
vnoremap # :CommentToggle<CR>

" NerdTree
" Just use change window <C-w><C-w> to get into/out of the NERDTree.

inoremap <C-t> <ESC>:NERDTreeToggle<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
inoremap <C-s> <ESC>:NERDTreeToggleVCS<CR>
nnoremap <C-s> :NERDTreeToggleVCS<CR>


" =========================================================================== #
" General Options
" --------------------------------------------------------------------------- #

set number
set nowrap
set tabstop=2
set shiftwidth=2

set expandtab
set autochdir

colorscheme solarized
" colorscheme gruvbox
" set bg=light

" Get rid of solorscheme background. This must be done after the solor scheme
" is set
set termguicolors
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE

highlight ColorColumn ctermbg=88 guibg=DarkBlue
set cc=80

" source ~/.cocrc
