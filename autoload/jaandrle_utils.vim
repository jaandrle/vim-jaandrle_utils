
" #region Guard
if exists('g:load_jaandrle_utils')
  finish
endif
let g:load_jaandrle_utils= 1

let s:save_cpo = &cpo
set cpo&vim
" #endregion

function! jaandrle_utils#trimEndLineSpaces(line_start, line_end)
    let b:pos= getpos(".") | let b:s= @/
    execute a:line_start.','.a:line_end.'s/\s\+$//e' | nohl
    let @/= b:s | call setpos('.', b:pos)
endfunction
let g:jaandrle_utils#last_command= ''
function! jaandrle_utils#grep(...)
    let g:jaandrle_utils#last_command= join([substitute(&grepprg, ' /dev/null', '', '')] + [expandcmd(join(a:000, ' '))], ' ')
    return system(g:jaandrle_utils#last_command)
endfunction
function! jaandrle_utils#redir(is_keep, command, range, line_start, line_end)
    let exit= a:is_keep==1 ? 'bw' : 'q'
    let pre_command = join(map(split(a:command), 'expand(v:val)'))
    if pre_command=~ '^!'
        if a:range!=0
            let joined_lines = join(getline(a:line_start, a:line_end), '\n')
            let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
            let command= pre_command . " <<< $" . cleaned_lines
        else 
            let command= pre_command
        endif
    else
        let command= pre_command
        redir => output
        silent execute command
        redir END
    endif
    let w:scratch = 1
    if a:is_keep==1
        silent! execute 'e '.fnameescape(command)
        setlocal buftype=nofile noswapfile nowrap number
    else
        let winnr_id = bufwinnr('^' . command . '$')
        silent! execute  winnr_id < 0 ? 'botright new ' . fnameescape(command) : winnr_id . 'wincmd w'
        setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap number
    endif
    echo 'Execute "' . command . '"...'
    if command=~ '^!'
        silent! execute 'silent %'. command
    else
        call setline(1, split(output, "\n"))
    endif
    if command=~ '^!git'
        setlocal filetype=git
    endif
    if a:is_keep==0
        execute 'wincmd ='
        let max_height= float2nr(round(winheight('0') / 2))
        execute 'resize ' . min([ max_height, line('$') ])
    endif
    silent! redraw!
    silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
    silent! execute 'nnoremap <silent> <buffer> ;e :call jaandrle_utils#redir('.a:is_keep.', '''.a:command.''', '.a:range.', '.a:line_start.', '.a:line_end.')<cr>'
    silent! execute 'nnoremap <silent> <buffer> ;q :'.exit.'<CR>'
    silent! execute 'nnoremap <silent> <buffer> gf gf:only<cr>'
    if line('$')==1 && col('$')==1
        silent! execute exit
        echomsg 'Command "' . command . '" executed and nothing to redirect.'
    endif
endfunction
function! jaandrle_utils#AppendModeline(additional)
    let l:modeline= printf(" vim: set tabstop=%d shiftwidth=%d textwidth=%d %sexpandtab :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
    let l:modeline= substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
    
    if !a:additional | return 0 | endif
    if &foldmethod=="marker"
        let l:modeline= printf(" vim>60: set foldmethod=marker foldmarker=%s :",
            \ &foldmarker)
    elseif &foldmethod=="indent"
        let l:modeline= printf(" vim>60: set foldmethod=indent foldlevel=%d foldnestmax=%d:",
            \ &foldlevel, &foldnestmax)
    else
        return 0
    endif
    let l:modeline= substitute(&commentstring, "%s", l:modeline, "")
    call append(line("$"), l:modeline)
endfunction
function! jaandrle_utils#MapSmartKey(key_name)
    let cmd = '<sid>Smart'.a:key_name
    exec 'nmap <silent><'.a:key_name.'> :call '.cmd.'("n")<CR>'
    exec 'imap <silent><'.a:key_name.'> <C-r>='.cmd.'("i")<CR>'
    exec 'vmap <silent><'.a:key_name.'> <Esc>:call '.cmd.'("v")<CR>'
endfunction
function! s:SmartHome(mode)
    " #region …
    let curcol = col(".")
    "gravitate towards beginning for wrapped lines
    if curcol > indent(".") + 2
        call cursor(0, curcol - 1)
    endif
    if curcol == 1 || curcol > indent(".") + 1
        if &wrap
            normal g^
        else
            normal ^
        endif
    else
        if &wrap
            normal g0
        else
            normal 0
        endif
    endif
    if a:mode == "v"
        normal msgv`s
    endif
    return ""
    " #endregion
endfunction
function! s:SmartEnd(mode)
    " #region …
    let curcol = col(".")
    let lastcol = a:mode == "i" ? col("$") : col("$") - 1
    "gravitate towards ending for wrapped lines
    if curcol < lastcol - 1
        call cursor(0, curcol + 1)
    endif
    if curcol < lastcol
        if &wrap
            normal g$
        else
            normal $
        endif
    else
        normal g_
    endif
    "correct edit mode cursor position, put after current character
    if a:mode == "i"
        call cursor(0, col(".") + 1)
    endif
    if a:mode == "v"
        normal msgv`s
    endif
    return ""
    " #endregion
endfunction
"see https://vi.stackexchange.com/a/180
function! jaandrle_utils#copyRegister()
    echo "Copy content of the register: "
    let sourceReg = nr2char(getchar())
    if sourceReg !~# '\v^[a-z0-9"]'
        echon sourceReg." – invalid register"
        return
    endif
    echon sourceReg."\ninto the register: "
    let destinationReg = nr2char(getchar())
    if destinationReg !~# '\v^[a-z0-9]'
        echon destinationReg." – invalid register"
        return
    endif
    call setreg(destinationReg, getreg(sourceReg, 1))
    echon destinationReg
endfunction
function! jaandrle_utils#gotoJumpChange(cmd)
    let l:key_shotcuts= a:cmd=="jump" ? [ "\<c-i>", "\<c-o>" ] : [ "g;", "g," ]
    set nomore
    execute a:cmd."s"
    set more
    let j = input("[see help for ':".a:cmd."(s).' | -/+ for up/down]\nselect ".a:cmd.": ")
    if j == '' | return 0 | endif

    let pattern = '\v\c^\+'
    if j =~ pattern
        let j = substitute(j, pattern, '', 'g')
        execute "normal " . j . l:key_shotcuts[0]
    else
        execute "normal " . j . l:key_shotcuts[1]
    endif
endfunction

" #region Finish
let &cpo = s:save_cpo
unlet s:save_cpo
" #endregion

" vim: set tabstop=4 shiftwidth=4 textwidth=250 expandtab :
" vim>60: set foldmethod=marker foldmarker=#region,#endregion :
