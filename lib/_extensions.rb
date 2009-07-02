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

class Fixnum
  class << self
    attr_accessor :sketch
  end

  def format
    return self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end

  def degree_to_pixel
    return self.to_f.degree_to_pixel
  end

  def pixel_to_degree
    return self.to_f.pixel_to_degree
  end

  def pixel_to_cumulative_bp
    return self.to_f.pixel_to_cumulative_bp
  end

  def cumulative_bp_to_pixel
    return self.to_f.cumulative_bp_to_pixel
  end

  def cumulative_bp_to_chr_bp
    return self.to_f.cumulative_bp_to_chr_bp
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

  def pixel_to_cumulative_bp
    slice = self.class.sketch.slices.select{|s| s.start_pixel <= self}[-1]
    return (slice.start_cumulative_bp - 1) + ((self - slice.start_pixel + 1).to_f/slice.resolution)
  end

  def cumulative_bp_to_pixel
    slice = self.class.sketch.slices.select{|s| s.start_cumulative_bp <= self}[-1]
    return (slice.start_pixel - 1) + ((self - slice.start_cumulative_bp + 1)*slice.resolution)
  end

  def cumulative_bp_to_chr_bp
    chr = self.class.sketch.chromosomes.values.select{|c| c.start_cumulative_bp <= self}[-1]
    return [chr, self.round - chr.start_cumulative_bp]
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
