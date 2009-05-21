require 'java'
require '/Users/ja8/sketchbook/normal/code/commons-math-1.2.jar'

class Lens
  class << self
    attr_accessor :sketch
    attr_accessor :transformation_matrix
    attr_accessor :matrix_size
  end
  attr_accessor :n
  attr_accessor :mu, :sigma_squared
  attr_accessor :focus_degree, :range_degree
  attr_accessor :focus_pixel, :range_pixel
  attr_accessor :min_pos, :max_pos

  def initialize(focus, range, mu, sigma_squared)
    @focus_degree, @range_degree, @mu, @sigma_squared = focus, range, mu, sigma_squared
#    @focus_pixel = @focus_degree.to_f.degree_to_pixel
#    @range_pixel = @range_degree.to_f.degree_to_pixel
    @n = org.apache.commons.math.distribution.NormalDistributionImpl.new(@mu, @sigma_squared)
    @min_pos = @n.cumulativeProbability(-5)
    @max_pos = @n.cumulativeProbability(5)
#    self.adjust_matrix
  end

  def update(focus, factor = 10)
    @focus_degree = focus
    @sigma_squared /= factor
    @n = org.apache.commons.math.distribution.NormalDistributionImpl.new(@mu, @sigma_squared)
    @min_pos = @n.cumulativeProbability(-5)
    @max_pos = @n.cumulativeProbability(5)
  end

  def self.initialize_matrix
    self.transformation_matrix = Hash.new
    (self.sketch.radius*2*3.141592).ceil.times do |pixel|
      self.transformation_matrix[pixel] = pixel
    end
    self.matrix_size = (self.sketch.radius*2*3.141592).ceil
    STDERR.puts "DEBUG: " + self.matrix_size.to_s
  end

  # This draws a line around the display showing which parts are zoomed in
  def self.draw(buffer)
    buffer.fill 0
    buffer.no_stroke
    (360*4).times do |point|
      degree = point.to_f/4
      value = self.sketch.radius + 30 + (degree - degree.to_f.apply_lenses)
      buffer.ellipse(self.sketch.cx(degree, value), self.sketch.cy(degree, value), 1, 1)
    end
  end

  def to_s
    return [@focus_degree, @range_degree, @mu, @sigma_squared].join("\t")
  end

#  def adjust_matrix
#    (self.class.sketch.radius*2*3.141592).ceil.times do |pixel|
#      if self.covers?(pixel)
#        delta_degree = pixel - @focus_pixel
#        input_value = self.class.sketch.map(delta_degree, -@range_pixel, @range_pixel, -5, 5)
#        delta_degree = @n.cumulativeProbability(input_value)
#        delta_degree = self.class.sketch.map(delta_degree, @min_pos, @max_pos, -@range_pixel, @range_pixel)
#        self.class.transformation_matrix[pixel] += delta_degree
#      end
#    end
#  end

#  def self.calculate_matrix_from_scratch
#    (self.sketch.radius*2*3.141592).ceil.times do |pixel|
#      delta_degree = 0
#      self.class.sketch.lenses.each do |lens|
#        focus_degree, range_degree = lens.focus, lens.range
#
#        if lens.covers?(self)
#          delta_degree = self - focus_degree
#          input_value = self.class.sketch.map(delta_degree, -range_degree, range_degree, -5, 5)
#          delta_degree = lens.n.cumulativeProbability(input_value)
#          delta_degree = self.class.sketch.map(delta_degree, lens.min_pos, lens.max_pos, -range_degree, range_degree)
#          new_degree = focus_degree + delta_degree
#          new_pixel = new_degree
#        end
#      end
#      self.transformation_matrix[pixel] = new_pixel
#    end
#  end

  def covers?(pos)
    pos > (@focus_degree - @range_degree) and pos < (@focus_degree + @range_degree)
  end

end