require 'vimrunner'
require 'vimrunner/rspec'

Vimrunner::RSpec.configure do |config|
  # Use a single Vim instance for the test suite. Set to false to use an
  # instance per test (slower, but can be easier to manage).
  config.reuse_server = true

  # Decide how to start a Vim instance. In this block, an instance should be
  # spawned and set up with anything project-specific.
  config.start_vim do
    FILE_NAME = 'test.rb'

    vim = Vimrunner.start

    # Or, start a GUI instance:
    # vim = Vimrunner.start_gvim

    # Setup your plugin in the Vim instance
    plugin_path = File.expand_path('../..', __FILE__)
    vim.add_plugin(plugin_path, 'plugin/blockle.vim')
    vim.add_plugin(plugin_path, 'spec/matchit.vim')
    vim.set 'expandtab'
    vim.set 'tabstop', 2
    vim.set 'shiftwidth', 2

    # The returned value is the Client available in the tests.
    vim
  end
end

module Helpers
  def test_block_toggle initial_buffer, expected_final_buffer
    ensure_cursor_presence expected_final_buffer

    actual_final_buffer, command_output = toggle_block initial_buffer

    expect(command_output).to be_empty
    expect(actual_final_buffer).to eq \
      normalize_string_indent(expected_final_buffer)
  end

  def ensure_not_working initial_buffer
    actual_final_buffer, command_output = toggle_block initial_buffer

    expect(command_output).to eq 'Cannot toggle block: cursor is not on {, },'\
      ' do or end'
    expect(actual_final_buffer).to eq normalize_string_indent(initial_buffer)
  end

  private

  def toggle_block initial_buffer
    ensure_cursor_presence initial_buffer
    write_file FILE_NAME, initial_buffer
    vim.edit FILE_NAME
    seek_to_cursor
    command_output = vim.command 'execute "normal \<Plug>BlockToggle"'
    mark_cursor_position
    # Necessary because the client-server API is not really robust, making
    # random tests fail. I guess this sleep lets time to the server to process
    # all the commands before writing.
    sleep 0.1
    vim.write
    actual_final_buffer = IO.read(FILE_NAME).chomp
    [actual_final_buffer, command_output]
  end

  def seek_to_cursor
    # Go to the cursor position.
    vim.search '<.>'
    # Remove the visual cursor.
    vim.normal 'xlxh'
  end

  def mark_cursor_position
    # Here the double quotes are necessary for the escape to be interpreted.
    vim.normal "i<\<esc\>la>"
  end

  def ensure_cursor_presence initial_buffer
    number_cursors = initial_buffer.scan(/<.>/).size
    expect(number_cursors).to eq(1),
      'Error in the test specification: the initial buffer should have exactly'\
      " one cursor defined, but #{number_cursors} were found."
  end
end
