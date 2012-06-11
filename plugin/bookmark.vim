if exists('g:loaded_simple_bookmarks') || &cp
  finish
endif

let g:loaded_simple_bookmarks = '0.0.1' " version number
let s:keepcpo                 = &cpo
set cpo&vim

if !exists('g:simple_bookmarks_storage')
  let g:simple_bookmarks_storage = {}
endif

if !exists('g:simple_bookmarks_storage_by_file')
  let g:simple_bookmarks_storage_by_file = {}
endif

if !exists('g:simple_bookmarks_filename')
  let g:simple_bookmarks_filename = '~/.vim_bookmarks'
endif

if !exists('g:simple_bookmarks_signs')
  let g:simple_bookmarks_signs = 0
endif

command! -nargs=1 Bookmark call simple_bookmarks#Add(<f-args>)
command! -nargs=1 -complete=custom,simple_bookmarks#BookmarkNames DelBookmark call simple_bookmarks#Del(<f-args>)
command! -nargs=1 -complete=custom,simple_bookmarks#BookmarkNames GotoBookmark call simple_bookmarks#Go(<f-args>)
command! CopenBookmarks call simple_bookmarks#Copen()

if g:simple_bookmarks_signs
  sign define bookmark text=-> texthl=Search
  autocmd BufEnter * call simple_bookmarks#ShowSigns()
endif
