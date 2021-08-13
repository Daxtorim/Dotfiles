" ================ Plugins ===========================
"{{{

"Neovim expects vim-plug in a different location, but with LunarVim it becomes unnecessary anyway
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
		Plug 'morhetz/gruvbox'
		Plug 'tpope/vim-commentary'
		Plug 'mg979/vim-visual-multi', {'branch': 'master'}
		Plug 'jiangmiao/auto-pairs'
		Plug 'itchyny/lightline.vim'
		Plug 'machakann/vim-highlightedyank'
	call plug#end()

	"Plugin settings
	let g:highlightedyank_highlight_duration = 300

endif

"}}}

" ================ Display settings ==================
"{{{

" Blinking BAR in insert mode, blinking BLOCK elsewhere (GUI only)
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
              \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
              \,sm:block-blinkwait175-blinkoff150-blinkon175

set guifont=FiraCode\ Nerd\ Font

"}}}

" ================ General Config ====================
"{{{

" Set the window title to 'VIM: filename [+][RO][Filetype]'
set title titlestring=%<%(VIM:\ %)%(%t\ %)%m%r%y

set background=dark
colorscheme gruvbox
set termguicolors               "Activate true color support
syntax enable                   "Turn on syntax highlighting when applicable
set belloff=all                 "Turn off the bell for all events, i.e. NO BEEP

set number                      "Show line number of current line
set relativenumber              "Show other line numbers relative to current line
set cursorline                  "Highlight line where the cursor is
set wildmenu                    "Add menu for auto completion
set wildmode=longest:full,full
set laststatus=2                "Always display the status line, even if only one window is displayed
set cmdheight=2                 "Set the height of the cmd line at the bottom to 2 lines
set splitbelow splitright       "Open new split panes to right and bottom, which feels more natural
set backspace=indent,eol,start  "Generally expected backspace behavior in insert mode
set history=1000                "Store cmd history
set showcmd                     "Show incomplete commands at the bottom right
set autoread                    "Reload files changed outside vim
set hidden                      "Allow buffers to exist in the background without being in a window
set encoding=utf-8              "Set default display encoding to utf-8
set spelllang=en_us             "Default spell checking for american english
set textwidth=0                 "Do not automatically break long lines

" Display whitespace visually
set list listchars=tab:›\ ,trail:~,space:∙,nbsp:⍽,extends:>,precedes:<

" Stop looking for a mapping/keycode after n milliseconds
set timeout timeoutlen=1000 ttimeoutlen=30

" Do not automatically add a comment marker to new lines and do not wrap long comments
autocmd BufRead,BufNew * setlocal formatoptions-=cro

"}}}

" ================ Indentation =======================
"{{{
set autoindent                 "Keep new lines on the same level as previous line
set smartindent                "Auto indent new lines after e.g '{'
set nosmarttab                 "Use actual tab when using <TAB>, ignore whatever mess smarttab tries to create
set tabstop=4                  "Maximum width of a tab character
set softtabstop=-1             "Pretend this is tabstop for <BS> and <TAB> operations, switch between tabs and spaces when necessary, (0=off, negative=shiftwidth)
set shiftwidth=0               "Number of spaces by which text is shifted (0=tabstop)
set noexpandtab                "Use actual tab characters, do not replace them with spaces

" Override ftplugins that think they know better but let them still set tabstop and expandtab
autocmd BufRead,BufNew * setlocal autoindent smartindent nosmarttab softtabstop=-1 shiftwidth=0
"}}}

" ================ Folds =============================
"{{{
set foldenable                  "Fold by default
set foldmethod=indent           "Fold based on indentation
set foldignore=                 "Do not exclude any lines from folds
set foldlevel=99                "Open all folds by default
set foldcolumn=0                "Display foldlevel in n wide gutter

" Filetype specific overrides
 autocmd FileType vim setlocal foldmethod=marker foldlevel=0
"}}}

" ================ Scrolling =========================
"{{{
set scrolloff=5 sidescrolloff=0 "Start scrolling when n lines away from borders
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

" ================ Keybindings =======================
"{{{
" Capitalization matters with meta keys
" It does NOT matter with CTRL (for some reason)

" Leader key
let mapleader=' '

" DO NOT GO INTO EX MODE EVER !!!
nmap Q <ESC>

" I see no scenario where I really need to step over wrapped lines
" Motions still act as if the wrapped lines were a single line
nnoremap j gj
nnoremap k gk

" Use meta-hjkl to move between splits
nnoremap <M-j> <C-w><C-j>
nnoremap <M-k> <C-w><C-k>
nnoremap <M-l> <C-w><C-l>
nnoremap <M-h> <C-w><C-h>

" Use meta+JK to move lines up and down
nmap <M-J> V:move '>+1<CR>gv-gv<ESC>
nmap <M-K> V:move '<-2<CR>gv-gv<ESC>
vmap <M-J> :move '>+1<CR>gv-gv
vmap <M-K> :move '<-2<CR>gv-gv

" Use CTRL+l to remove highlighting until next search
nnoremap <C-l> :nohl<CR><C-l>

" Make Y yank to the end of line (act like D or C)
nmap Y y$

"}}}
