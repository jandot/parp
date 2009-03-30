class CopyNumber
  attr_accessor :chr, :start, :stop, :original_value, :value
  attr_accessor :as_string
  attr_accessor :start_degree, :stop_degree
  attr_accessor :slices
  def initialize(chr, start, stop, value)
    @chr = chr
    @start, @stop = start.to_i, stop.to_i
    @original_value = value.to_f
    @value = S.map(@original_value.to_f, 0, 382, 0, 80)
    @as_string = [@chr.pad('0', 2), @start.to_s.pad('0', 9), @stop.to_s.pad('0', 9)].join('_')
    @start_degree = Hash.new
    @stop_degree = Hash.new
    @slices = Hash.new
    S.copy_numbers.push(self)
  end

  def self.fetch_region(start, stop) #start and stop must be in 05_000123456 format
    from_index = CopyNumber.get_index(start)
    to_index = CopyNumber.get_index(stop) - 1
    if to_index >= from_index
      return S.copy_numbers[[0, from_index - 1].max, to_index - from_index + 2]
    else
      return []
    end
  end

  def self.get_index(value)
    return S.copy_numbers.collect{|r| r.as_string}.bsearch_lower_boundary{|x| x <=> value}
  end

  def calculate_degree(display)
    @start_degree[display] = [@slices[display].start_degree[display], S.map(@start, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])].max
    @stop_degree[display] = [@slices[display].stop_degree[display], S.map(@stop, @slices[display].start_bp, @slices[display].stop_bp, @slices[display].start_degree[display], @slices[display].stop_degree[display])].min
  end

  def to_s
    return @as_string
  end
end