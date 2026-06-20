"#[what] Ctrl+C: copy visual selection to system clipboard
vnoremap <C-c> "+y

"#[what] Alt+Left / Alt+Right: move by word
nmap <Esc>b b
nmap <Esc>f w

"#[what] Cmd+Left / Cmd+Right: beginning / end of line
nnoremap <Char-0x01> 0
nnoremap <Char-0x05> g_
vnoremap <Char-0x01> 0
vnoremap <Char-0x05> g_

"#[what] Alt+Up / Alt+Down: jump 10 lines
nmap <Esc>p 10k
nmap <Esc>n 10j

"#[what] Alt+Z: toggle word wrap
nnoremap <Esc>z :set wrap!<CR>

"#[what] Cmd+Up / Cmd+Down: jump to top / bottom of file
nmap <Char-0x90>U gg
nmap <Char-0x90>D G

"#[what] Plain backspace: delete one char back
nmap <BS> X

"#[what] Alt+Backspace: delete word backward
nnoremap <Char-0x17> db

"#[what] Cmd+Backspace / Ctrl+Backspace: delete to start of line
nnoremap <Char-0x15> d0

"#[what] Delete: delete char forward
nmap <Del> x

"#[what] Alt+Delete: delete word forward
nmap <Esc>d dw

"#[what] Cmd+Delete: delete to end of line
nmap <Char-0x90>K d$

"#[what] Cmd+Z: undo
nmap <Char-0x90>z u

"#[what] Cmd+Shift+Z: redo
nmap <Char-0x90>Z <C-r>

"#[what] Cmd+S: save file
nmap <Esc>[115;9u :update<CR>

"#[what] Cmd+W: quit, prompting to save if there are unsaved changes
nmap <Char-0x90>w :confirm q<CR>

"#[what] Cmd+Shift+Up: select from cursor to top of file
nmap <Esc>[1;10A vgg

"#[what] Cmd+Shift+Down: select from cursor to bottom of file
nmap <Esc>[1;10B vG

"#[what] Shift+Arrows: start/extend selection (normal -> enters visual, visual -> extends)
nmap <Esc>[1;2A vk
nmap <Esc>[1;2B vj
nmap <Esc>[1;2D vh
nmap <Esc>[1;2C vl
vmap <Esc>[1;2A k
vmap <Esc>[1;2B j
vmap <Esc>[1;2D h
vmap <Esc>[1;2C l
