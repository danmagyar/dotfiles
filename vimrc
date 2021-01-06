"################ Plugins ################
" so ~/.vim/plugins.vim
call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'mtdl9/vim-log-highlighting'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'AndrewRadev/linediff.vim'
"shows marks
Plug 'kshenoy/vim-signature'
Plug 'unblevable/quick-scope'
Plug 'easymotion/vim-easymotion'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'plasticboy/vim-markdown'
Plug 'google/vim-searchindex'
Plug 'JamshedVesuna/vim-markdown-preview'
Plug 'mbbill/undotree'
Plug 'jesseleite/vim-agriculture'
Plug 'wellle/targets.vim'

call plug#end()


"################ Plugin confiigs and maps ################
" use lightline plugin to display fancy onedark statusline with git branch
let g:lightline = {
        \ 'colorscheme': 'onedark',
        \ 'active': {
        \   'left': [  [ 'mode', 'paste' ],
        \              [ 'gitbranch', 'readonly', 'filename', 'modified' ] ],
        \   'right': [ [ 'lineinfo' ], [ 'percent' ],
        \              [ 'fileformat' , 'fileencoding' ] ]
        \ },
        \ 'component_function': {
        \   'gitbranch': 'FugitiveHead'
        \ },
        \ }

" git gutter character customization to be consistent with idea
let g:gitgutter_sign_added = '▓'
let g:gitgutter_sign_modified = '▓'
let g:gitgutter_sign_removed = '▶'

" tpope/rhubarb config to use Cloudera internal github
let g:github_enterprise_urls = ['https://github.infra.cloudera.com']

" vim-plug plugin manager config
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ale plugin: disable highlights
let g:ale_set_highlights = 0

let vim_markdown_preview_github=1

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
" Start NERDTree and put the cursor back in the other window.
autocmd VimEnter * NERDTree | wincmd p
" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif


au BufRead,BufNewFile *.conf set filetype=dosini  " turn on syntax for .conf files


"################ General config ################
set nocompatible                " use Vim default settings instead of Vi
set backspace=indent,eol,start  " allow backspacing over indention, line breaks and insertion start
set history=1000                " bigger history of executed commands
set showcmd                     " at the bottom show partial commands being typed (e.g. ya...) in normal mode / selected area in visual mode
set noshowmode                  " dont show current mode in the statusline, lightline plugin takes care of it
set autoread                    " automatically reload filesystem changes
set hidden                      " let current buffer being sent to the background without writing to disk
set confirm                     " show confirmation dialog when closing an unsaved file


"################ User interface ################
set laststatus=2                " always show status bar
set wildmenu                    " display command line's tab complete option as a menu
set tabpagemax=40               " enable more tabs to be opened
set number                      " show cursorline's absolute line number
" for other lines use absolute line numbers in insert mode, relative in other modes
augroup toggle_relative_number
autocmd InsertEnter * :setlocal norelativenumber
autocmd InsertLeave * :setlocal relativenumber
"set visualbell t_vb=           " turn off error beep/flash
"set novisualbell               " turn off visual bell
"set noerrorbells               " don't beep on errors
set visualbell                  " flash screen on error
set mouse=a                     " enable using the mouse for scrolling, selecting
set title                       " set the window's title, reflecting the file currently being edited
set background=dark
colorscheme onedark             " set color scheme to the one used by atom
set cursorline                  " mark the entire line the cursor is currently in
" use bold characters on the entire line the cursor is currently in
highlight CursorLine term=bold cterm=bold


"################ Auxiliary vim files ################
set directory=$HOME/.vim/swp//  " Put swap files into ~/.vim/swp. `//` tells vim to use the absolute path of the opened file to name the swap file
set nobackup                    " Don't use backup files, use git instead
set nowritebackup               " Don't use backup files, use git instead
set undofile                    " Maintain undo history between sessions
set undodir=$HOME/.vim/undodir  " Put undo history files to ~/.vim/undodir, not locally next to the file


"################ Indentations ################
set autoindent                  " new lines inherit the indentation of previous lines
filetype plugin indent on       " load indent file for specific file type indentation instead of old smartindent
set tabstop=4                   " show existing tabs with 4 spaces width
set shiftwidth=2                " when indenting with >, use 2 spaces
set expandtab                   " when pressing tab, insert 4 spaces
set wrap                        " wrap lines


"################ Search options ################
set hlsearch		            " highlight search
set incsearch		            " incremental search
set showmatch                   " jump to matches when entering regexp
set ignorecase                  " ignore case when searching
set smartcase                   " no ignorecase if Uppercase char present


"################ Text rendering ################
set encoding=utf-8              " use unicode supporting encoding
set fileencoding=utf-8
set linebreak                   " wrap lines at convenient points not in the middle of a word
set scrolloff=3                 " number of lines to keep above/below the cursor
set sidescrolloff=5             " number of columns to keep left/right from the cursor
syntax on                       " turn syntax highlighting on by default
filetype on                     " detect type of file


