"        _
" __   _(_)_ __ ___  _ __ ___
" \ \ / / | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
" (_)_/ |_|_| |_| |_|_|  \___|
"
" Encoding {{{
set encoding=utf-8
scriptencoding utf-8
" }}}

" Environment {{{
function! VimrcEnvironment()
  let env = {}
  let env.is_unix = has('unix')
  let env.is_mac = has('mac')
  let env.is_win = has('win32')

  let user_dir = env.is_win
        \ ? expand('$VIM/vimfiles')
        \ : expand('~/.vim')
  let env.path = {
        \   'user':          user_dir,
        \   'plugins':       user_dir . '/plugins',
        \   'data':          user_dir . '/data',
        \   'local_vimrc':   user_dir . '/.vimrc_local',
        \   'undo':          user_dir . '/data/undo',
        \   'vim_plug':      user_dir . '/vim-plug',
        \ }

  return env
endfunction

let s:env = VimrcEnvironment()
" }}}

" Plugins {{{
function! s:plugins()
  " Completion {{{
  Plug 'Shougo/deoplete.nvim'
  Plug 'Shougo/neosnippet'
  Plug 'Shougo/neosnippet-snippets'
  Plug 'cohama/lexima.vim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
  Plug 'tpope/vim-surround'
  " }}}
  " Appearance {{{
  Plug 'Shougo/context_filetype.vim'
  Plug 'cocopon/iceberg.vim'
  Plug 'godlygeek/tabular'
  Plug 'lilydjwg/colorizer', { 'for': ['css', 'vim', 'scss'] }
  Plug 'morhetz/gruvbox'
  Plug 'osyo-manga/vim-precious'
  Plug 'vim-airline/vim-airline'
  " }}}
  " Filetype {{{
  Plug 'NLKNguyen/c-syntax.vim'
  Plug 'cespare/vim-toml'
  Plug 'digitaltoad/vim-pug'
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
  Plug 'othree/html5.vim'
  Plug 'pangloss/vim-javascript'
  Plug 'plasticboy/vim-markdown'
  Plug 'posva/vim-vue'
  " }}}
  " Git {{{
  Plug 'airblade/vim-gitgutter'
  Plug 'tpope/vim-fugitive'
  " }}}
  " Search {{{
  Plug 'AndrewRadev/linediff.vim'
  Plug 'dhruvasagar/vim-open-url'
  Plug 'easymotion/vim-easymotion'
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'
  " }}}
  " Utility {{{
  if !has('kaoriya')
    if s:env.is_win
      Plug 'Shougo/vimproc.vim', { 'do': 'mingw32-make' }
    else
      Plug 'Shougo/vimproc.vim', { 'do': 'make' }
    endif
  endif
  Plug 'LeafCage/yankround.vim'
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'cocopon/vaffle.vim'
  Plug 'haya14busa/vim-asterisk'
  Plug 'kana/vim-operator-user'
  Plug 'osyo-manga/vim-operator-search'
  Plug 'thinca/vim-quickrun'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-speeddating'
  Plug 'tyru/restart.vim'
  Plug 'vim-jp/vimdoc-ja'
  " }}}

  let s:colorscheme = 'gruvbox'

  return 1
endfunction
" }}}

" Setup {{{
function! VimrcSetUp()
  call s:install_plugin_manager()
endfunction
" }}}


" Installation {{{
function! s:install_plugins()
  call mkdir(s:env.path.plugins, 'p')

  if exists(':PlugInstall')
    PlugInstall
    return 1
  endif

  return 0
endfunction

function! s:clone_repository(url, local_path)
  if isdirectory(a:local_path)
    return
  endif

  execute printf('!git clone %s %s', a:url, a:local_path)
endfunction

function! s:install_plugin_manager()
  call mkdir(s:env.path.user, 'p')
  call mkdir(s:env.path.data, 'p')

  call s:clone_repository(
        \ 'https://github.com/junegunn/vim-plug',
        \ s:env.path.vim_plug . '/autoload')

  if !s:activate_plugin_manager()
    return 0
  endif

  if !s:install_plugins()
    return 0
  endif

  echo 'Restart vim to finish the installation.'
  return 1
endfunction
" }}}


" Activation {{{
function! s:load_plugin(path)
  try
    execute 'set runtimepath+=' . a:path

    return 1
  catch /:E117:/
    " E117: Unknown function
    return 0
  endtry
endfunction

function! s:activate_plugins()
  if !exists(':Plug')
    " Plugin manager is not installed yet
    return 0
  endif

  return s:plugins()
endfunction

function! s:activate_plugin_manager_internal()
  " Activate plugin manager
  if !exists(':Plug')
    execute 'set runtimepath+=' . s:env.path.vim_plug
  endif
  call plug#begin(s:env.path.plugins)

  try
    " Activate plugins
    return s:activate_plugins()
  finally
    call plug#end()
    syntax enable
    filetype plugin indent on
  endtry
endfunction

function! s:activate_plugin_manager()
  try
    return s:activate_plugin_manager_internal()
  catch /:E117:/
    " E117: Unknown function
    " Plugin manager is not installed yet
    return 0
  endtry
endfunction
" }}}

" Initialization {{{
call mkdir(s:env.path.undo, 'p')
let s:plugins_activated = s:activate_plugin_manager()
" }}}

" Key mapping {{{
let mapleader = "\<Space>"

" In TERMINAL mode, press Esc key to go to NORMAL mode
tnoremap <silent> <Esc> <C-\><C-n>0

nnoremap <C-t> :tabnew<CR>
nnoremap <silent> <CR> :nohlsearch<CR>
inoremap <C-l> <Del>
inoremap jj <Esc>

" tagjump
nnoremap <C-]> g<C-]>
nnoremap <C-h> :vsplit<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <C-k> :split<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <C-Left> :pop<CR>

" windows movement
nnoremap <Leader>wh <C-w>H
nnoremap <Leader>wj <C-w>J
nnoremap <Leader>wk <C-w>K
nnoremap <Leader>wl <C-w>L
nnoremap <Leader>wt <C-w>T

" For US keyboard
noremap ; :

" Generate a tags file
function! s:output_result(ch, exit_status)
  if !a:exit_status
    echomsg 'Success generating a tags file'
  else
    echoerr 'Failure generating a tags file'
  endif
endfunction

function! GenerateTags()
  let l:job = job_start(
        \ ['ctags', '-R'],
        \ {'exit_cb': function('s:output_result')}
        \ )
endfunction

nnoremap <Leader>t :call GenerateTags()<CR>

" Disable key mappings
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
" }}}

" Indent {{{
" http://peace-pipe.blogspot.com/2006/05/vimrc-vim.html
set tabstop=4
set shiftwidth=4
set softtabstop=0
set expandtab
set smarttab
" }}}

" File types {{{
augroup vimrc
  autocmd!
  autocmd FileType html  setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType ruby  setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType scss  setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType css   setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType eruby setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType vim   setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType zsh   setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType pug   setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
  autocmd FileType vue   setlocal softtabstop=0 shiftwidth=2 tabstop=2 expandtab
augroup END
" }}}

" Search {{{
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
" }}}

" Backup {{{
set nobackup
set noswapfile
let &undodir = s:env.path.undo
set undofile
" }}}

" Appearance {{{
set number
set ruler
set scrolloff=8
set sidescrolloff=16
set sidescroll=1
set cursorline
set list
set listchars=tab:»-,trail:_,eol:↲,extends:»,precedes:«,nbsp:%
set laststatus=2
" }}}

" Highlight {{{
set synmaxcol=400
augroup vimrc-highlight
  autocmd!
  autocmd Syntax * if 10000 < line('$') | syntax sync minlines=100 | endif
augroup END
" set gui colors on cui vim
if exists('$TMUX')
  " Colors in tmux
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
set termguicolors
set background=dark
" }}}

" Cursor {{{
if has('vim_starting')
  " Non blink vertical bar type cursor on INSERT mode
  let &t_SI .= "\e[6 q"
  " Non blink block type cursor on NORMAL mode
  let &t_EI .= "\e[2 q"
  " Non blink underscore type cursor on REPLACE mode
  let &t_SR .= "\e[4 q"
endif
" Enable movement across lines by moving the cursor left and right
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
" }}}

" Misc {{{
set confirm
set autoread
set hidden
set belloff=all
set clipboard=unnamed,unnamedplus
" Make Windows path separator slash
set shellslash
set wildmenu wildmode=longest,full
set history=10000
set lazyredraw
" }}}

" Color hex to func {{{
function! HexToFunc(hex)
  let color = matchlist(a:hex, '\([0-9A-F]\{2\}\)\([0-9A-F]\{2\}\)\([0-9A-F]\{2\}\)')
  return 'rgb(' . printf('%d', '0x' . color[1]) . ', ' . printf('%d', '0x' . color[2]) . ', ' . printf('%d', '0x' . color[3]) . ')'
endfunction

command!
      \ HexToFunc
      \ :%s/\(#[0-9A-F]\{6\}\)/\=HexToFunc(submatch(1))/gi
" }}}

" Plugin settings {{{
if s:plugins_activated
  " easymotion {{{
  map <Space><Space> <Plug>(easymotion-prefix)
  map f <Plug>(easymotion-f)
  map F <Plug>(easymotion-F)
  map t <Plug>(easymotion-t)
  map T <Plug>(easymotion-T)
  " }}}

  " yankround {{{
  nmap p <Plug>(yankround-p)
  xmap p <Plug>(yankround-p)
  nmap P <Plug>(yankround-P)
  nmap gp <Plug>(yankround-gp)
  xmap gp <Plug>(yankround-gp)
  nmap gP <Plug>(yankround-gP)
  nmap <C-p> <Plug>(yankround-prev)
  nmap <C-n> <Plug>(yankround-next)
  " }}}

  " fzf.vim {{{
  nnoremap <silent> <C-c> :FZF<CR>
  nnoremap <silent> <C-b> :Buffers<CR>
  nnoremap <silent> q: :History:<CR>
  nnoremap <silent> q/ :History/<CR>
  " }}}

  " gruvbox {{{
  let g:gruvbox_italic = 0
  let g:gruvbox_contrast_dark = 'hard'
  " }}}

  " restart.vim {{{
  command!
        \ -bar
        \ RestartWithSession
        \ let g:restart_sessionoptions = 'blank,curdir,folds,help,localoptions,tabpages'
        \ | Restart
  " }}}

  " vim-operator-search {{{
  nmap <Leader>s <Plug>(operator-search)
  nmap <Leader>/ <Plug>(operator-search)if
  " }}}

  " deoplete {{{
  if !s:env.is_win
    let g:deoplete#enable_at_startup = 1
    call deoplete#custom#option('auto_complete', v:false)
    inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ deoplete#mappings#manual_complete()
    function! s:check_back_space() abort "{{{
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~? '\s'
    endfunction "}}}
  endif
  " }}}

  " neosnippet {{{
  " Plugin key-mappings.
  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <C-k> <Plug>(neosnippet_expand_target)

  " For conceal markers.
  if has('conceal')
    set conceallevel=2 concealcursor=nv
  endif
  " }}}

  " vim-markdown {{{
  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_no_default_key_mappings = 1
  let g:vim_markdown_conceal = 0
  " }}}

  " Japaneseization of help doc {{{
  set helplang=ja,en
  " }}}

  " quickrun {{{
  " Asynchronous execution by vimproc
  " Display buffers on success, display Quickfix on failure
  " Resize result window
  let g:quickrun_config = {
        \   '_' : {
        \   'runner' : 'vimproc',
        \   'runner/vimproc/updatetime' : 40,
        \   'outputter' : 'error',
        \   'outputter/error/success' : 'buffer',
        \   'outputter/error/error'   : 'quickfix',
        \   'outputter/buffer/split' : ':botright 8sp',
        \   }
        \ }

  let g:quickrun_config.python = {
        \ 'command': 'python3'
        \ }

  " Save the buffer, close the previous result and execute
  let g:quickrun_no_default_key_mappings = 1
  nmap <Leader>r :cclose<CR>:write<CR>:QuickRun -mode n<CR>
  " }}}

  " vim-asterisk {{{
  map *   <Plug>(asterisk-*)N
  map #   <Plug>(asterisk-#)N
  map g*  <Plug>(asterisk-g*)N
  map g#  <Plug>(asterisk-g#)N
  map z*  <Plug>(asterisk-z*)N
  map gz* <Plug>(asterisk-gz*)N
  map z#  <Plug>(asterisk-z#)N
  map gz# <Plug>(asterisk-gz#)N
  " }}}
endif
" }}}

" Local settings {{{
if filereadable(s:env.path.local_vimrc)
  execute 'source ' . s:env.path.local_vimrc
endif
" }}}

" Color scheme {{{
if s:plugins_activated
  if !has('gui_running')
    execute printf('colorscheme %s', s:colorscheme)
  else
    augroup vimrc_colorscheme
      autocmd!
      execute printf('autocmd GUIEnter * colorscheme %s', s:colorscheme)
    augroup END
  endif
endif
" }}}

