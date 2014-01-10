" Add the current [filename, cursor position, line content] as a bookmark
" under the given name
function! simple_bookmarks#Add(name, ...)
  if a:0 > 0
    " then we have the needed data as the second argument
    let data   = a:1
    let file   = data.file
    let cursor = data.cursor
    let line   = data.line
  else
    " we get it from the current position of the cursor
    let file   = expand('%:p')
    let cursor = getpos('.')
    let line   = substitute(getline('.'), '\v(^\s+)|(\s+$)', '', 'g')
  endif

  if file != ''
    call s:ReadBookmarks()
    let g:simple_bookmarks_storage[a:name] = [file, cursor, line]
    call s:WriteBookmarks()

    if s:QuickfixOpened()
      call simple_bookmarks#Copen()
      wincmd p
    endif
  else
    echom "No file"
  endif
endfunction

" Delete the user-chosen bookmark
function! simple_bookmarks#Del(name)
  call s:ReadBookmarks()

  if !has_key(g:simple_bookmarks_storage, a:name)
    return
  endif
  call remove(g:simple_bookmarks_storage, a:name)

  call s:WriteBookmarks()

  if s:QuickfixOpened()
    call simple_bookmarks#Copen()
    wincmd p
  endif
endfunction

" Go to the user-chosen bookmark
function! simple_bookmarks#Go(name)
  call s:ReadBookmarks()

  if !has_key(g:simple_bookmarks_storage, a:name)
    return
  endif

  let [filename, cursor, _line] = g:simple_bookmarks_storage[a:name]

  exe 'edit '.filename
  call setpos('.', cursor)
  silent! normal! zo
endfunction

" Open all bookmarks in the quickfix window
function! simple_bookmarks#Copen()
  call s:ReadBookmarks()
  let choices = []

  for [name, place] in items(g:simple_bookmarks_storage)
    let [filename, cursor, line] = place

    if g:simple_bookmarks_long_quickfix
      " then place the line on its own below
      call add(choices, {
            \ 'text':     name,
            \ 'filename': filename,
            \ 'lnum':     cursor[1],
            \ 'col':      cursor[2]
            \ })
      call add(choices, {
            \ 'text': line
            \ })
    else
      " place the line next to the bookmark name
      call add(choices, {
            \ 'text':     name.' | '.line,
            \ 'filename': filename,
            \ 'lnum':     cursor[1],
            \ 'col':      cursor[2]
            \ })
    endif
  endfor

  call setqflist(choices)
  copen
  let w:simple_bookmarks_quickfix = 1

  call s:SetupQuickfixMappings()
endfunction

" Completion function for choosing bookmarks
function! simple_bookmarks#BookmarkNames(A, L, P)
  call s:ReadBookmarks()
  return join(sort(keys(g:simple_bookmarks_storage)), "\n")
endfunction

function! simple_bookmarks#Highlight()
  if !(g:simple_bookmarks_highlight || g:simple_bookmarks_signs)
    return
  endif

  call s:ReadBookmarks()

  if g:simple_bookmarks_signs && expand('%:p') != ''
    exe 'sign unplace * file='.expand('%:p')
  endif

  if g:simple_bookmarks_highlight
    exe 'syntax clear SimpleBookmark'
  endif

  for entry in get(g:simple_bookmarks_storage_by_file, expand('%:p'), [])
    let line = entry[1]

    if g:simple_bookmarks_signs
      exe 'sign place '.line.' line='.line.' name=bookmark file='.expand('%:p')
    endif

    if g:simple_bookmarks_highlight
      exe 'syntax match SimpleBookmark /^.*\%'.line.'l.*$/'
    endif
  endfor

  redraw!
endfunction

function! s:ReadBookmarks()
  let bookmarks      = {}
  let files          = {}
  let bookmarks_file = fnamemodify(g:simple_bookmarks_filename, ':p')

  if !filereadable(bookmarks_file)
    call writefile([], bookmarks_file)
  endif

  for line in readfile(bookmarks_file)
    let parts = split(line, "\t")

    let name   = parts[0]
    let file   = parts[1]
    let cursor = split(parts[2], ':')
    let line   = get(parts, 3, '')

    let bookmarks[name] = [file, cursor, line]

    if g:simple_bookmarks_signs || g:simple_bookmarks_highlight
      " then we'll index by filename
      if !has_key(files, file)
        let files[file] = []
      endif

      call add(files[file], cursor)
    endif
  endfor

  let g:simple_bookmarks_storage         = bookmarks
  let g:simple_bookmarks_storage_by_file = files
endfunction

function! s:WriteBookmarks()
  let records        = []
  let bookmarks_file = fnamemodify(g:simple_bookmarks_filename, ':p')

  for [name, place] in items(g:simple_bookmarks_storage)
    let [filename, cursor, line] = place
    let line                     = substitute(line, "\t", ' ', 'g') " avoid possible delimiter problems
    let cursor_description       = join(cursor, ':')
    let record                   = join([name, filename, cursor_description, line], "\t")

    call add(records, record)
  endfor

  call writefile(records, bookmarks_file)

  if g:simple_bookmarks_signs || g:simple_bookmarks_highlight
    call simple_bookmarks#Highlight()
  endif
endfunction

function! s:SetupQuickfixMappings()
  if g:simple_bookmarks_no_qf_mappings
    return
  endif

  let cr_mapping = '<cr>'

  if g:simple_bookmarks_auto_close
    let cr_mapping = cr_mapping.':cclose<cr>'
  endif

  if g:simple_bookmarks_new_tab
    let cr_mapping = '<c-w>'.cr_mapping.':tabedit %<cr>gT:quit<cr>gt'
  endif

  if cr_mapping != '<cr>'
    exe 'nnoremap <silent> <buffer> <cr> '.cr_mapping
  endif

  nnoremap <buffer> dd :call <SID>DeleteQuickfixBookmark()<cr>
  nnoremap <buffer> u :call <SID>UndoDeleteQuickfixBookmark()<cr>
endfunction

function! s:DeleteQuickfixBookmark()
  let saved_cursor = getpos('.')
  let index        = line('.') - 1
  let qflist       = getqflist()

  if index >= len(qflist)
    " somehow, the index isn't right
    echo
    return
  end

  let bookmark_data = qflist[index]

  if bookmark_data.bufnr == 0
    " it's not a real bookmark
    echo
    return
  end

  if g:simple_bookmarks_long_quickfix
    let name = bookmark_data.text
  else
    let name = matchstr(bookmark_data.text, '.\{-}\ze | ')
  endif

  let bookmark = g:simple_bookmarks_storage[name]

  call insert(g:simple_bookmarks_deletion_stack, {
        \ 'name':   name,
        \ 'file':   bookmark[0],
        \ 'cursor': bookmark[1],
        \ 'line':   bookmark[2]
        \ })
  call simple_bookmarks#Del(name)
  CopenBookmarks

  call setpos('.', saved_cursor)
  echo "Deleted bookmark: ".name
endfunction

function! s:UndoDeleteQuickfixBookmark()
  let saved_cursor = getpos('.')

  if empty(g:simple_bookmarks_deletion_stack)
    echo
    return
  endif

  let bookmark_data = remove(g:simple_bookmarks_deletion_stack, 0)
  call simple_bookmarks#Add(bookmark_data.name, bookmark_data)
  CopenBookmarks
  echo

  call setpos('.', saved_cursor)
endfunction

function! s:QuickfixOpened()
  for winnr in range(1, winnr('$'))
    if getwinvar(winnr, 'simple_bookmarks_quickfix')
      return 1
    end
  endfor

  return 0
endfunction
