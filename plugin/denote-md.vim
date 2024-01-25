" denote-md.vim - Companion plugin for denote-md.sh
" Maintainer:   Conan Theobald <https://github.com/shuckster/vim-denote-md>
" Version:      1.0.0

" Define the folder where your scripts are located
let g:denote_shell_script = $DENOTE_MD_SCRIPT_PATH . 'denote.sh'

if filereadable(g:denote_shell_script)
   nnoremap <Leader>dn :call DenoteNewNote()<CR>
   nnoremap <Leader>dt :call DenoteChangeTitle()<CR>
   nnoremap <Leader>dg :call DenoteChangeTags()<CR>
   nnoremap <Leader>dl :call DenotePutNotesListForTags()<CR>
   nnoremap <Leader>da :call DenotePutNoteActionsForTags()<CR>
   nnoremap <Leader>db :call DenotePutNoteBacklinksForBuffer()<CR>
   nnoremap <Leader>df :call DenoteFollowLink()<CR>
endif

function! BuildDenoteCommand(...) abort
   let l:action = a:1
   let l:escapedArgs = map(copy(a:000[1:]), 'shellescape(v:val)')
   let l:args = join(l:escapedArgs, ' ')
   let l:cmd = g:denote_shell_script . ' ' . l:action . ' ' . l:args
   return l:cmd
endfunction

function! DenoteListAvailableTags() abort
   let l:allTags = BuildDenoteCommand('list tags')
   echo "Available tags: " . l:allTags
endfunction

function! DenoteNewNote() abort
   call DenoteListAvailableTags()
   let l:tagsFromUser = input('New note, enter tags: ')
   let l:titleFromUser = input('New note, enter title: ')
   let l:cmd = BuildDenoteCommand('new', l:tagsFromUser, l:titleFromUser)
   let l:noteFile = substitute(system(l:cmd), '\n\+$', '', '')
   if filereadable(l:noteFile)
      execute 'split ' . fnameescape(l:noteFile)
      normal G
      startinsert!
   else
      echo "Error: The new file does not exist: " . l:noteFile
   endif
endfunction

function! DenotePutNotesListForTags() abort
   call DenoteListAvailableTags()
   let l:userTags = input('Enter tags: ')
   let l:cmd = BuildDenoteCommand('list notes', l:userTags)
   let l:noteList = system(l:cmd)
   let l:cursorLine = line('.')
   let l:noteLines = split(l:noteList, '\n')
   call append(l:cursorLine, l:noteLines)
endfunction

function! DenotePutNoteActionsForTags() abort
   call DenoteListAvailableTags()
   let l:userTags = input('Enter tags: ')
   let l:cmd = BuildDenoteCommand('list actions', l:userTags)
   let l:actionList = system(l:cmd)
   let l:cursorLine = line('.')
   let l:actionLines = split(l:actionList, '\n')
   call append(l:cursorLine, l:actionLines)
endfunction

function! IsValidDenoteFilename() abort
   let l:filename = expand('%:t')
   let l:pattern = '^\d\{8\}T\d\{6\}--\zs.*\ze__.*\.md$'
   return l:filename =~ l:pattern
endfunction

function! DenotePutNoteBacklinksForBuffer() abort
   if !IsValidDenoteFilename()
      echo "Invalid filename format."
      return
   endif
   let l:bufFilename = expand('%:p')
   let l:cmd = BuildDenoteCommand('list backlinks', l:bufFilename)
   let l:actionList = system(l:cmd)
   let l:cursorLine = line('.')
   let l:actionLines = split(l:actionList, '\n')
   call append(l:cursorLine, l:actionLines)
endfunction

function! DenoteValueFromFrontMatter(key) abort
   let l:value = ''
   let l:inFrontMatter = 0
   for l:line in getline(1, '$')
      if l:line =~ '^---$'
         let l:inFrontMatter = !l:inFrontMatter
      elseif l:inFrontMatter && l:line =~ '^' . a:key . ': '
         let l:value = matchstr(l:line, a:key . ': \zs.*\ze')
         break
      endif
   endfor
   return l:value
endfunction

function! DenoteReplaceBuffer(newFilename) abort
   if !filereadable(a:newFilename)
      echo "Error: The new file does not exist: " . a:newFilename
      return
   endif
   let l:staleBuf = bufnr('%')
   let l:cursorPos = getpos('.')
   execute 'edit ' . fnameescape(a:newFilename)
   call setpos('.', l:cursorPos)
   if bufwinnr(l:staleBuf) == -1
      execute 'bwipeout! ' . l:staleBuf
   endif
endfunction

