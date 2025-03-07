"#: General Options                         {{{

" Set the window title to 'Vim: filename [+][RO][Filetype]'
set title titlestring=Vim:\ %t\ %m

set belloff=all                 " Turn off the bell for all events, i.e. NO BEEP
set number                      " Show line number of current line
set norelativenumber            " Don't show other line numbers relative to current line
set signcolumn=auto             " Only display a signcolumn when there are signs set
set colorcolumn=121             " Add a highlighted column to indicate excessively long lines
set cursorline                  " Highlight line where the cursor is
set conceallevel=2              " Hide markup characters
set history=1000                " Store cmd history
set showcmd                     " Show incomplete commands at the bottom right
set noshowmode			        " Do not show which mode is active at the bottom
set cmdheight=1                 " Set the height of the cmd line at the bottom to n lines
set laststatus=2                " Always display the status line, even if only one window is displayed
set splitbelow splitright       " Open new split panes to right and bottom, which feels more natural
set backspace=indent,eol,start  " Generally expected backspace behavior in insert mode
set autoread                    " Reload files changed outside vim
set hidden                      " Allow buffers to exist in the background without being in a window
set encoding=utf-8              " Set default display encoding to utf-8
set textwidth=0                 " Do not automatically break long lines
set clipboard=unnamed           " Put yanked/deleted text into the * register (»primary selection« can be pasted via middle click)
set mouse=a                     " Enable use of the mouse to select text inside a buffer
set modeline                    " Read modeline to enable file specific settings

if v:version >= 900
set splitkeep=screen            " Keep buffer text on screen static when splitting windows, moving the cursor if necessary
endif

" enable syntax highlighting and ftplugin settings
syntax enable
filetype plugin on

" Change cursor style
let &t_SI="\<Esc>[6 q"          " Insert: solid vertical bar
let &t_SR="\<Esc>[4 q"          " Replace: solid underscore
let &t_EI="\<Esc>[2 q"          " Normal: solid block

" Stop looking for a mapping/keycode after n milliseconds
set timeout timeoutlen=1000 ttimeoutlen=30

" Display whitespace visually
set listchars=tab:›\ ,space:·,trail:~,nbsp:⍽,extends:>,precedes:<
" set list listchars=tab:<->,space:⋅,trail:~,nbsp:⍽,extends:>,precedes:<,eol:↴

" List of characters for separators and other special places
set fillchars=fold:\ ,vert:│,diff:╱
"}}}

"#: Scrolling                               {{{
set scrolloff=9 sidescrolloff=9 " Start scrolling when n lines away from borders
set sidescroll=0                " Put cursor back to the middle of the screen when scrolling off horizontally
set nowrap                      " Do not wrap long lines
set linebreak                   " Break lines at convenient points when 'wrap' is enabled
"}}}

"#: Search                                  {{{
set ignorecase                  " Ignore case when searching for all lowercase pattern
set smartcase                   " Do NOT ignore case when search pattern contains uppercase letters
set hlsearch                    " Highlight matches
set incsearch                   " Search while still typing
"}}}

"#: Indentation                             {{{
set autoindent                  " Keep new lines on the same level as previous line
set smartindent                 " Auto indent new lines after e.g '{'
set smarttab                    " Indent according to shiftwidth at start of line and convert between tabs and spaces appropriately
set tabstop=4                   " Maximum width of a tab character
set softtabstop=-1              " Pretend this is tabstop for <BS> and <TAB> operations, switch between tabs and spaces when necessary, (0=off, negative=shiftwidth)
set shiftwidth=0                " Number of spaces by which text is shifted (0=tabstop)
set noexpandtab                 " Use actual tab characters, do not replace them with spaces
"}}}

"#: Folds                                   {{{
set foldenable                  " Fold by default
set foldmethod=indent           " Fold based on indentation
set foldignore=                 " Do not exclude any lines from folds
set foldlevel=99                " Open all folds by default
set foldcolumn=0                " Display foldlevel in n wide gutter

" Replace tabs (\t) in first line of fold with spaces, then append ' ... ',
" then the last line of fold, then append the number of lines within the fold.
" The first \ signals a line continuation, not an escape sequence
set foldtext=
	\substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g')
	\.'\ ...\ '
	\.trim(getline(v:foldend))
	\.'\ ('.(v:foldend-v:foldstart+1).'\ lines)'
"}}}

"#: Wildmenu                                {{{
set wildmenu                    " Add menu for auto completion
set wildoptions=pum             " Use popup menu to display completions
set wildmode=longest:full,full  " Start wildmenu and complete longest common prefix, then cycle through complete matches
set wildchar=<Tab>              " Use this key to go through completion options
set wildcharm=<C-z>             " Use this key to open wildmenu via a mapping
"}}}

