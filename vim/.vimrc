" ================ General Config ====================
"{{{

" Set the window title to 'VIM: filename [+][RO][Filetype]'
set title titlestring=%<%(VIM:\ %t\ %)%m%r%y

set termguicolors               "Activate true color support
set belloff=all                 "Turn off the bell for all events, i.e. NO BEEP
set number                      "Show line number of current line
set norelativenumber            "Do not show other line numbers relative to current line
set signcolumn=auto             "Only display a signcolumn when there are signes set
set cursorline                  "Highlight line where the cursor is
set wildmenu                    "Add menu for auto completion
set wildmode=longest:full,full
set history=1000                "Store cmd history
set showcmd                     "Show incomplete commands at the bottom right
set cmdheight=1                 "Set the height of the cmd line at the bottom to n lines
set laststatus=2                "Always display the status line, even if only one window is displayed
set splitbelow splitright       "Open new split panes to right and bottom, which feels more natural
set backspace=indent,eol,start  "Generally expected backspace behavior in insert mode
set autoread                    "Reload files changed outside vim
set hidden                      "Allow buffers to exist in the background without being in a window
set encoding=utf-8              "Set default display encoding to utf-8
set spelllang=en                "Default spell checking for english
set textwidth=0                 "Do not automatically break long lines

syntax on

" Tell vim to draw the entire background; fixes issues with colorscheme
let &t_ut=''

" Stop looking for a mapping/keycode after n milliseconds
set timeout timeoutlen=1000 ttimeoutlen=30

" Display whitespace visually
set list listchars=tab:›\ ,space:·,trail:~,nbsp:⍽,extends:>,precedes:<
" set list listchars=tab:<->,space:⋅,trail:~,eol:↴,nbsp:⍽,extends:>,precedes:<

" List of characters for separators and other special places
set fillchars=fold:\ ,vert:│,diff:╱

augroup vimrc
	autocmd!
	" Do not automatically add a comment marker to new lines and do not wrap long comments
	autocmd BufWinEnter * setlocal formatoptions-=cro
	" Do not hide ANY characters in markup files
	autocmd BufWinEnter * setlocal conceallevel=0
	" Insert hard newlines after 72 chars and reformat entire paragraphs automatically
	autocmd FileType gitcommit setlocal tw=72 colorcolumn=73 formatoptions=w1pant
	" set colorcolumn according to max line width of common formatters
	autocmd FileType lua setlocal colorcolumn=121
	autocmd FileType python setlocal colorcolumn=89
	autocmd FileType rust setlocal colorcolumn=101
augroup END

"}}}

" ================ Scrolling =========================
"{{{
set scrolloff=3 sidescrolloff=0 "Start scrolling when n lines away from borders
set sidescroll=0                "Put cursor back to the middle of the screen when scrolling off horizontally
set nowrap                      "Do not Wrap long lines
set linebreak                   "Break lines at convenient points when 'wrap' is enabled
"}}}

" ================ Search ============================
"{{{
set ignorecase                  "Ignore case when searching for all lowercase pattern
set smartcase                   "Do NOT ignore case when search pattern contains uppercase letters
set hlsearch                    "Highlight matches
set incsearch                   "Search while still typing
"}}}

" ================ Indentation =======================
"{{{
set autoindent                  "Keep new lines on the same level as previous line
set smartindent                 "Auto indent new lines after e.g '{'
set nosmarttab                  "Use actual tab when using <TAB>, ignore whatever mess smarttab tries to create
set tabstop=4                   "Maximum width of a tab character
set softtabstop=-1              "Pretend this is tabstop for <BS> and <TAB> operations, switch between tabs and spaces when necessary, (0=off, negative=shiftwidth)
set shiftwidth=0                "Number of spaces by which text is shifted (0=tabstop)
set noexpandtab                 "Use actual tab characters, do not replace them with spaces
"}}}

" ================ Folds =============================
"{{{
set foldenable                  "Fold by default
set foldmethod=indent           "Fold based on indentation
set foldignore=                 "Do not exclude any lines from folds
set foldlevel=99                "Open all folds by default
set foldcolumn=0                "Display foldlevel in n wide gutter

" Replace tabs (\t) in first line of fold with spaces, then append ' ... ',
" then the last line of fold, then append the number of lines within the fold.
" The first \ signals a line continuation, not an escape sequence
set foldtext=substitute(getline(v:foldstart),'\\t',repeat('\ ',&tabstop),'g').
			\'\ ...\ '.trim(getline(v:foldend)).
			\'\ ('.(v:foldend-v:foldstart+1).'\ lines)'
"}}}

" ================ Keybindings =======================
"{{{
" Avoid meta (alt) key, not reliable
" Capitalization does NOT matter with CTRL

" Space as <leader> key
let mapleader = " "

" DO NOT GO INTO EX MODE EVER !!!
nmap Q <ESC>

" Shortcut to leave Terminal mode
tmap <Esc> <C-\><C-n>

" Make Y yank to the end of line (act like D or C)
nmap Y y$

" I see no scenario where I really need to step over wrapped lines
" Motions still act as if the wrapped lines were a single line
nnoremap j gj
nnoremap k gk

" Move around buffers (H,L were used to move curser to top or bottom of screen)
nnoremap L <cmd>bnext<CR>
nnoremap H <cmd>bNext<CR>

" Remove highlighting and redraw the screen
nmap <leader>h <cmd>nohl<CR><cmd>redraw<CR>

" Search and Replace shortcuts
nmap <leader>sw *N
nmap <leader>se *N:%s@@@g<Left><Left>
xmap <leader>se :s@@@g<Left><Left><Left>

nmap <leader>v <cmd>vsplit<CR>
nmap <leader>w <cmd>w<CR>
"}}}

" ================ Plugins ===========================
"{{{

" Neovim expects vim-plug in a different location, but with LunarVim it becomes unnecessary anyway
if ! has('nvim')

	" Install vim-plug if not found
	if empty(glob('~/.vim/autoload/plug.vim'))
		silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	endif

	" Run PlugInstall if there are missing plugins
	autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
	     \| PlugInstall --sync | source $MYVIMRC
	\| endif

	" Plugins will be downloaded under the specified directory.
	call plug#begin('~/.vim/plugged')
		Plug 'lifepillar/vim-gruvbox8'
		Plug 'tpope/vim-commentary'
		Plug 'tpope/vim-surround'
		Plug 'LunarWatcher/auto-pairs', { 'tag': '*' }
		Plug 'machakann/vim-highlightedyank'
		Plug 'Daxtorim/vim-auto-indent-settings'
	call plug#end()

	"Plugin settings
	let g:highlightedyank_highlight_duration = 300
	let g:AutoPairsCompatibleMaps = 0
	let g:AutoPairsShortcutFastWrap = '<C-e>'

	set background=dark
	colorscheme gruvbox8

endif

"}}}

" vim:fdm=marker:fdl=0:
