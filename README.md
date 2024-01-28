# vim-denote-md

Companion plugin for [denote-md.sh](https://github.com/shuckster/denote-md).

## Installation

```vim
Plug 'shuckster/vim-denote-md'
```

Or just use that path in your favourite plugin manager.

Then add the following to your `.vimrc` / `init.vim`:

```vim
" Define where your denote-md script is located
let g:denote_md_script = $DENOTE_MD_SCRIPT_PATH

" Add your denote-md remaps
if filereadable(g:denote_md_script)
   nnoremap <Leader>dn :DenoteNewNote<CR>
   nnoremap <Leader>dt :DenoteChangeTitle<CR>
   nnoremap <Leader>dg :DenoteChangeTags<CR>
   nnoremap <Leader>dl :DenotePutNotesListForTags<CR>
   nnoremap <Leader>da :DenotePutNoteActionsForTags<CR>
   nnoremap <Leader>db :DenotePutNoteBacklinksForBuffer<CR>
   nnoremap <Leader>df :DenoteFollowLink<CR>
endif
```

Assuming:

```sh
export DENOTE_MD_SCRIPT_PATH=/path/to/denote-md.sh
export DENOTE_MD_NOTES_PATH=/path/to/your/notes/folder/
```

## Credits

Props to
[u/varsderk](https://www.reddit.com/r/vim/comments/17vm4i8/re_denote_for_vim_fineill_make_a_crappy_version/)
for introducing me to [denote](https://protesilaos.com/emacs/denote).

`vim-denote-md` was written by [Conan Theobald](https://github.com/shuckster/).

I hope you found it useful! If so, I like [coffee ☕️](https://www.buymeacoffee.com/shuckster) :)
