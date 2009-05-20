require 'java'
require '/Users/ja8/sketchbook/normal/code/commons-math-1.2.jar'

class Lens
  class << self
    attr_accessor :sketch
  end
  attr_accessor :n
  attr_accessor :mu, :sigma_squared

  def initialized(mu, sigma_squared)
    @mu, @sigma_squared = mu, sigma_squared
    @n = org.apache.commons.math.distribution.NormalDistributionImpl.new(@mu, @sigma_squared)
  end
end