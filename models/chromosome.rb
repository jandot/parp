class Chromosome
  attr_accessor :name, :length, :centromere_start, :centromere_stop
  attr_accessor :readpairs

  def initialize(name, length, centr_start, centr_stop)
    @name, @length, @centromere_start, @centromere_stop = name, length, centr_start, centr_stop
  end
end