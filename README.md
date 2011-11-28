The plugin provides several commands to manage named bookmarks. This is
similar to what you'd do with persistent marks, but brings the benefit of
longer, more rememberable names.

Here's an example:

``` vim
:edit ~/.vimrc
:3
:Bookmark here
```

This will store a bookmark called "here" in the file `~/.vim_bookmarks` (changeable through a setting). To jump to the mark, use `:GotoBookmark`

``` vim
:GotoBookmark here
```

This will open the `~/.vimrc` file and jump to the third line. The column is saved as well.

To delete the bookmark, use:

``` vim
:DelBookmark here
```

Both `:GotoBookmark` and `:DelBookmark` are tab-completed with all known bookmarks.

The command `:CopenBookmarks` will load all marks in the quickfix window for easier navigating.

Note that bookmarks should be synchronized between vim instances. Anytime you add a mark in one vim instance, it should be available in all others. In practice, this is achieved by simply reading and writing the whole file on each update. I have yet to experiment to find out if there are any performance issues or race conditions. If you find any issues, please open a bug report in [the bugtracker](https://github.com/AndrewRadev/simple_bookmarks.vim/issues).
