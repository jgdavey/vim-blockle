require 'spec_helper'

describe 'Blockle' do
  include Helpers

  specify 'one-liner brackets to do..end' do
    test_block_toggle <<-END_INITIAL, <<-END_FINAL
      [1, 3].each <{> |elt| puts elt }
    END_INITIAL
      [1, 3].each d<o> |elt|
        puts elt
      end
    END_FINAL
  end

  specify 'do..end to one-liner brackets' do
    test_block_toggle <<-END_INITIAL, <<-END_FINAL
      [1, 3].each <d>o |elt|
        puts elt
      end
    END_INITIAL
      [1, 3].each <{> |elt| puts elt }
    END_FINAL
  end

  specify 'inner nested do..end' do
    test_block_toggle <<-END_INITIAL, <<-END_FINAL
      [[1, 3], [6, 7]].each do |pair|
        pair.each <d>o |elt|
          puts elt
        end
      end
    END_INITIAL
      [[1, 3], [6, 7]].each do |pair|
        pair.each <{> |elt| puts elt }
      end
    END_FINAL
  end

  specify 'outer nested do..end' do
    test_block_toggle <<-END_INITIAL, <<-END_FINAL
      [[1, 3], [6, 7]].each <d>o |pair|
        pair.each do |elt|
          puts elt
        end
      end
    END_INITIAL
      [[1, 3], [6, 7]].each <{> |pair|
        pair.each do |elt|
          puts elt
        end
      }
    END_FINAL
  end

  specify 'inner nested brackets' do
    test_block_toggle <<-END_INITIAL, <<-END_FINAL
      [[1, 3], [6, 7]].each { |pair| pair.each <{> |elt| puts elt } }
    END_INITIAL
      [[1, 3], [6, 7]].each { |pair| pair.each <d>o |elt|
        puts elt
      end }
    END_FINAL
  end

  specify 'outer nested brackets' do
    test_block_toggle <<-END_INITIAL, <<-END_FINAL
      [[1, 3], [6, 7]].each <{> |pair| pair.each { |elt| puts elt } }
    END_INITIAL
      [[1, 3], [6, 7]].each <d>o |pair|
        pair.each { |elt| puts elt }
      end
    END_FINAL
  end
end
