set viminfo+=!

if !exists('g:BOOKMARKS')
  let g:BOOKMARKS = {}
endif

command! -nargs=1 Bookmark call bookmark#Bookmark(<f-args>)
command! -nargs=1 -complete=custom,bookmark#BookmarkNames DelBookmark call bookmark#DelBookmark(<f-args>)
command! -nargs=1 -complete=custom,bookmark#BookmarkNames GotoBookmark call bookmark#GotoBookmark(<f-args>)
command! CopenBookmarks call bookmark#CopenBookmarks()
