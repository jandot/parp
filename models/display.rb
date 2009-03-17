class Display
  attr_accessor :name
  attr_accessor :origin_x, :origin_y
  attr_accessor :slices, :readpairs
  attr_accessor :bp_length, :scale

  def initialize(name, origin_x, origin_y)
    @name = name
    @origin_x, @origin_y = origin_x, origin_y
    @slices = Array.new
    @bp_length = 0
  end

  def add_slice(slice)
    @slices.push(slice)
    slice.reads.each do |read|
      read.visible[self] = true
    end
  end
  
  def draw(b)
    # First get all readpairs
    @readpairs = Array.new
    @slices.each do |slice|
      readpairs = slice.reads.collect{|r| r.readpair}
      @readpairs.push(readpairs)
    end
    @readpairs.flatten!
    @readpairs.uniq!
    @readpairs.reject!{|rp| !rp.visible(self)}

    # calculate all degrees
    self.calculate_degrees

    # and finally draw
    @slices.each_with_index do |slice, i|
      slice.draw(b, i)
    end

    # Readpairs are drawn independently of slices because they can be inter-slice
    @readpairs.each do |readpair|
      readpair.draw(b, self)
    end
  end

  def calculate_degrees
    @slices.each_with_index do |slice, i|
      slice.calculate_degree(@bp_length, i)
    end
    @readpairs.each do |readpair|
      readpair.reads[0].calculate_degree(@bp_length, self)
      readpair.reads[1].calculate_degree(@bp_length, self)
    end
  end
end