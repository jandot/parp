require 'test/unit'
require 'rubygems'
require 'ruby-processing'

require File.dirname(__FILE__) + '/../lib/sketch.rb'

S = MySketch.new :title => "My Sketch", :width => 800, :height => 600, :data_directory => File.dirname(__FILE__) + '/data'

sleep 3

class ZoomIn < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,2_240_727_404, 1, 644))
    S.slices.push(Slice.new(2_240_727_405, 2_260_727_404, 645, 772))
    S.slices.push(Slice.new(2_260_727_405, GENOME_SIZE, 773, S.circumference))

    S.slices[1].zoom(10)

    sleep 3
  end

  def test_bp_sizes
    assert_equal(2_249_727_404, S.slices[0].length_bp.round)
    assert_equal(2_000_000, S.slices[1].length_bp.round)
    assert_equal(828_860_038, S.slices[2].length_bp.round)
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(2_249_727_404, S.slices[0].stop_cumulative_bp)
    assert_equal(2_249_727_405, S.slices[1].start_cumulative_bp)
    assert_equal(2_251_727_404, S.slices[1].stop_cumulative_bp)
    assert_equal(2_251_727_405, S.slices[2].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[2].stop_cumulative_bp)
  end

  def test_pixel_sizes
    assert_equal(644, S.slices[0].length_pixel.round)
    assert_equal(128, S.slices[1].length_pixel.round)
    assert_equal(234, S.slices[2].length_pixel.round)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(644, S.slices[0].stop_pixel)
    assert_equal(645, S.slices[1].start_pixel)
    assert_equal(772, S.slices[1].stop_pixel)
    assert_equal(773, S.slices[2].start_pixel)
    assert_equal(1006, S.slices[2].stop_pixel)
  end

  def test_resolution
    assert_equal(3_493_366, S.slices[0].resolution.round)
    assert_equal(15_625, S.slices[1].resolution.round)
    assert_equal(3_542_137, S.slices[2].resolution.round) #3542136.91453
  end

  def test_positions_bp_to_pixel
    feature_before_bp = 1_500_000_000
    feature_within_bp = 2_250_000_000
    feature_after_bp = 2_800_000_000
    assert_equal(429, feature_before_bp.cumulative_bp_to_pixel.round)
    assert_equal(661, feature_within_bp.cumulative_bp_to_pixel.round)
    assert_equal(927, feature_after_bp.cumulative_bp_to_pixel.round)
  end

  def test_positions_pixel_to_bp
    feature_before_pixel = 400
    feature_within_pixel = 700
    feature_after_pixel = 900
    assert_equal(1_397_346_214, feature_before_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_250_602_404, feature_within_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_705_120_929, feature_after_pixel.pixel_to_cumulative_bp.round)
  end
end

class ZoomOut < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,2_240_727_404, 1, 644))
    S.slices.push(Slice.new(2_240_727_405, 2_260_727_404, 645, 772))
    S.slices.push(Slice.new(2_260_727_405, GENOME_SIZE, 773, S.circumference))

    S.slices[1].zoom(0.1)

    sleep 3
  end

  def test_bp_sizes
    assert_equal(2_150_727_404, S.slices[0].length_bp.round)
    assert_equal(200_000_000, S.slices[1].length_bp.round)
    assert_equal(729_860_038, S.slices[2].length_bp.round)
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(2_150_727_404, S.slices[0].stop_cumulative_bp)
    assert_equal(2_150_727_405, S.slices[1].start_cumulative_bp)
    assert_equal(2_350_727_404, S.slices[1].stop_cumulative_bp)
    assert_equal(2_350_727_405, S.slices[2].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[2].stop_cumulative_bp)
  end

  def test_pixel_sizes
    assert_equal(644, S.slices[0].length_pixel.round)
    assert_equal(128, S.slices[1].length_pixel.round)
    assert_equal(234, S.slices[2].length_pixel.round)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(644, S.slices[0].stop_pixel)
    assert_equal(645, S.slices[1].start_pixel)
    assert_equal(772, S.slices[1].stop_pixel)
    assert_equal(773, S.slices[2].start_pixel)
    assert_equal(1006, S.slices[2].stop_pixel)
  end

  def test_resolution
    assert_equal(3_339_639, S.slices[0].resolution.round) # 3339638.8261
    assert_equal(1_562_500, S.slices[1].resolution.round) # 1562500
    assert_equal(3_119_060, S.slices[2].resolution.round) # 3119059.9915
  end

  def test_positions_bp_to_pixel
    feature_before_bp = 1_500_000_000
    feature_within_bp = 2_255_000_000
    feature_after_bp = 2_800_000_000
    assert_equal(449, feature_before_bp.cumulative_bp_to_pixel.round)
    assert_equal(711, feature_within_bp.cumulative_bp_to_pixel.round)
    assert_equal(916, feature_after_bp.cumulative_bp_to_pixel.round)
  end

  def test_positions_pixel_to_bp
    feature_before_pixel = 400
    feature_within_pixel = 700
    feature_after_pixel = 900
    assert_equal(1_335_855_530, feature_before_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_238_227_404, feature_within_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_749_967_083, feature_after_pixel.pixel_to_cumulative_bp.round)
  end
