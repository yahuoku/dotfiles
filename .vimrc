" Settings {{{
" ============

syntax on
set nocompatible
set mouse=a                     " Use mouse
set ttymouse=xterm2
set backspace=indent,eol,start  " Use backspace

set nowrap
set nofoldenable        " `zc` to fold
set clipboard+=unnamed  " Use clipboard register '*' by default
set splitright          " Split to right when `:vs`
set splitbelow          " Split to below when `:sp`
set scrolloff=1
set diffopt+=vertical
set wildmenu

" Visual
set title         " Show window title
set number        " Show line numbers
set cursorline    " Highlight current line
set laststatus=2  " Always show status bar
set noshowmode
set showcmd

" Indent
set autoindent
set expandtab  " Convert tabs to spaces
set tabstop=4
set softtabstop=4
set shiftwidth=4
autocmd FileType javascript setlocal ts=2 sts=2 sw=2

" Search
set incsearch
set ignorecase
" Don't highlight when reloading vimrc
if !&hlsearch | set hlsearch | endif

" 80 column ruler
set textwidth=80
set colorcolumn=+1

" Statusline
function! s:stl_update()
    let i = 1
    while i <= winnr('$')
        call setwinvar(i, '&statusline', StatusLineBuild(i))
        let i += 1
    endwhile
endfunction
autocmd BufWinEnter,WinEnter * call <SID>stl_update()

function! StatusLineBuild(winnr)
    let active_winnr = winnr()
    let mode = a:winnr == active_winnr ? '%#DiffAdd#%{StatusLineMode()}%*' : ''
    let left  = ['%n: %f %r%{&modified ? "*" : ""}']
    let right = [
        \   '%{StatusLineGit()}',
        \   '%{&filetype != ""   ? &filetype." / "   : ""}',
        \   '%{&fileformat != "" ? &fileformat." / " : ""}',
        \   '%L lines '
        \ ]
    return mode.' '.join(left, '').'%='.join(right, '').'%<'
endfunction

function! StatusLineMode()
    let mode_map = {
        \   'i': 'INSERT', 'R': 'REPLACE',
        \   'v': 'VISUAL', 'V': 'V-LINE', "\<C-v>": 'V-BLOCK',
        \   's': 'SELECT', 'S': 'S-LINE', "\<C-s>": 'S-BLOCK'
        \ }
    let mode_name = get(mode_map, mode(), '')
    return mode_name != '' ? '  '.mode_name.' ' : ''
endfunction

function! StatusLineGit()
    let branch = exists('*fugitive#head') ? fugitive#head() : ''
    if empty(branch)
        return ''
    endif
    let val = 'Git('.branch.')'
    if !empty(GitGutterGetHunks())
        let sum = GitGutterGetHunkSummary()
        let val .= printf(' +%d ~%d -%d', sum[0], sum[1], sum[2])
    endif
    return val.' / '
endfunction

" MacVim
" Quit after last window closes:
" defaults write org.vim.MacVim MMLastWindowClosedBehavior 2
if has('gui_macvim')
    set guioptions-=L
    set guifont=Menlo:h14
    set linespace=3

    " If it is not work properly, use Gureum IM.
    set noimdisable  " Auto change input source to english when escaping.
    set iminsert=1   " Don't change input source when entering insert mode.
    set imsearch=-1
endif

" True colors in terminal! (Vim 7.4.1770+)
" Refer to `:help xterm-true-color`
if !has('gui_running') && has('termguicolors')
    set termguicolors
    let &t_8f = "\e[38;2;%lu;%lu;%lum"
    let &t_8b = "\e[48;2;%lu;%lu;%lum"
endif

" }}}

" Keymaps, Commands {{{
" =====================

" Use `:help index` to see the default key bindings
" Split window: <C-w>s or <C-w>v

let mapleader = ','
nnoremap ; :
vnoremap ; :

