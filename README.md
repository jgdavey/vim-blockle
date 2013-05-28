#  vim-blockle

This plugin allows rapid toggling between the two different styles of ruby
blocks, namely do/end and brackets {}. To use, simply move the cursor to the
beginning or end of a block, and type <Leader>b. As a mnemonic, remember 'b'
for 'block'.

Note: This plugin works best if you have your cursor on a do, end, {, or }. An
attempt is made for it to work if you are inside a block as well, in which
case the most immediate parent will be toggled.

When moving from a do/end to a bracket-style block, the plugin will attempt to
move to a one-liner if appropriate.

For example, if you have the following ruby code (* indicates cursor position):

    ['one', 'two'].each d*o |number|
      puts number + "!"
    end

After invoking <Leader>b, the resulting code would be:

    ['one', 'two'].each *{ |number| puts number + "!" }

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/jgdavey/vim-blockle.git

Once help tags have been generated, you can view the manual with
`:help blockle`.

This plugin is only available if 'compatible' is not set, and will only work
correctly if matchit.vim is available.

## License

Copyright (c) Joshua Davey.  Distributed under the same terms as Vim itself.
See `:help license`.
