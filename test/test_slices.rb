require 'test/unit'
require 'rubygems'
require 'ruby-processing'

require File.dirname(__FILE__) + '/../lib/sketch.rb'

S = MySketch.new :title => "My Sketch", :width => 800, :height => 600, :data_directory => File.dirname(__FILE__) + '/data'

sleep 3

class NoZoom < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new)

    @feature_a_bp = 2_250_000_000
    @feature_b_pixel = 735

    sleep 3
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[0].stop_cumulative_bp)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(S.circumference, S.slices[0].stop_pixel)
  end

  def test_bp_sizes
    assert_equal(GENOME_SIZE, S.slices[0].length_bp)
  end

  def test_pixel_sizes
    assert_equal(S.circumference, S.slices[0].length_pixel)
  end

  def test_resolution
    assert_equal(3_062_214, S.slices[0].resolution.round)
  end

  def test_positions
    assert_equal(735, @feature_a_bp.cumulative_bp_to_pixel.round)
    assert_equal(2_250_727_405, @feature_b_pixel.pixel_to_cumulative_bp.round)
  end
end

class HardCodedZoom < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,2_240_727_404, 1, 644))
    S.slices.push(Slice.new(2_240_727_405, 2_260_727_404, 645, 772))
    S.slices.push(Slice.new(2_260_727_405, GENOME_SIZE, 773, S.circumference))
    sleep 3
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(2_240_727_404, S.slices[0].stop_cumulative_bp)
    assert_equal(2_240_727_405, S.slices[1].start_cumulative_bp)
    assert_equal(2_260_727_404, S.slices[1].stop_cumulative_bp)
    assert_equal(2_260_727_405, S.slices[2].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[2].stop_cumulative_bp)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(644, S.slices[0].stop_pixel)
    assert_equal(645, S.slices[1].start_pixel)
    assert_equal(772, S.slices[1].stop_pixel)
    assert_equal(773, S.slices[2].start_pixel)
    assert_equal(1006, S.slices[2].stop_pixel)
  end

  def test_bp_sizes
    assert_equal(2_240_727_404, S.slices[0].length_bp.round)
    assert_equal(20_000_000, S.slices[1].length_bp.round)
    assert_equal(819_860_038, S.slices[2].length_bp.round)
  end

  def test_pixel_sizes
    assert_equal(644, S.slices[0].length_pixel.round)
    assert_equal(128, S.slices[1].length_pixel.round)
    assert_equal(234, S.slices[2].length_pixel.round)
  end

  def test_resolution
    assert_equal(3_479_390, S.slices[0].resolution.round)
    assert_equal(156_250, S.slices[1].resolution.round)
    assert_equal(3_503_675, S.slices[2].resolution.round)
  end
end

#class AutomaticZoom < Test::Unit::TestCase
#  def setup
#    S.slices = [Slice.new]
#    Slice.add(2_250_000_000, 20_000_000)
#    sleep 3
#  end
#
#  def test_bp_boundaries
#    assert_equal(1, S.slices[0].start_cumulative_bp)
#    assert_equal(2_240_727_404, S.slices[0].stop_cumulative_bp)
#    assert_equal(2_240_727_405, S.slices[1].start_cumulative_bp)
#    assert_equal(2_260_727_404, S.slices[1].stop_cumulative_bp)
#    assert_equal(2_260_727_405, S.slices[2].start_cumulative_bp)
#    assert_equal(GENOME_SIZE, S.slices[2].stop_cumulative_bp)
#  end
#
#  def test_pixel_boundaries
#    assert_equal(1, S.slices[0].start_pixel)
#    assert_equal(644, S.slices[0].stop_pixel)
#    assert_equal(645, S.slices[1].start_pixel)
#    assert_equal(772, S.slices[1].stop_pixel)
#    assert_equal(773, S.slices[2].start_pixel)
#    assert_equal(1006, S.slices[2].stop_pixel)
#  end
#
#  def test_bp_sizes
#    assert_equal(2_240_727_404, S.slices[0].length_bp.round)
#    assert_equal(20_000_000, S.slices[1].length_bp.round)
#    assert_equal(819_860_038, S.slices[2].length_bp.round)
#  end
#
#  def test_pixel_sizes
#    assert_equal(644, S.slices[0].length_pixel.round)
#    assert_equal(128, S.slices[1].length_pixel.round)
#    assert_equal(234, S.slices[2].length_pixel.round)
#  end
#
#  def test_resolution
#    assert_equal(3_479_390, S.slices[0].resolution.round)
#    assert_equal(156_250, S.slices[1].resolution.round)
#    assert_equal(3_503_675, S.slices[2].resolution.round)
#  end
#end