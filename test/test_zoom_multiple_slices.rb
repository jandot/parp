require 'test/unit'
require 'rubygems'
require 'ruby-processing'

require File.dirname(__FILE__) + '/../lib/sketch.rb'

S = MySketch.new :title => "My Sketch", :width => 800, :height => 600, :data_directory => File.dirname(__FILE__) + '/data'

sleep 3

# When zooming slices that are adjacent to the zoomed slice should not be affected
class ZoomIn < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,440_083_920, 1, 150))
    S.slices.push(Slice.new(440_083_921, 880_167_840, 151, 170))
    S.slices.push(Slice.new(880_167_841, 1_320_251_760, 171, 300))
    S.slices.push(Slice.new(1_320_251_761, 1_760_335_680, 301, 550))
    S.slices.push(Slice.new(1_760_335_681, 2_200_419_600, 551, 650)) # <- we'll play with this one
    S.slices.push(Slice.new(2_200_419_601, 2_640_503_520, 651, 800))
    S.slices.push(Slice.new(2_640_503_521, GENOME_SIZE, 801, S.circumference))

    S.slices[4].zoom(10)

    sleep 3
  end

  def test_bp_sizes
    assert_equal(440_083_920, S.slices[0].length_bp.round)
    assert_equal(440_083_920, S.slices[1].length_bp.round)
    assert_equal(440_083_920, S.slices[2].length_bp.round)
    assert_equal(638_121_684, S.slices[3].length_bp.round)
    assert_equal(44_008_392, S.slices[4].length_bp.round)
    assert_equal(638_121_684, S.slices[5].length_bp.round)
    assert_equal(440_083_922, S.slices[6].length_bp.round)
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(440_083_920, S.slices[0].stop_cumulative_bp)
    assert_equal(440_083_921, S.slices[1].start_cumulative_bp)
    assert_equal(880_167_840, S.slices[1].stop_cumulative_bp)
    assert_equal(880_167_841, S.slices[2].start_cumulative_bp)
    assert_equal(1_320_251_760, S.slices[2].stop_cumulative_bp)
    assert_equal(1_320_251_761, S.slices[3].start_cumulative_bp)
    assert_equal(1_958_373_444, S.slices[3].stop_cumulative_bp)
    assert_equal(1_958_373_445, S.slices[4].start_cumulative_bp)
    assert_equal(2_002_381_836, S.slices[4].stop_cumulative_bp)
    assert_equal(2_002_381_837, S.slices[5].start_cumulative_bp)
    assert_equal(2_640_503_520, S.slices[5].stop_cumulative_bp)
    assert_equal(2_640_503_521, S.slices[6].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[6].stop_cumulative_bp)
  end

  def test_pixel_sizes
    assert_equal(150, S.slices[0].length_pixel.round)
    assert_equal(20, S.slices[1].length_pixel.round)
    assert_equal(130, S.slices[2].length_pixel.round)
    assert_equal(250, S.slices[3].length_pixel.round)
    assert_equal(100, S.slices[4].length_pixel.round)
    assert_equal(150, S.slices[5].length_pixel.round)
    assert_equal(206, S.slices[6].length_pixel.round)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(150, S.slices[0].stop_pixel)
    assert_equal(151, S.slices[1].start_pixel)
    assert_equal(170, S.slices[1].stop_pixel)
    assert_equal(171, S.slices[2].start_pixel)
    assert_equal(300, S.slices[2].stop_pixel)
    assert_equal(301, S.slices[3].start_pixel)
    assert_equal(550, S.slices[3].stop_pixel)
    assert_equal(551, S.slices[4].start_pixel)
    assert_equal(650, S.slices[4].stop_pixel)
    assert_equal(651, S.slices[5].start_pixel)
    assert_equal(800, S.slices[5].stop_pixel)
    assert_equal(801, S.slices[6].start_pixel)
    assert_equal(1006, S.slices[6].stop_pixel)
  end

  def test_resolution
    assert_equal(2_933_893, S.slices[0].resolution.round) # 2933892.8000
    assert_equal(22_004_196, S.slices[1].resolution.round)
    assert_equal(3_385_261, S.slices[2].resolution.round) # 3385260.9231
    assert_equal(2_552_487, S.slices[3].resolution.round) # 2552486.7360
    assert_equal(440_084, S.slices[4].resolution.round) # 440083.920
    assert_equal(4_254_145, S.slices[5].resolution.round) # 4254144.5600
    assert_equal(2_136_330, S.slices[6].resolution.round) # 2136329.7185
  end

  def test_positions_bp_to_pixel
    feature_slice_0 = 5_000_000
    feature_slice_1 = 500_000_000
    feature_slice_2 = 1_000_000_000
    feature_slice_3 = 1_500_000_000
    feature_slice_4 = 2_000_000_000
    feature_slice_5 = 2_500_000_000
    feature_slice_6 = 2_800_000_000
    assert_equal(2, feature_slice_0.cumulative_bp_to_pixel.round)
    assert_equal(153, feature_slice_1.cumulative_bp_to_pixel.round)
    assert_equal(205, feature_slice_2.cumulative_bp_to_pixel.round)
    assert_equal(370, feature_slice_3.cumulative_bp_to_pixel.round)
    assert_equal(645, feature_slice_4.cumulative_bp_to_pixel.round)
    assert_equal(767, feature_slice_5.cumulative_bp_to_pixel.round)
    assert_equal(875, feature_slice_6.cumulative_bp_to_pixel.round)
  end

  def test_positions_pixel_to_bp
    feature_slice_0 = 100
    feature_slice_1 = 160
    feature_slice_2 = 200
    feature_slice_3 = 400
    feature_slice_4 = 600
    feature_slice_5 = 700
    feature_slice_6 = 900
    assert_equal(293_389_280, feature_slice_0.pixel_to_cumulative_bp.round)
    assert_equal(660_125_880, feature_slice_1.pixel_to_cumulative_bp.round)
    assert_equal(981_725_668, feature_slice_2.pixel_to_cumulative_bp.round)
    assert_equal(1_575_500_434, feature_slice_3.pixel_to_cumulative_bp.round)
    assert_equal(1_980_377_640, feature_slice_4.pixel_to_cumulative_bp.round)
    assert_equal(2_215_089_064, feature_slice_5.pixel_to_cumulative_bp.round)
    assert_equal(2_854_136_492, feature_slice_6.pixel_to_cumulative_bp.round)
  end
