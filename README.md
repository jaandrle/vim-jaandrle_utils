# jaandrle_utils.vim

Some helper functions used in my `.vimrc`.

## Installation

Install using your favorite package manager, or use Vim's built-in package
support:

    mkdir -p ~/.vim/bundle/vim-jaandrle_utils
    cd ~/.vim/bundle/vim-jaandrle_utils
    git clone https://github.com/jaandrle/vim-jaandrle_utils.git

In `.vimrc`:

    set runtimepath^=~/.vim/bundle/*

Now, you can use any function.

## Functions list
<details> <summary> <code> function! jaandrle_utils#trimEndLineSpaces(line_start, line_end) </code> </summary>
    The name doesn't lie
</details>
<details> <summary> <code>
function! jaandrle_utils#fold_nextClosed(dir)
    
function! jaandrle_utils#fold_nextOpen(dir)
</code> </summary>
    Use `j`/`k` as arguments, navigates to the next fold.
</details>
<details> <summary> <code> function! jaandrle_utils#grep(...) </code> </summary>

    `:grep` alternative which is asynchronous and also uses system grep tool (see `:help 'grepprg'`)
</details>
<details> <summary> <code> function! jaandrle_utils#redir(is_keep, command, range, line_start, line_end) </code> </summary>

    Redirecs any Vim `command` to ‘nofile’ buffer, `is_keep` modify deleting buffer when leaving and also (no)split.
    ```
    command! -complete=command -bar -range -nargs=+ ALTredir call jaandrle_utils#redir(0, <q-args>, <range>, <line1>, <line2>)
    " run curent line(s) in node
    '<,'>ALTredir !node
    " changes in buffer
    ALTredir changes
    ```
</details>
<details> <summary> <code> function! jaandrle_utils#AppendModeline(additional) </code> </summary>

    Add current `modeline` (see `:help modeline`)
</details>
<details> <summary> <code> function! jaandrle_utils#MapSmartKey(key_name) </code> </summary>

    Argument `Home`/`End` → smart key behav. (first, first nonwhite, hadle wrap, …)
</details>
<details> <summary> <code> function! jaandrle_utils#copyRegister() </code> </summary>

    To copy content between registers
</details>
<details> <summary> <code> function! jaandrle_utils#gotoJumpChange(cmd) </code> </summary>

    Argument can be `"jump"`/`"changes"`, invokes combination of showing list and option to navigate
</details>
<details> <summary> <code> function! jaandrle_utils#gotoJumpListDI(move, key) </code> </summary>

    Argument can be `"["`/`"]"` for `move` and `"I"`/`"D"` for `key`, invokes combination of showing list and option to navigate
</details>

## TODO
- [ ] better README
- [ ] tbd
