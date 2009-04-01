class Display
  class << self
    attr_accessor :sketch
  end
  attr_accessor :name
  attr_accessor :origin_x, :origin_y
  attr_accessor :slices, :readpairs
  attr_accessor :length_bp, :scale

  def initialize(name, origin_x, origin_y)
    @name = name
    @origin_x, @origin_y = origin_x, origin_y
    @slices = Array.new
    @length_bp = 0
  end

  def add_slice(slice)
    @slices.push(slice)
    slice.reads.each do |read|
      read.visible[self] = true
    end
  end
  
  def draw(b, dependent = true)
    # First get all readpairs and copy_numbers
    @readpairs = Array.new
    @copy_numbers = Array.new
    @segdups = Array.new
    @length_bp = 0
    @slices.each do |slice|
      @length_bp += slice.length_bp
      readpairs = slice.reads.collect{|r| r.readpair}
      @readpairs.push(readpairs)
      @copy_numbers.push(slice.copy_numbers)
      @segdups.push(slice.segdups)
    end
    @readpairs.flatten!
    @readpairs.uniq!
    @readpairs.reject!{|rp| !rp.visible(self) or rp.qual < self.class.sketch.qual_cutoff}
    @copy_numbers.flatten!
    @segdups.flatten!

    # calculate all degrees
    self.calculate_degrees(dependent)

    # and finally draw
    @slices.each_with_index do |slice, i|
      slice.draw(b, self, i)
    end

    # Readpairs are drawn independently of slices because they can be inter-slice
    @readpairs.each do |readpair|
      readpair.draw(b, self)
    end
  end

  def calculate_degrees(dependent = true)
    # Caution: this resets the zoomlevel of all slices to be the same
    @slices.each_with_index do |slice, i|
      slice.calculate_degree(self, i, dependent)
    end
    @readpairs.each do |readpair|
      readpair.reads[0].calculate_degree(self)
      readpair.reads[1].calculate_degree(self)
    end
    @copy_numbers.each do |copy_number|
      copy_number.calculate_degree(self)
    end
    @segdups.each do |segdup|
      segdup.calculate_degree(self)
    end
  end
end