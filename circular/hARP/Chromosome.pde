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
  
  Chromosome(int number, int len, int centr_start, int centr_stop) {
    this.number = number;
    this.len = len/1000; // in kb
    this.centr = (centr_start/1000 + centr_stop/1000)/2;
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
  
  void draw() {
    buffer.noFill();
    buffer.strokeWeight(5);
    if ( this.number % 2 == 0 ) {
      buffer.stroke(0);
    } else {
      buffer.stroke(150);
    }
    buffer.arc(0,0, DIAMETER, DIAMETER, this.start_rad, this.stop_rad);
    
    buffer.fill(0);
    buffer.strokeWeight(0.5);
    buffer.text(this.number, (RADIUS+15)*cos((this.start_rad + this.stop_rad)/2), (RADIUS+15)*sin((this.start_rad + this.stop_rad)/2));
    
    buffer.ellipse(RADIUS*cos(this.centr_rad), RADIUS*sin(this.centr_rad),10,10);
  }
}