end

class PanLeft < Test::Unit::TestCase
  def setup
    S.slices = Array.new
    S.slices.push(Slice.new(1,440_083_920, 1, 150))
    S.slices.push(Slice.new(440_083_921, 880_167_840, 151, 170))
    S.slices.push(Slice.new(880_167_841, 1_320_251_760, 171, 300))
    S.slices.push(Slice.new(1_320_251_761, 1_760_335_680, 301, 550))
    S.slices.push(Slice.new(1_760_335_681, 2_200_419_600, 551, 650)) # <- we'll play with this one
    S.slices.push(Slice.new(2_200_419_601, 2_640_503_520, 651, 800))
    S.slices.push(Slice.new(2_640_503_521, GENOME_SIZE, 801, S.circumference))

    S.slices[4].pan((S.slices[4].length_pixel.to_f/10).floor, :left) # should be 10 pixels

    sleep 3
  end

  def test_bp_sizes
    assert_equal(440_083_920, S.slices[0].length_bp.round)
    assert_equal(440_083_920, S.slices[1].length_bp.round)
    assert_equal(440_083_920, S.slices[2].length_bp.round)
    assert_equal(396_075_528, S.slices[3].length_bp.round)
    assert_equal(440_083_920, S.slices[4].length_bp.round)
    assert_equal(484_092_312, S.slices[5].length_bp.round)
    assert_equal(440_083_922, S.slices[6].length_bp.round)
  end

  def test_bp_boundaries
    assert_equal(1, S.slices[0].start_cumulative_bp)
    assert_equal(440_083_920, S.slices[0].stop_cumulative_bp)
    assert_equal(440_083_921, S.slices[1].start_cumulative_bp)
    assert_equal(880_167_840, S.slices[1].stop_cumulative_bp)
    assert_equal(880_167_841, S.slices[2].start_cumulative_bp)
    assert_equal(1_320_251_760, S.slices[2].stop_cumulative_bp)
    assert_equal(1_320_251_761, S.slices[3].start_cumulative_bp)
    assert_equal(1_716_327_288, S.slices[3].stop_cumulative_bp)
    assert_equal(1_716_327_289, S.slices[4].start_cumulative_bp)
    assert_equal(2_156_411_208, S.slices[4].stop_cumulative_bp)
    assert_equal(2_156_411_209, S.slices[5].start_cumulative_bp)
    assert_equal(2_640_503_520, S.slices[5].stop_cumulative_bp)
    assert_equal(2_640_503_521, S.slices[6].start_cumulative_bp)
    assert_equal(GENOME_SIZE, S.slices[6].stop_cumulative_bp)
  end

  def test_pixel_sizes
    assert_equal(150, S.slices[0].length_pixel.round)
    assert_equal(20, S.slices[1].length_pixel.round)
    assert_equal(130, S.slices[2].length_pixel.round)
    assert_equal(240, S.slices[3].length_pixel.round)
    assert_equal(100, S.slices[4].length_pixel.round)
    assert_equal(160, S.slices[5].length_pixel.round)
    assert_equal(206, S.slices[6].length_pixel.round)
  end

  def test_pixel_boundaries
    assert_equal(1, S.slices[0].start_pixel)
    assert_equal(150, S.slices[0].stop_pixel)
    assert_equal(151, S.slices[1].start_pixel)
    assert_equal(170, S.slices[1].stop_pixel)
    assert_equal(171, S.slices[2].start_pixel)
    assert_equal(300, S.slices[2].stop_pixel)
    assert_equal(301, S.slices[3].start_pixel)
    assert_equal(540, S.slices[3].stop_pixel)
    assert_equal(541, S.slices[4].start_pixel)
    assert_equal(640, S.slices[4].stop_pixel)
    assert_equal(641, S.slices[5].start_pixel)
    assert_equal(800, S.slices[5].stop_pixel)
    assert_equal(801, S.slices[6].start_pixel)
    assert_equal(1006, S.slices[6].stop_pixel)
  end

  def test_resolution
    assert_equal(2_933_893, S.slices[0].resolution.round) # 2933892.8000
    assert_equal(22_004_196, S.slices[1].resolution.round)
    assert_equal(3_385_261, S.slices[2].resolution.round) # 3385260.9231
    assert_equal(1_650_315, S.slices[3].resolution.round) # 1650314.7
    assert_equal(4_400_839, S.slices[4].resolution.round) # 4400839.2
    assert_equal(3_025_577, S.slices[5].resolution.round) # 3025576.95
    assert_equal(2_136_330, S.slices[6].resolution.round) # 2136329.7185
  end

  def test_positions_bp_to_pixel
    feature_slice_0 = 5_000_000
    feature_slice_1 = 500_000_000
    feature_slice_2 = 1_000_000_000
    feature_slice_3 = 1_500_000_000
    feature_slice_4 = 1_800_000_000
    feature_slice_5 = 2_200_000_000
    feature_slice_6 = 2_800_000_000
    assert_equal(2, feature_slice_0.cumulative_bp_to_pixel.round)
    assert_equal(153, feature_slice_1.cumulative_bp_to_pixel.round)
    assert_equal(205, feature_slice_2.cumulative_bp_to_pixel.round)
    assert_equal(409, feature_slice_3.cumulative_bp_to_pixel.round)
    assert_equal(559, feature_slice_4.cumulative_bp_to_pixel.round)
    assert_equal(654, feature_slice_5.cumulative_bp_to_pixel.round)
    assert_equal(875, feature_slice_6.cumulative_bp_to_pixel.round)
  end

  def test_positions_pixel_to_bp
    feature_slice_0 = 100
    feature_slice_1 = 160
    feature_slice_2 = 200
    feature_slice_3 = 400
    feature_slice_4 = 600
    feature_slice_5 = 700
    feature_slice_6 = 900
    assert_equal(293_389_280, feature_slice_0.pixel_to_cumulative_bp.round)
    assert_equal(660_125_880, feature_slice_1.pixel_to_cumulative_bp.round)
    assert_equal(981_725_668, feature_slice_2.pixel_to_cumulative_bp.round)
    assert_equal(1_485_283_230, feature_slice_3.pixel_to_cumulative_bp.round)
    assert_equal(1_980_377_640, feature_slice_4.pixel_to_cumulative_bp.round)
    assert_equal(2_337_945_825, feature_slice_5.pixel_to_cumulative_bp.round)
    assert_equal(2_854_136_492, feature_slice_6.pixel_to_cumulative_bp.round)
  end
end
