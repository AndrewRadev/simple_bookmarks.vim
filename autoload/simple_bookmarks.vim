" Add the current [filename, cursor position] as a bookmark under the given
" name
function! simple_bookmarks#Add(name)
  let file   = expand('%:p')
  let cursor = getpos('.')

  if file != ''
    let g:simple_bookmarks_storage = s:ReadBookmarks()
    let g:simple_bookmarks_storage[a:name] = [file, cursor]
    call s:WriteBookmarks(g:simple_bookmarks_storage)
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

  let g:simple_bookmarks_storage = s:ReadBookmarks()
  call remove(g:simple_bookmarks_storage, a:name)
  call s:WriteBookmarks(g:simple_bookmarks_storage)
endfunction

" Go to the user-chosen bookmark
function! simple_bookmarks#Go(name)
  let g:simple_bookmarks_storage = s:ReadBookmarks()

  if !has_key(g:simple_bookmarks_storage, a:name)
    return
  endif

  let [filename, cursor] = g:simple_bookmarks_storage[a:name]

  exe 'edit '.filename
  call setpos('.', cursor)
endfunction

" Open all bookmarks in the quickfix window
function! simple_bookmarks#Copen()
  let g:simple_bookmarks_storage = s:ReadBookmarks()
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
  let g:simple_bookmarks_storage = s:ReadBookmarks()
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

  return bookmarks
endfunction

function! s:WriteBookmarks(bookmarks)
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
