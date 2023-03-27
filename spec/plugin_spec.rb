require 'spec_helper'

describe "simple_bookmarks" do
  let(:filename) { 'test.rb' }
  let(:contents) { ['line 1', 'line 2', 'line 3'] }
  let(:bookmark_name) { 'simple_bookmarks_spec' }

  before do
    set_file_contents contents.join("\n")
  end

  after do
    delete_bookmark
  end

  describe "BookmarkAdd" do
    it "creates a bookmark at the current line" do
      vim.command '2'
      create_bookmark

      vim.edit!('tmp.rb')
      open_bookmark

      expect(vim.echo('getline(".")')).to eq contents[1]
      expect(vim.echo('expand("%")')).to eq filename
    end
  end

  describe "BookmarkDel" do
    it "deletes a previously created bookmark" do
      vim.command '2'
      create_bookmark

      vim.command '1'
      delete_bookmark

      open_bookmark
      expect(vim.echo('getline(".")')).to eq contents[0]
    end
  end
end
