require 'test/unit'
require 'rubygems'
require 'ruby-processing'

require File.dirname(__FILE__) + '/../lib/sketch.rb'

S = MySketch.new :title => "My Sketch", :width => 800, :height => 600, :data_directory => File.dirname(__FILE__) + '/data'

sleep 3

class PositionUnderMouse < Test::Unit::TestCase
  def test_position_under_mouse
    assert_equal(['1', 1], S.find_position_under_mouse(1))
    assert_equal(['1', 3_062_215], S.find_position_under_mouse(2))
    assert_equal(['1', 27_559_928], S.find_position_under_mouse(10))
    assert_equal(['1', 58_182_069], S.find_position_under_mouse(20))
    assert_equal(['1', 241_914_919], S.find_position_under_mouse(80))
    assert_equal(['1', 244_977_133], S.find_position_under_mouse(81))
    assert_equal(['2', 789_627], S.find_position_under_mouse(82))
  end
end