function! DenoteChangeTitle() abort
   if !IsValidDenoteFilename()
      echo "Invalid filename format."
      return
   endif
   let l:currentTitle = DenoteValueFromFrontMatter('title')
   let l:currentTitle = matchstr(l:currentTitle, '"\zs.*\ze"')
   let l:newTitle = input('Enter new title: ', l:currentTitle)
   let l:filename = expand('%:p')
   let l:cmd = BuildDenoteCommand('replace title', l:newTitle, l:filename)
   let l:newFilename = substitute(system(l:cmd), '\n\+$', '', '')
   call DenoteReplaceBuffer(l:newFilename)
endfunction

function! DenoteChangeTags() abort
   if !IsValidDenoteFilename()
      echo "Invalid filename format."
      return
   endif
   let l:currentTags = DenoteValueFromFrontMatter('tags')
   let l:currentTags = matchstr(l:currentTags, '\[\zs.*\ze\]')
   let l:currentTags = substitute(l:currentTags, '"', '', 'g')
   let l:currentTags = substitute(l:currentTags, '\s', '', 'g')
   let l:tagsFromUser = input('Enter new tags: ', l:currentTags)
   let l:newTags = join(split(l:tagsFromUser, '\s*,\s*'), ',')
   let l:bufFilename = expand('%:p')
   let l:cmd = BuildDenoteCommand('replace tags', l:newTags, l:bufFilename)
   let l:newFilename = substitute(system(l:cmd), '\n\+$', '', '')
   call DenoteReplaceBuffer(l:newFilename)
endfunction

function! DenoteFileNameFromIdentifier(identifier) abort
   let l:cmd = BuildDenoteCommand('get filename', a:identifier)
   let l:filename = substitute(system(l:cmd), '\n\+$', '', '')
   return l:filename
endfunction

function! DenoteTitleFromFileName(filename) abort
   let l:cmd = BuildDenoteCommand('get title', a:filename)
   let l:title = substitute(system(l:cmd), '\n\+$', '', '')
   return l:title
endfunction

function! DenoteTitleFromIdentifier(identifier) abort
   let l:filename = DenoteFileNameFromIdentifier(a:identifier)
   let l:title = DenoteTitleFromFileName(l:filename)
   return l:title
endfunction

function! FindPatternMatches(pattern, line)
   let l:matches = []
   let l:start_pos = -1
   while match(a:line, a:pattern, l:start_pos + 1) != -1
      let l:match_pos = matchstrpos(a:line, a:pattern, l:start_pos + 1)
      call add(l:matches, {'start': l:match_pos[1], 'end': l:match_pos[2]})
      let l:start_pos = l:match_pos[1]
   endwhile
   return l:matches
endfunction

function! DenoteFollowLink()
   if !IsValidDenoteFilename()
      return
   endif
   let l:pattern = '\[\[denote:\(\d\{8\}T\d\{6\}\)\]\]'
   let l:line = getline('.')
   let l:col = col('.') - 1
   let l:matches = FindPatternMatches(l:pattern, l:line)
   for l:match in l:matches
      if l:col >= l:match['start'] && l:col < l:match['end']
         let l:identifier = matchstr(l:line, '\d\{8\}T\d\{6\}', l:match['start'])
         let l:filename = DenoteFileNameFromIdentifier(l:identifier)
         if l:filename != ''
            execute 'edit ' . l:filename
         endif
         return
      endif
   endfor
endfunction

function! MaybeInspectLine()
   if !IsValidDenoteFilename()
      return
   endif
   let l:pattern = '\[\[denote:\(\d\{8\}T\d\{6\}\)\]\]'
   let l:line = getline('.')
   let l:col = col('.') - 1
   let l:matches = FindPatternMatches(l:pattern, l:line)
   for l:match in l:matches
      if l:col >= l:match['start'] && l:col < l:match['end']
         let l:identifier = matchstr(l:line, '\d\{8\}T\d\{6\}', l:match['start'])
         call InspectLine(l:identifier, line('.'), l:match['start'] + 1)
         return
      endif
   endfor
endfunction

function! InspectLine(identifier, matchLine, matchCol)
   let l:save_cursor = getcurpos()
   call cursor(a:matchLine, a:matchCol)
   let l:info = DenoteTitleFromIdentifier(a:identifier)
   if !has('patch-8.1.2269') || has('nvim')
      echo l:info
      call setpos('.', l:save_cursor)
      return
   endif
   call popup_atcursor(l:info, #{
            \ pos: 'topleft',
            \ line: 'cursor+1',
            \ col: 'cursor',
            \ minwidth: 20,
            \ padding: [0,1,0,1],
            \ border: [0,0,0,0],
            \ })
   call setpos('.', l:save_cursor)
endfunction

" Set up an autocommand to call MaybeInspectLine on CursorHold
augroup HoverInspect
   autocmd!
   autocmd CursorHold * call MaybeInspectLine()
augroup END