nnoremap <silent> <C-s>      :update<CR>
inoremap <silent> <C-s> <C-o>:update<CR>
nnoremap <silent> q :confirm q<CR>
nnoremap <silent> Q :confirm qa<CR>

nnoremap <silent> <C-h> :bprevious<CR>
nnoremap <silent> <C-l> :bnext<CR>
nnoremap <silent> <C-j> :Startify<CR>
nnoremap <silent> <C-n> :NERDTreeToggle<CR>

nnoremap <C-v> *p
vnoremap <C-v> *p
inoremap <C-v> <C-r><C-r>*
cnoremap <C-v> <C-r><C-r>*

vnoremap > >gv
vnoremap < <gv

" Clear search highlight
nnoremap <silent> <BS> :nohlsearch<CR>

" If autocompletion popup visable, use <Tab> to select next item
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"

" Delete buffer without closing window
function! s:delete_buffer()
    if &modified | echom 'No write since last change!' | return | endif
    " Find all windows that show current buffer (%: curr, #: prev, $: last)
    for winnum in filter(range(1, winnr('$')), 'winbufnr(v:val) == bufnr("%")')
        execute winnum.'wincmd w'
        bprevious
    endfor
    silent! bdelete #  " Ignore 'No buffer were deleted'
endfunction
nnoremap <silent> <C-c> :call <SID>delete_buffer()<CR>

" Fugitive
function! s:on_fugitive()
    nnoremap <buffer> <C-g>  :Gstatus<CR>
    nnoremap <buffer> <C-g>g :Git
endfunction
autocmd User Fugitive call s:on_fugitive()

" OS X
if has('mac')
    nnoremap <C-k> :silent !open -a iTerm .<CR>
endif

" }}}

" Plugins {{{
" ===========

call plug#begin('~/.vim/bundle')

" PlugUpdate:  Install or update plugins
" PlugUpgrade: Upgrade vim-plug itself
" PlugClean:   Remove unused directories

"Plug 'zefei/cake16'
"Plug 'cocopon/iceberg.vim'
Plug 'aseom/snowcake16'
Plug 'junegunn/gv.vim', { 'on': 'GV' }
Plug 'junegunn/vim-peekaboo'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Shougo/neocomplete.vim'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-gitgutter'
Plug 'ap/vim-buftabline'

" Languages
Plug 'pangloss/vim-javascript'
Plug 'moll/vim-node', { 'for': 'javascript' }
Plug 'hdima/python-syntax'
Plug 'keith/swift.vim'
Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown'
Plug 'tmux-plugins/vim-tmux'

" Add plugins to &runtimepath
call plug#end()

" colorscheme
try
    colorscheme snowcake16
catch 'Cannot find color scheme'
    colorscheme default
endtry

" neocomplete
set completeopt=menuone  " Popup even one item, no preview
let g:neocomplete#enable_at_startup = 1

" nerdtree
let NERDTreeWinSize = 26
let NERDTreeMinimalUI = 1
let NERDTreeShowHidden = 1
let NERDTreeShowBookmarks = 1
let NERDTreeIgnore = ['\.swp$', '^\.DS_Store$', '^Thumbs.db$']
let NERDTreeAutoDeleteBuffer = 1
" Quit vim if NERDTree is only window
autocmd WinEnter * if winnr('$') == 1 && &ft == 'nerdtree' | q | endif

" fugitive
" resolve symlink when opening file
function! s:fugitive_resolve_symlink()
    let path     = expand('%:p')
    let realpath = resolve(path)
    if path != realpath && exists('*fugitive#detect')
        call fugitive#detect(realpath)
    endif
endfunction
autocmd BufReadPost * call <SID>fugitive_resolve_symlink()

" buftabline
let g:buftabline_numbers = 2
let g:buftabline_indicators = 1

" python-syntax
let g:python_highlight_all = 1
let g:python_version_2 = 1

" vim-markdown
let g:vim_markdown_folding_disabled = 1

" }}}

" vim:fdm=marker
