set relativenumber	" make linenumbers relative

autocmd BufWritePre * :%s/\s\+$//e 	 " exterminatus to trailing whitespaces


set hlsearch		" highlight search
set incsearch		" incremental search
set showmatch           " jump to matches when entering regexp
set ignorecase          " ignore case when searching
set smartcase           " no ignorecase if Uppercase char present
set foldmethod=syntax   " enable folding e.g a json array or a python method

set autoread            " reload filesystem changes

set clipboard=unnamed " yank into clipboard by default

" surround with ", ' or delete the quatation
:nnoremap <Leader>q" ciw""<Esc>P
:nnoremap <Leader>q' ciw''<Esc>P
:nnoremap <Leader>q{ ciw{}<Esc>P
:nnoremap <Leader>q} ciw{}<Esc>P
:nnoremap <Leader>q[ ciw[]<Esc>P
:nnoremap <Leader>q] ciw[]<Esc>P
:nnoremap <Leader>qd daW"=substitute(@@,"'\\\|\"","","g")<CR>P

" quote shell variable properly,
" e.g. $VAR --> \qv --> <doublequote>$VAR<doublequote>
:nnoremap <Leader>qv F$xciw""<Esc>Pbi$<Esc>

" fuzzy find and open file with Control+Shift+O
" :nnoremap <silent> <C-S-O> : Files<CR>

" prettyfy json with Control+Shift+P
:nnoremap <silent> <C-S-P> : %!python -m json.tool<CR>

" turn on actual highlight on highlightsearch
set cursorline
hi CursorLine term=bold cterm=bold guibg=white


set visualbell t_vb=    " turn off error beep/flash
set novisualbell        " turn off visual bell


set backspace=indent,eol,start  " make that backspace key work the way it should
set expandtab

syntax on               " turn syntax highlighting on by default
filetype on             " detect type of file
filetype indent on      " load indent file for specific file type


set nocompatible        " use vim defaults
set t_RV=               " http://bugs.debian.org/608242, http://groups.google.com/group/vim_dev/browse_thread/thread/9770ea844cec3282

" google the selected text by pressing F1
xnoremap <f1> "zy:!open "http://www.google.com/search?q=<c-r>=substitute(@z,' ','%20','g')<cr>"<return>gv

" insert current timestamp in normal mode by pressing F5
nnoremap <F5> "=strftime("%A, %Y %B %d")<CR>P


" git commit opens vim in insert mode
autocmd FileType gitcommit exec 'au VimEnter * startinsert'


" lightline plugin
let g:lightline = {
  \     'active': {
  \         'left': [['mode', 'paste' ], ['readonly', 'filename', 'modified']],
  \         'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding']]
  \     }
  \ }


if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" so ~/.vim/plugins.vim
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'junegunn/goyo.vim'
Plug 'mtdl9/vim-log-highlighting'
Plug 'zivyangll/git-blame.vim'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'k0kubun/vim-open-github'
Plug 'AndrewRadev/linediff.vim'
Plug 'kshenoy/vim-signature'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'
Plug 'unblevable/quick-scope'
Plug 'easymotion/vim-easymotion'
Plug 'Xuyuanp/nerdtree-git-plugin'
call plug#end()

let g:github_enterprise_urls = ['https://github.infra.cloudera.com']
let g:notes_directories = ['~/notes']

let g:ale_set_highlights = 0

colorscheme onedark

" unblevable/quick-scope: Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

highlight QuickScopePrimary cterm=underline,italic
highlight QuickScopeSecondary cterm=underline,bold



"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

" fix lightline plugin
set laststatus=2

set encoding=utf-8
set fileencoding=utf-8

"" NERDTree configuration
let g:NERDTreeChDirMode=2
let g:NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks=1
let g:nerdtree_tabs_focus_on_files=1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 50
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
nnoremap <silent> <F2> :NERDTreeFind<CR>
noremap <F3> :NERDTreeToggle<CR>
"" Make Nerdtree show .files by default
let NERDTreeShowHidden=1
hi Directory guifg=#FF0000 ctermfg=darkgreen
"" auto open NerdTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

"" close nerdtree automatically
let NERDTreeQuitOnOpen = 1

"" open nerdtree and select currently edited file by pressing `\v`
nnoremap <silent> <Leader>v :NERDTreeFind<CR>
