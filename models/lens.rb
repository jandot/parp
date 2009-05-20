require 'java'
require '/Users/ja8/sketchbook/normal/code/commons-math-1.2.jar'

class Lens
  class << self
    attr_accessor :sketch
  end
  attr_accessor :n
  attr_accessor :mu, :sigma_squared
  attr_accessor :focus, :range

  def initialize(focus, range, mu, sigma_squared)
    @focus, @range, @mu, @sigma_squared = focus, range, mu, sigma_squared
    @n = org.apache.commons.math.distribution.NormalDistributionImpl.new(@mu, @sigma_squared)
  end
end