# vim-denote-md

Companion plugin for [denote-md.sh](https://github.com/shuckster/denote-md).

```vim
" Define where your denote-md script is located
let g:denote_md_script = $DENOTE_MD_SCRIPT_PATH . 'denote-md.sh'

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

## Credit

Props to
[u/varsderk](https://www.reddit.com/r/vim/comments/17vm4i8/re_denote_for_vim_fineill_make_a_crappy_version/)
for introducing me to [denote](https://protesilaos.com/emacs/denote).
