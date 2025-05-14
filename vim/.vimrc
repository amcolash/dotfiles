""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set various options for editor
set modeline
set ruler
set nu
set ai
set backspace=2
set tabstop=2 shiftwidth=2 expandtab

"runtime! ftplugin/man.vim

" Ignore whitespace in diffs
set diffopt+=iwhite
set diffexpr=""

" Change temp file directory to keep things tidy
"set backupdir=~/.vim/backup//
"set directory=~/.vim/swp//

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set shortcuts

" double tap 'i' to toggle insert mode
inoremap ii <Esc>
" Shift-Tab unindents
imap <S-Tab> <C-o><<

vnoremap <Tab> >gv
vnoremap <S-Tab> <gv
" Control-H clears search
nnoremap <C-H> :let @/=""<CR>
" Close all windows forcibly
nnoremap <C-Q> :qa!<CR>

" Allow scrolling on mac os
if has("mouse")
  set mouse=a
  set ttymouse=xterm2
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Change default highlighting for parenthesis and brackets
highlight MatchParen cterm=bold ctermbg=none ctermfg=cyan
" Highlight when over 120 characters in file
au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>120v.\+', -1)
" Highlight extra whitespace
highlight ExtraWhitespace ctermbg=yellow guibg=yellow
:match ExtraWhitespace /\s\+$\| \+\zs\t/

let @/=""

" associate special filetypes with syntax highlighting
au BufRead,BufNewFile *.jlex setfiletype java
au BufRead,BufNewFile *.cup setfiletype java
au BufRead,BufNewFile *.grammar setfiletype java
au BufRead,BufNewFile *.csx setfiletype c
au BufRead,BufNewFile *.out setfiletype c
au BufRead,BufNewFile *.spim setfiletype asm
au BufRead,BufNewFile *.hbs setfiletype html
au BufRead,BufNewFile *.glsl setfiletype cpp
au BufRead,BufNewFile *.less setfiletype css

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Removes trailing spaces
function TrimWhiteSpace()
    %s/\s*$//
    ''
:endfunction

" set list listchars=trail:.,extends:>
autocmd FileWritePre * :call TrimWhiteSpace()
autocmd FileAppendPre * :call TrimWhiteSpace()
autocmd FilterWritePre * :call TrimWhiteSpace()
autocmd BufWritePre * :call TrimWhiteSpace()

" Removes leading white spaces
function TrimLeadingSpace()
  %le
:endfunction

function ReIndent()
  :normal mzgg=G`z
:endfunction

function FullIndent()
  :call TrimLeadingSpace()
  :call ReIndent()
:endfunction

" F2 trims leading space
map <F2> :call TrimLeadingSpace()<CR>
"map! <F2> :call TrimLeadingSpace()<CR>

" F3 fixes the indenting of a selection
map <F3> :call ReIndent()<CR>

" F4 trims and then indents in on key
map <F4> :call FullIndent()<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set Colors and Color Mode
set t_Co=256
colorscheme wombat256mod

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Syntax highlighting and indenting stuff
syntax on
filetype plugin indent on

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Load packages
packloadall | silent! helptags ALL

" Transparent Backgrounds
highlight NonText ctermbg=none
highlight Normal ctermbg=none
highlight LineNr ctermbg=none
