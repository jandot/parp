class ReadPair {
  Chromosome chr1;
  int pos1;
  float x1;
  float y1;
  float bezier1_x;
  float bezier1_y;
  Chromosome chr2;
  int pos2;
  float x2;
  float y2;
  float bezier2_x;
  float bezier2_y;
  String code;
  color colour;
  boolean intrachromosomal;
  
  float pos1_whole_genome;
  float pos2_whole_genome;
  float pos1_degree;
  float pos2_degree;
  float pos1_rad;
  float pos2_rad;
  float pos1_bezier;
  float pos2_bezier;
  boolean activated;
  
  ReadPair(String chr1, int pos1, String chr2, int pos2, String code) {
    this.chr1 = (Chromosome) chromosomes.get(int(chr1));
    this.pos1 = pos1;
    this.chr2 = (Chromosome) chromosomes.get(int(chr2));
    this.pos2 = pos2;
    this.code = code;
    if ( chr1 == chr2 ) {
      intrachromosomal = true;
    } else {
      intrachromosomal = false;
    }
    this.activated = false;

    this.pos1_whole_genome = this.chr1.start_whole_genome + this.pos1/1000;
    this.pos2_whole_genome = this.chr2.start_whole_genome + this.pos2/1000;

    float pos1_degree = ( this.pos1_whole_genome/GENOME_SIZE ) * 360;
    float pos2_degree = ( this.pos2_whole_genome/GENOME_SIZE) * 360;
    this.pos1_rad = radians(pos1_degree);
    this.pos2_rad = radians(pos2_degree);
    this.x1 = RADIUS*cos(this.pos1_rad);
    this.y1 = RADIUS*sin(this.pos1_rad);
    this.bezier1_x = (RADIUS-30)*cos(this.pos1_rad);
    this.bezier1_y = (RADIUS-30)*sin(this.pos1_rad);
    this.bezier2_x = (RADIUS-30)*cos(this.pos2_rad);
    this.bezier2_y = (RADIUS-30)*sin(this.pos2_rad);
    this.x2 = RADIUS*cos(this.pos2_rad);
    this.y2 = RADIUS*sin(this.pos2_rad);

    if ( code.equals("FF") ) {
      this.colour = color(255,0,0);
    } else if ( code.equals("RR") ) {
      this.colour = color(0,255,0);
    } else if ( code.equals("DIST") ) {
      this.colour = color(0,0,255);
    } else {
      this.colour = color(0);
    }
  }

  void draw() {
    buffer.stroke(this.colour, 5);
    buffer.strokeWeight(0.5);
    buffer.bezier(x1,y1,bezier1_x,bezier1_y,bezier2_x,bezier2_y,x2,y2);
  }

  void draw_highlighted() {
    stroke(255,0,0,25);
    strokeWeight(2);
    bezier(x1,y1,bezier1_x,bezier1_y,bezier2_x,bezier2_y,x2,y2);
  } 
}
