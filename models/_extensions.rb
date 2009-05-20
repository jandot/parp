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