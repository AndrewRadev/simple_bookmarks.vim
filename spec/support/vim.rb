module Support
  module Vim
    def set_file_contents(string)
      write_file(filename, string)
      vim.edit!(filename)
    end

    def create_bookmark
      vim.command "Bookmark #{bookmark_name}"
    end

    def open_bookmark
      vim.command "GotoBookmark #{bookmark_name}"
    end

    def delete_bookmark
      vim.command "DelBookmark #{bookmark_name}"
    end
  end
end
