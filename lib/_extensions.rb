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

  def format(decimals = 0)
    return printf("%.2f", self)
  end

  def degree_to_pixel
    return (self*self.class.sketch.circumference).to_f/360.to_f
  end

  def pixel_to_degree
    return (self*360).to_f/self.class.sketch.circumference.to_f
  end

  def bp_to_pixel
    slice = self.class.sketch.slices.select{|s| s.range_overall_bp.include?(self)}[0]
    return slice.start_pixel + (self - slice.start_overall_bp).to_f/slice.resolution
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
