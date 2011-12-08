" Add the current [filename, cursor position] as a bookmark under the given
" name
function! simple_bookmarks#Add(name)
  let file   = expand('%:p')
  let cursor = getpos('.')

  if file != ''
    call s:ReadBookmarks()
    let g:simple_bookmarks_storage[a:name] = [file, cursor]
    call s:WriteBookmarks()
  else
    echom "No file"
  endif

  wviminfo
endfunction

" Delete the user-chosen bookmark
function! simple_bookmarks#Del(name)
  if !has_key(g:simple_bookmarks_storage, a:name)
    return
  endif

  call s:ReadBookmarks()
  call remove(g:simple_bookmarks_storage, a:name)
  call s:WriteBookmarks()
endfunction

" Go to the user-chosen bookmark
function! simple_bookmarks#Go(name)
  call s:ReadBookmarks()

  if !has_key(g:simple_bookmarks_storage, a:name)
    return
  endif

  let [filename, cursor] = g:simple_bookmarks_storage[a:name]

  exe 'edit '.filename
  call setpos('.', cursor)
  silent! normal! zo
endfunction

" Open all bookmarks in the quickfix window
function! simple_bookmarks#Copen()
  call s:ReadBookmarks()
  let choices = []

  for [name, place] in items(g:simple_bookmarks_storage)
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
function! simple_bookmarks#BookmarkNames(A, L, P)
  call s:ReadBookmarks()
  return join(sort(keys(g:simple_bookmarks_storage)), "\n")
endfunction

function! s:ReadBookmarks()
  let bookmarks      = {}
  let bookmarks_file = fnamemodify(g:simple_bookmarks_filename, ':p')

  if !filereadable(bookmarks_file)
    call writefile([], bookmarks_file)
  endif

  for line in readfile(bookmarks_file)
    let [name, file, cursor_description] = split(line, "\t")
    let cursor = split(cursor_description, ':')
    let bookmarks[name] = [file, cursor]
  endfor

  let g:simple_bookmarks_storage = bookmarks
endfunction

function! s:WriteBookmarks()
  let lines          = []
  let bookmarks_file = fnamemodify(g:simple_bookmarks_filename, ':p')

  for [name, place] in items(g:simple_bookmarks_storage)
    let [filename, cursor] = place
    let cursor_description = join(cursor, ':')
    let line               = join([name, filename, cursor_description], "\t")

    call add(lines, line)
  endfor

  call writefile(lines, bookmarks_file)
endfunction