end

class PanLeft < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,2_240_727_404, 1, 644))
    S.slices.push(Slice.new(2_240_727_405, 2_260_727_404, 645, 772))
    S.slices.push(Slice.new(2_260_727_405, GENOME_SIZE, 773, S.circumference))

    S.slices[1].pan((S.slices[1].length_pixel.to_f/10).floor, :left) # should be 12 pixels

    sleep 3
  end

  def test_bp_sizes
    assert_equal(2_238_852_404, S.slices[0].length_bp.round)
    assert_equal(20_000_000, S.slices[1].length_bp.round)
    assert_equal(821_735_038, S.slices[2].length_bp.round)
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(2_238_852_404, S.slices[0].stop_cumulative_bp)
    assert_equal(2_238_852_405, S.slices[1].start_cumulative_bp)
    assert_equal(2_258_852_404, S.slices[1].stop_cumulative_bp)
    assert_equal(2_258_852_405, S.slices[2].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[2].stop_cumulative_bp)
  end

  def test_pixel_sizes
    assert_equal(632, S.slices[0].length_pixel.round)
    assert_equal(128, S.slices[1].length_pixel.round)
    assert_equal(246, S.slices[2].length_pixel.round)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(632, S.slices[0].stop_pixel)
    assert_equal(633, S.slices[1].start_pixel)
    assert_equal(760, S.slices[1].stop_pixel)
    assert_equal(761, S.slices[2].start_pixel)
    assert_equal(1006, S.slices[2].stop_pixel)
  end

  def test_resolution
    assert_equal(3_542_488, S.slices[0].resolution.round) # 3542487.9810
    assert_equal(156_250, S.slices[1].resolution.round) # 156250
    assert_equal(3_340_386, S.slices[2].resolution.round) # 3340386.3333
  end

  def test_positions_bp_to_pixel
    feature_before_bp = 1_500_000_000
    feature_within_bp = 2_255_000_000
    feature_after_bp = 2_800_000_000
    assert_equal(423, feature_before_bp.cumulative_bp_to_pixel.round)
    assert_equal(735, feature_within_bp.cumulative_bp_to_pixel.round)
    assert_equal(922, feature_after_bp.cumulative_bp_to_pixel.round)
  end

  def test_positions_pixel_to_bp
    feature_before_pixel = 400
    feature_within_pixel = 700
    feature_after_pixel = 900
    assert_equal(1_416_995_192, feature_before_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_249_477_404, feature_within_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_726_506_491, feature_after_pixel.pixel_to_cumulative_bp.round)
  end
end

class PanRight < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,2_240_727_404, 1, 644))
    S.slices.push(Slice.new(2_240_727_405, 2_260_727_404, 645, 772))
    S.slices.push(Slice.new(2_260_727_405, GENOME_SIZE, 773, S.circumference))

    S.slices[1].pan((S.slices[1].length_pixel.to_f/10).floor, :right) # should be 12 pixels

    sleep 3
  end

  def test_bp_sizes
    assert_equal(2_242_602_404, S.slices[0].length_bp.round)
    assert_equal(20_000_000, S.slices[1].length_bp.round)
    assert_equal(817_985_038, S.slices[2].length_bp.round)
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(2_242_602_404, S.slices[0].stop_cumulative_bp)
    assert_equal(2_242_602_405, S.slices[1].start_cumulative_bp)
    assert_equal(2_262_602_404, S.slices[1].stop_cumulative_bp)
    assert_equal(2_262_602_405, S.slices[2].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[2].stop_cumulative_bp)
  end

  def test_pixel_sizes
    assert_equal(656, S.slices[0].length_pixel.round)
    assert_equal(128, S.slices[1].length_pixel.round)
    assert_equal(222, S.slices[2].length_pixel.round)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(656, S.slices[0].stop_pixel)
    assert_equal(657, S.slices[1].start_pixel)
    assert_equal(784, S.slices[1].stop_pixel)
    assert_equal(785, S.slices[2].start_pixel)
    assert_equal(1006, S.slices[2].stop_pixel)
  end

  def test_resolution
    assert_equal(3_418_601, S.slices[0].resolution.round) # 3418601.2256
    assert_equal(156_250, S.slices[1].resolution.round) # 156250
    assert_equal(3_684_617, S.slices[2].resolution.round) # 3684617.2883
  end

  def test_positions_bp_to_pixel
    feature_before_bp = 1_500_000_000
    feature_within_bp = 2_255_000_000
    feature_after_bp = 2_800_000_000
    assert_equal(439, feature_before_bp.cumulative_bp_to_pixel.round)
    assert_equal(735, feature_within_bp.cumulative_bp_to_pixel.round)
    assert_equal(930, feature_after_bp.cumulative_bp_to_pixel.round)
  end

  def test_positions_pixel_to_bp
    feature_before_pixel = 400
    feature_within_pixel = 700
    feature_after_pixel = 900
    assert_equal(1_367_440_490, feature_before_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_249_477_404, feature_within_pixel.pixel_to_cumulative_bp.round)
    assert_equal(2_690_018_009, feature_after_pixel.pixel_to_cumulative_bp.round)
  end
end