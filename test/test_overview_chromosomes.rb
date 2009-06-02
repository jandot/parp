require 'test/unit'
require 'rubygems'
require 'ruby-processing'

require File.dirname(__FILE__) + '/../lib/sketch.rb'

S = MySketch.new :title => "My Sketch", :width => 800, :height => 600, :data_directory => File.dirname(__FILE__) + '/data'

sleep 3
STDERR.puts '---------------------------'

class ChromosomeBoundaries < Test::Unit::TestCase
  def test_count
    assert_equal(24, S.chromosomes.length)
  end
  
  def test_offsets
    assert_equal(0, S.chromosomes['1'].offset_bp)
    assert_equal(247249719, S.chromosomes['2'].offset_bp)
    assert_equal(490200868, S.chromosomes['3'].offset_bp)
  end

  def test_pixels
    assert_equal(80, S.chromosomes['1'].stop_pixel.floor)
    assert_equal(346, S.chromosomes['5'].stop_pixel.floor)
  end
end