"#: Autocommands                            {{{
augroup vimrc
	autocmd!
	" Do not automatically add a comment marker to new lines and do not wrap long comments
	autocmd BufWinEnter * setlocal formatoptions-=cro
	" Insert hard newlines after 72 chars and reformat entire paragraphs automatically
	autocmd FileType gitcommit setlocal spell tw=72 colorcolumn=73 formatoptions=w1pant

	" set colorcolumn according to max line width of common formatters
	autocmd FileType javascript setlocal colorcolumn=81   " prettier
	autocmd FileType lua setlocal colorcolumn=121         " stylua
	autocmd FileType python setlocal colorcolumn=89       " black
	autocmd FileType rust setlocal colorcolumn=101        " rustfmt
augroup END
"}}}

"#: Statusline                              {{{
function! StatuslineColor(mode)
	if a:mode == 'i'
		hi! link StatusLine DiffAdd
	elseif a:mode =~ '[vV\x16]'
		hi! link StatusLine DiffText
	elseif a:mode == 'R'
		hi! link StatusLine DiffChange
	elseif a:mode =~ '[sS\x13]'
		hi! link StatusLine DiffDelete
	elseif a:mode == 'c'
		hi! link StatusLine WildMenu
	else
		hi! link StatusLine NONE
	endif
	redrawstatus
endfunction

augroup vimrcStatusline
	autocmd!
	autocmd ModeChanged *:* call StatuslineColor(mode())
augroup END

"}}}

"#: Keybindings                             {{{
" Avoid meta (alt) key, not reliable in all terminals
" Capitalization does NOT matter with CTRL

" Space as <leader> key
let mapleader = " "
let maplocalleader = "_"

" DO NOT GO INTO EX MODE EVER !!!
nmap Q <Nop>
nmap gQ <Nop>

" Shortcut to leave Terminal mode
tmap <Esc> <C-\><C-n>

" Make Y yank to the end of line (act like D or C)
nmap Y y$

" Step *through* wrapped lines unless v:count is given
noremap <expr> j (v:count ? 'j' : 'gj')
noremap <expr> k (v:count ? 'k' : 'gk')

" Set undo points in insert mode for certain actions
inoremap <left> <c-g>U<left>
inoremap <right> <c-g>U<right>
inoremap <up> <c-g>u<up>
inoremap <down> <c-g>u<down>
inoremap <cr> <c-g>u<cr>
" inoremap <bs> <c-g>u<bs>
inoremap <c-w> <c-g>u<c-w>
inoremap <c-u> <c-g>u<c-u>

" Open list of buffers in wildmenu
nnoremap <leader><space> :buffer <C-z>

" Remove highlighting and redraw the screen
nmap <leader>h <cmd>nohls<CR><cmd>redraw<CR>

" Search and Replace shortcuts
nmap <leader>se *N:%s@@@g<Left><Left>
xmap <leader>se :s@@@g<Left><Left><Left>

nmap <leader>v <cmd>vsplit<CR>
"}}}

"#: Plugins                                 {{{
if has('nvim')
	" if this file is sourced from neovim modify runtimepath to automatically include vim plugins
	set runtimepath^=~/.vim
	set runtimepath+=~/.vim/after
	let &packpath = &runtimepath
endif

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
	\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter *
\ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
\ | PlugInstall --sync | source '~/.vim/autoload/plug.vim'
\ | endif

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')
	Plug 'tpope/vim-commentary'
	Plug 'tpope/vim-surround'
	Plug 'tpope/vim-sleuth'
	Plug 'gruvbox-community/gruvbox'

	Plug 'LunarWatcher/auto-pairs'
	let g:AutoPairsMapBS = 1
	let g:AutoPairsShortcutFastWrap = '<C-e>'

	Plug 'machakann/vim-highlightedyank'
	let g:highlightedyank_highlight_duration = 300
	if has('nvim')
		" Don't need this one when in Neovim
		let g:loaded_highlightedyank = 1
	end
call plug#end()


set termguicolors               " Activate true color support
set background=dark             " Tell colorschemes which colour mode to use (light/dark)
let &t_ut=''                    " Draw entire background (fixes issues with colorscheme)
silent! colorscheme gruvbox

"Reduce color intensity of some highlights
highlight SpecialKey guifg=#3a3a3a       " listchars
highlight CursorLine guibg=#191919
highlight CursorColumn guibg=#191919
"}}}

" vim:fdm=marker:fdl=0:
