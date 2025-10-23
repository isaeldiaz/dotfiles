nnoremap <F10> :h brody-vim-config<CR>

" to fix color rendering with tmux
set termguicolors

" Git config
let g:fugitive_diff_tool = 'vimdiff'

" Change grep behavior
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

set expandtab                 " To make tabs into spaces
set tabstop=2
set shiftwidth=2
set hlsearch
set nomousehide
set diffopt+=algorithm:patience
set guioptions-=T  "remove toolbar
filetype indent on


" Associate r files to XML syntax
 au BufNewFile,BufRead *.r setlocal ft=xml
" associate *.upf with Tcl filetype
au BufRead,BufNewFile *.upf set filetype=tcl

" Remove character : from word delimiter when is a perl file
autocmd FileType perl setlocal iskeyword-=:

" ----------------------------------
" Font Adjust sections
if has('win32') || has ('win64')
  let s:fonttype = 'Consolas:h'
else
  let s:fonttype = 'Monospace:h'
endif



let s:fontsize = 11
if exists('g:neovide')
  :execute "set guifont=" . s:fonttype . s:fontsize
endif

function! AdjustFontSize(amount)
  let s:fontsize = s:fontsize+a:amount
  if exists('g:neovide')
    :execute "set guifont=" . s:fonttype . s:fontsize
  else
    :execute "GuiFont! " . s:fonttype . s:fontsize
  endif
endfunction

noremap <C-ScrollWheelUp> :call AdjustFontSize(1)<CR>
noremap <C-ScrollWheelDown> :call AdjustFontSize(-1)<CR>
inoremap <C-ScrollWheelUp> <Esc>:call AdjustFontSize(1)<CR>a
inoremap <C-ScrollWheelDown> <Esc>:call AdjustFontSize(-1)<CR>a


if has('win32') || has ('win64')
  "To use powershell (on Windows): >
  set shell=powershell.exe
  set shellxquote=
  let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
  let &shellquote   = ''
  let &shellpipe    = '| Out-File -Encoding UTF8 %s'
  let &shellredir   = '| Out-File -Encoding UTF8 %s'

endif


" ----------------------------------
"  Mouse support toggling
function! ToggleMouseSupport()
  if &mouse == 'a'
    set mouse=
    echo "Mouse support OFF"
  else
    set mouse=a
    echo "Mouse support ON"
  endif
endfunction

nnoremap <C-l> :call ToggleMouseSupport()<CR>
    

" ===========  Plug 'flazz/vim-colorschemes'
colorscheme wombat
set background=dark

" ========== Plug 'vim-airline/vim-airline'
let g:airline_theme='distinguished'

" ========== Plug 'plasticboy/vim-markdown'
autocmd FileType markdown normal zR
let g:vim_markdown_conceal = 0
let g:vim_markdown_math = 1

au FileType markdown syn clear htmlTag
au FileType markdown syn clear htmlEndTag

" ========== Plug 'easymotion/vim-easymotion'
map  <Leader>w <Plug>(easymotion-bd-w)
map  <Leader>f <Plug>(easymotion-bd-f)
nmap <Leader>s <Plug>(easymotion-overwin-f2)

" ============  Plug 'scrooloose/nerdtree'
map <F2> :NERDTreeToggle<CR>
map <F3> :NERDTreeFind %<CR>
map <Leader><F2> :NERDTreeFocus<CR>
let NERDTreeShowLineNumbers=1

"==========     Plug 'nvim-telescope/telescope.nvim'
nnoremap <leader>tf <cmd>Telescope find_files<cr>
"nnoremap <leader>tg <cmd>Telescope live_grep<cr>
nnoremap <leader>tb <cmd>Telescope buffers<cr>
nnoremap <leader>th <cmd>Telescope help_tags<cr>

lua require('telescope').load_extension('live_grep_args')
nnoremap <leader>tg <cmd>Telescope live_grep_args<cr>

"==========     Plug 'junegunn/vim-easy-align'
vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)



"==========     Plug 'jeffkreeftmeijer/vim-numbertoggle'
function! ToggleNumbers()
    if &number
        if &relativenumber
          set norelativenumber
        else
          set nonumber
          set norelativenumber
        endif
    else
        set number
        set relativenumber
    endif
endfunction

nnoremap <C-n> :call ToggleNumbers()<CR>

"==========     Plug 'ojroques/nvim-osc52'

" Set clipboard to use OSC52
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '+' | execute 'OSCYankReg +' | endif
set clipboard+=unnamedplus

" After installing, configure:
lua << EOF
require('osc52').setup {
  max_length = 0,      -- Maximum length of selection (0 for no limit)
  silent = false,      -- Disable message on successful copy
  trim = false,        -- Trim text before copy
}
EOF

