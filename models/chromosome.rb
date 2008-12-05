class Chromosome
  attr_accessor :number, :length, :centromere, :active, :x
  
  def initialize(nr, length, centromere_start, centromere_stop)
    @number = nr
    @length = length
    @centromere = ( centromere_start + centromere_stop )/2
    @x = MySketch.map(@number, 0, 25, 0, S.width)
    @active = false
  end
  
  def draw
    if @active
      S.buffer.fill(0,0,255)
    else
      S.buffer.fill(255,255,0)
    end

    S.buffer.ellipse(@x,150,10,10)

  end
  
  def covers?(x,y)
    if @x-5 < x and @x + 5 > x and 140 < y and 160 > y
      return true
    else
      return false
    end
  end
end