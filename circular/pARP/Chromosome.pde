class Chromosome {
  int number;
  float len;
  int centr;
  float centr_whole_genome;
  float centr_rad;
  float start_whole_genome;
  float stop_whole_genome;
  float start_rad;
  float stop_rad;
  int[] intrachromosomal_read_pair_ids = new int[0]; //array with IDs of all intrachromosomal read pairs
  Hashtable interchromosomal_read_pair_ids = new Hashtable(); // hash with all interchromosomal read pair (key = other_chr, value = array with read pairs)
  
  Chromosome(int number, int len, int centr_start, int centr_stop) {
    this.number = number;
    this.len = len/1000; // in kb
    this.centr = (centr_start/1000 + centr_stop/1000)/2;
    for ( int i = this.number + 1; i <= 24; i++ ) {
      this.interchromosomal_read_pair_ids.put(i, new int[0]);
    }
  }

  void addReadPair(ReadPair rp) {
    this.intrachromosomal_read_pair_ids = ( int[] ) append(this.intrachromosomal_read_pair_ids, rp.id);
  }
  
  void addReadPair(ReadPair rp, Chromosome other_chr) {
    int[] rp_ids;
    rp_ids = (int[]) this.interchromosomal_read_pair_ids.get(other_chr.number);
    if ( rp_ids == null ) {
      rp_ids = new int[0];
    }
    rp_ids = ( int[] ) append(rp_ids, rp.id);
    this.interchromosomal_read_pair_ids.put(other_chr.number, rp_ids);
  }

  void calculateRadians() {
    if ( this.number == 1 ) {
      this.start_whole_genome = 0;
      this.stop_whole_genome = this.len;
    } else {
      Chromosome prev_chr = (Chromosome) chromosomes.get(this.number - 1);
      this.start_whole_genome = prev_chr.stop_whole_genome;
      this.stop_whole_genome = this.start_whole_genome + this.len;
    }
    
    float centr_whole_genome = this.start_whole_genome + this.centr;
    float centr_degree = ( centr_whole_genome/GENOME_SIZE) * 360;
    this.centr_rad = radians(centr_degree);

    float start_degree = ( start_whole_genome/GENOME_SIZE ) * 360;
    float stop_degree = ( stop_whole_genome/GENOME_SIZE) * 360;
    this.start_rad = radians(start_degree);
    this.stop_rad = radians(stop_degree);
    
  }
  
  void drawBufferCircularAll() {
    buffer_circular_all.noFill();
    buffer_circular_all.strokeWeight(5);
    if ( this.number % 2 == 0 ) {
      buffer_circular_all.stroke(0);
    } else {
      buffer_circular_all.stroke(150);
    }
    buffer_circular_all.arc(0,0, DIAMETER, DIAMETER, this.start_rad, this.stop_rad);
    
    buffer_circular_all.fill(0);
    buffer_circular_all.strokeWeight(0.5);
    buffer_circular_all.text(this.number, (RADIUS+15)*cos((this.start_rad + this.stop_rad)/2), (RADIUS+15)*sin((this.start_rad + this.stop_rad)/2));
    
    chromosome_labels = ( Label[] ) append(chromosome_labels, new Label(int((RADIUS+15)*cos((this.start_rad + this.stop_rad)/2)+WIDTH/4), int((RADIUS+15)*sin((this.start_rad + this.stop_rad)/2) - textAscent() + HEIGHT/4), int(textWidth(str(this.number))), int(textAscent()), this.number));
    
    buffer_circular_all.ellipse(RADIUS*cos(this.centr_rad), RADIUS*sin(this.centr_rad),10,10);
  }
}
