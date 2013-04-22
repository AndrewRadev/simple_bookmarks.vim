if exists('g:loaded_simple_bookmarks') || &cp
  finish
endif

let g:loaded_simple_bookmarks = '0.0.2' " version number
let s:keepcpo                 = &cpo
set cpo&vim

let g:simple_bookmarks_deletion_stack = []

if !exists('g:simple_bookmarks_storage')
  let g:simple_bookmarks_storage = {}
endif

if !exists('g:simple_bookmarks_storage_by_file')
  let g:simple_bookmarks_storage_by_file = {}
endif

if !exists('g:simple_bookmarks_filename')
  let g:simple_bookmarks_filename = '~/.vim_bookmarks'
endif

if !exists('g:simple_bookmarks_long_quickfix')
  let g:simple_bookmarks_long_quickfix = 0
endif

if !exists('g:simple_bookmarks_signs')
  let g:simple_bookmarks_signs = 0
endif

if !exists('g:simple_bookmarks_highlight')
  let g:simple_bookmarks_highlight = 0
endif

if !exists('g:simple_bookmarks_new_tab')
  let g:simple_bookmarks_new_tab = 0
endif

if !exists('g:simple_bookmarks_auto_close')
  let g:simple_bookmarks_auto_close = 1
endif

if !exists('g:simple_bookmarks_no_qf_mappings')
  let g:simple_bookmarks_no_qf_mappings = 0
endif

command! -nargs=1 Bookmark call simple_bookmarks#Add(<f-args>)
command! -nargs=1 -complete=custom,simple_bookmarks#BookmarkNames DelBookmark call simple_bookmarks#Del(<f-args>)
command! -nargs=1 -complete=custom,simple_bookmarks#BookmarkNames GotoBookmark call simple_bookmarks#Go(<f-args>)
command! CopenBookmarks call simple_bookmarks#Copen()

hi link SimpleBookmark Search

if g:simple_bookmarks_signs || g:simple_bookmarks_highlight
  sign define bookmark text=->
  autocmd BufRead * call simple_bookmarks#Highlight()
endif

let &cpo = s:keepcpo
unlet s:keepcpo
