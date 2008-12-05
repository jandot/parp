class Chromosome
  attr_accessor :number, :length, :centromere
  attr_accessor :centr_whole_genome, :centr_rad, :start_whole_genome, :start_rad, :stop_whole_genome, :stop_rad
  
  
  def initialize(nr, length, centromere_start, centromere_stop)
    @number = nr
    @length = length
    @centromere = ( centromere_start + centromere_stop )/2
    @x = MySketch.map(@number, 0, 25, 0, S.width)
    @active = false
  end
  
  def calculate_radians
    if @number == 1
      @start_whole_genome = 0
      @stop_whole_genome = @length
    else
      prev_chr = S.chromosomes[@number - 1]
      @start_whole_genome = prev_chr.stop_whole_genome
      @stop_whole_genome = @start_whole_genome + @length
    end
    
    @centr_whole_genome = @start_whole_genome + @centromere
    centr_degree = (@centr_whole_genome.to_f/GENOME_SIZE)*360
    @centr_rad = MySketch.radians(centr_degree)
    
    start_degree = (@start_whole_genome.to_f/GENOME_SIZE)*360
    stop_degree = (@stop_whole_genome.to_f/GENOME_SIZE)*360
    @start_rad = MySketch.radians(start_degree)
    @stop_rad = MySketch.radians(stop_degree)
  end
  
  def draw_buffer_circular_all
    S.buffer_circular_all.noFill
    S.buffer_circular_all.strokeWeight(5)
    if @number % 2 == 0
      S.buffer_circular_all.stroke(0);
    else
      S.buffer_circular_all.stroke(150);
    end
    S.buffer_circular_all.arc(0,0, DIAMETER, DIAMETER, @start_rad, @stop_rad);
    
    S.buffer_circular_all.fill(0);
    S.buffer_circular_all.strokeWeight(0.5);
    S.buffer_circular_all.text(@number, (RADIUS+15)*MySketch.cos((@start_rad + @stop_rad)/2), (RADIUS+15)*MySketch.sin((@start_rad + @stop_rad)/2));
    
    S.buffer_circular_all.ellipse(RADIUS*MySketch.cos(@centr_rad), RADIUS*MySketch.sin(@centr_rad),10,10);

  end
  
  def covers?(x,y)
    if @x-5 < x and @x + 5 > x and 140 < y and 160 > y
      return true
    else
      return false
    end
  end
end