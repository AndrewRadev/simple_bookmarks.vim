" Add the current [filename, cursor position] in g:BOOKMARKS under the given
" name
function! bookmark#Bookmark(name)
  let file   = expand('%:p')
  let cursor = getpos('.')

  if file != ''
    let g:BOOKMARKS[a:name] = [file, cursor]
  else
    echom "No file"
  endif

  wviminfo
endfunction

" Delete the user-chosen bookmark
function! bookmark#DelBookmark(name)
  if !has_key(g:BOOKMARKS, a:name)
    return
  endif

  call remove(g:BOOKMARKS, a:name)
  wviminfo
endfunction

" Go to the user-chosen bookmark
function! bookmark#GotoBookmark(name)
  if !has_key(g:BOOKMARKS, a:name)
    return
  endif

  let [filename, cursor] = g:BOOKMARKS[a:name]

  exe 'edit '.filename
  call setpos('.', cursor)
endfunction

" Open all bookmarks in the quickfix window
function! bookmark#CopenBookmarks()
  let choices = []

  for [name, place] in items(g:BOOKMARKS)
    let [filename, cursor] = place

    call add(choices, {
          \ 'text':     name,
          \ 'filename': filename,
          \ 'lnum':     cursor[1],
          \ 'col':      cursor[2]
          \ })
  endfor

  call setqflist(choices)
  copen
endfunction

" Completion function for choosing bookmarks
function! bookmark#BookmarkNames(A, L, P)
  return join(sort(keys(g:BOOKMARKS)), "\n")
endfunction
