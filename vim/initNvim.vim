
if has('win32') || has ('win64')
  let plugPath='C:\Users\isdi\.config\nvim\plugged'
else
  let plugPath='~\.config\nvim\plugged'
endif

"call plug#begin('C:\Users\isdi\.config\nvim\plugged')
call plug#begin(plugPath)

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-git'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-rhubarb'
Plug 'jlanzarotta/bufexplorer'
Plug 'godlygeek/tabular'
Plug 'nachumk/systemverilog.vim'
Plug 'icymind/NeoSolarized'
Plug 'finbarrocallaghan/highlights.vim'
Plug 'chrisbra/vim-diff-enhanced'
Plug 'scrooloose/nerdtree'
Plug 'triglav/vim-visual-increment'
Plug 'tomtom/tlib_vim'
Plug 'Yggdroot/indentLine'
Plug 'jeffkreeftmeijer/vim-numbertoggle'
Plug 'plasticboy/vim-markdown'
Plug 'flazz/vim-colorschemes'
Plug 'mhinz/vim-grepper'
Plug 'scrooloose/nerdcommenter'
Plug 'easymotion/vim-easymotion'
call plug#end()

set number relativenumber

" enable line numbers
let NERDTreeShowLineNumbers=1
"Open NERDTree with Ctrl+n
map <C-n> :NERDTreeToggle<CR>


" Enable solarized
 colorscheme NeoSolarized
set background=dark


 "Show all hidden characters except spaces
 set listchars=tab:>-,trail:~,extends:>,precedes:<
 set list
 

 " Associate r files to XML syntax
 au BufNewFile,BufRead *.r setlocal ft=xml
 
 set expandtab
 set tabstop=2
 set shiftwidth=2
 filetype indent on
 set hlsearch
 set number
 set nomousehide
 set mouse=a

" Map the leader key to SPACE
let mapleader="\<SPACE>"

" Can be typed even faster than jj, and if you are already in
"    normal mode, you (usually) don't accidentally move:
:imap kj <Esc>

" Remove = and : from the filename characters
set isfname-=:
set isfname-==