"################ Folding ################
set foldenable                  " enable folding
set foldlevelstart=10           " open most of the folds by default. If set to 0, all folds will be closed.
set foldnestmax=10              " folds can be nested. Setting a max value protects you from too many folds.
set foldmethod=syntax           " enable folding e.g a json array or a python method
set foldcolumn=0                " indicate folds on the left column 0 levels deep.


"################ Misc ################

" fix gx bug on vim8, source: https://github.com/vim/vim/issues/4738#issuecomment-714609892
function! OpenURLUnderCursor()
  let s:uri = matchstr(getline('.'), '[a-z]*:\/\/[^ >,;()]*')
  let s:uri = shellescape(s:uri, 1)
  if s:uri != ''
    silent exec "!open '".s:uri."'"
    :redraw!
  endif
endfunction
nnoremap gx :call OpenURLUnderCursor()<CR>

" show whitespaces by default, toggle with F4
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<,space:· "whitespaces to show
set list
noremap <F4> :set list!<CR>

set exrc                        " use project specific vimrc files
autocmd BufWritePre * :%s/\s\+$//e 	 " exterminatus to trailing whitespaces

set display+=lastline           " display lines partially that are too long to fit the screen

set clipboard=unnamed           " yank into clipboard by default
set t_RV=                       " http://bugs.debian.org/608242, http://groups.google.com/group/vim_dev/browse_thread/thread/9770ea844cec3282


let g:netrw_liststyle = 3       " netrw: use tree style directory listing (e.g. :40vs +Ex)
let g:netrw_browse_split = 4    " netrw: open file in previous window beside netrw split
let g:netrw_winsize = 20        " width of netrw split is 20% of the entire vim window


" Set the title of the Terminal to the currently open file, credits: https://gist.github.com/bignimbus/1da46a18416da4119778
function! SetTerminalTitle()
    let titleString = expand('%:t')
    if len(titleString) > 0
        let &titlestring = expand('%:t')
        " this is the format iTerm2 expects when setting the window title
        let args = "\033];".&titlestring."\007"
        let cmd = 'silent !echo -e "'.args.'"'
        execute cmd
        redraw!
    endif
endfunction
autocmd BufEnter * call SetTerminalTitle()

" git commit opens vim in insert mode when run from terminal
autocmd FileType gitcommit exec 'au VimEnter * startinsert'


"################ Maps (shortcuts) ################
" Use space as leader key
let mapleader = "\<Space>"

" when pressing n/N show previous/next match in the middle of the screen
nnoremap n nzz
nnoremap N Nzz

" press `,/` to turn off search highlighting
nmap <silent> ,/ :nohlsearch<CR>

" press Ctrl-K/Ctrl-J to get to previous/next buffer
map <C-S-K> :bprev<CR>
map <C-S-J> :bnext<CR>

"Jump back to last edited buffer
nnoremap <C-b> <C-^>
inoremap <C-b> <esc><C-^>

" jump between opened windows with Ctrl-H/J/K/L
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" make . to work with visually selected lines
vnoremap . :normal.<CR>

" use Ctrl-space to autocomplete words in insert mode
inoremap <Nul> <C-n>

" fuzzy find and open file with <LEADER>+Shift+O
nnoremap <Leader>O :Files<CR>

" Move visually selected lines up/down by pressing J/K
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" <LEADER>c to write buffer to file, git add, commit in verbose mode and reload so GitGutter shows the updated buffer state
nnoremap <Leader>c :w<CR> :Git commit -av<CR>k :e<CR>

" surround with ", ' or delete the quatation
nnoremap <Leader>q" ciw""<Esc>P
nnoremap <Leader>q' ciw''<Esc>P
nnoremap <Leader>q{ ciw{}<Esc>P
nnoremap <Leader>q} ciw{}<Esc>P
nnoremap <Leader>q[ ciw[]<Esc>P
nnoremap <Leader>q] ciw[]<Esc>P
nnoremap <Leader>qd daW"=substitute(@@,"'\\\|\"","","g")<CR>P

" quote shell variable properly,
" e.g. $VAR --> \qv --> <doublequote>$VAR<doublequote>
nnoremap <Leader>qv F$xciw""<Esc>Pbi$<Esc>

" prettyfy json with Control+Shift+P
nnoremap <silent> <C-S-P> : %!python -m json.tool<CR>
xnoremap <f1> "zy:!open "http://www.google.com/search?q=<c-r>=substitute(@z,' ','%20','g')<cr>"<return>gv
" insert current timestamp in normal mode by pressing F5
nnoremap <F5> "=strftime("%A, %Y %B %d")<CR>P

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

nmap <leader>uh :GitGutterUndoHunk<cr>
