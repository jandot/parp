#class Display
#  class << self
#    attr_accessor :sketch
#  end
#
#  def initialize(name, origin_x, origin_y)
#    @name = name
#    @origin_x, @origin_y = origin_x, origin_y
#  end
#
#  def calculate_degrees
#    self.class.sketch.chromosomes.values.each do |chr|
#      chr.calculate_degrees(self)
#      chr.copy_numbers.each do |copy_number|
#        copy_number.calculate_degrees(self)
#      end
#      chr.segdups.each do |segdup|
#        segdup.calculate_degrees(self)
#      end
#    end
#    self.class.sketch.readpairs.each do |readpair|
#      readpair.reads[0].calculate_degrees(self)
#      readpair.reads[1].calculate_degrees(self)
#    end
#  end
#
##  def draw(b)
##    # First get all readpairs and copy_numbers
##    @readpairs = Array.new
##    @copy_numbers = Array.new
##    @segdups = Array.new
##    @chromosomes.each do |chromosome|
##      readpairs = chromosome.reads.collect{|r| r.readpair}
##      @readpairs.push(readpairs)
##      @copy_numbers.push(chromosome.copy_numbers)
##      @segdups.push(chromosome.segdups)
##    end
###    @slices.each do |slice|
###      readpairs = slice.reads.collect{|r| r.readpair}
###      @readpairs.push(readpairs)
###      @copy_numbers.push(slice.copy_numbers)
###      @segdups.push(slice.segdups)
###    end
##    @readpairs.flatten!
##    @readpairs.uniq!
##    @readpairs.reject!{|rp| !rp.visible(self) or rp.qual < self.class.sketch.controls[:qual_cutoff].value}
##    @copy_numbers.flatten!
##    @segdups.flatten!
##
##    # calculate all degrees
##    self.calculate_degrees
##
##    # and finally draw
##    @chromosomes.each_with_index do |chromosome, i|
##      chromosome.draw(b, self, i)
##    end
###    @slices.each_with_index do |slice, i|
###      slice.draw(b, self, i)
###    end
##
##    # Readpairs are drawn independently of slices because they can be inter-slice
##    @readpairs.each do |readpair|
##      readpair.draw(b, self)
##    end
##  end
#end