require 'bsearch'

class String
  def pad(filler, len)
    if self.length < len
      output = self
      (len - self.length).times do
        output = filler + output
      end
      return output
    else
      return self
    end
  end
end

class Integer
  def format
    return self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end
end

class Float
  class << self
    attr_accessor :sketch
  end

  def degree_to_pixel
    return (self*self.class.sketch.radius).to_f/360.to_f
  end

#  # Based on http://www.jasonwaltman.com/thesis/filter-fisheye.html
#  def apply_lenses
#    self.class.sketch.lenses.each do |lens|
#      focus_degree, range_degree = lens.focus, lens.range
#      w = lens.sigma_squared
#
#      if self > (focus_degree - range_degree) and self < (focus_degree + range_degree)
#        s = range_degree/(Math.log(w*range_degree+1))
#        delta_degree = s*Math.log(1+w*(focus_degree - self).abs)
#        new_degree = focus_degree + delta_degree
#        return new_degree
#      end
#    end
#    return self
#  end

  # Based on normal distribution
  def apply_lenses
    value = self
    self.class.sketch.lenses.each do |lens|
      focus_degree, range_degree = lens.focus_degree, lens.range_degree

      if lens.covers?(self)
        delta_degree = self - focus_degree
        input_value = self.class.sketch.map(delta_degree, -range_degree, range_degree, -5, 5)
        delta_degree = lens.n.cumulativeProbability(input_value)
        delta_degree = self.class.sketch.map(delta_degree, lens.min_pos, lens.max_pos, -range_degree, range_degree)
        new_degree = focus_degree + delta_degree
        value = new_degree
      end
    end
    return value
  end

end

class Array
  # This only works on sorted arrays!
  # Returns the index before (default) or after a certain value
  def binary_search(value, side = :before) #only works on sorted arrays!
    if value < self[0]
      return 0
    elsif value > self[-1]
      return self.length
    else
      index = (self.length)/2.floor
      prev_index = 0
      step = index/2
      until (prev_index - index).abs < 2
        prev_index = index
        if value > self[index]
          index += step
        else
          index -= step
        end
        step /= 2
      end

      index = ( side == :before ) ? index : index + 1
      return index
    end
  end
end