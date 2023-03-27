module Support
  module Vim
    def set_file_contents(string)
      write_file(filename, string)
      vim.edit!(filename)
    end

    def create_bookmark
      vim.command "BookmarkAdd #{bookmark_name}"
    end

    def open_bookmark
      vim.command "BookmarkGo #{bookmark_name}"
    end

    def delete_bookmark
      vim.command "BookmarkDel #{bookmark_name}"
    end
  end
end
