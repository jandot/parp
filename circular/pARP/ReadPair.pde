class ReadPair {
  Chromosome chr1;
  int pos1;
  float circular_x1;
  float circular_y1;
  float circular_bezier1_x;
  float circular_bezier1_y;
  Chromosome chr2;
  int pos2;
  float circular_x2;
  float circular_y2;
  float circular_bezier2_x;
  float circular_bezier2_y;
  String code;
  int qual;
  color colour;
  boolean intrachromosomal;
  float linear_x1;
  float linear_x2;
  float linear_bezier_y;
  
  float pos1_whole_genome;
  float pos2_whole_genome;
  float pos1_degree;
  float pos2_degree;
  float pos1_rad;
  float pos2_rad;
  float pos1_circular_bezier;
  float pos2_circular_bezier;
  boolean activated;
  
  ReadPair(String chr1, int pos1, String chr2, int pos2, String code, int qual) {
    //TODO: sort by number: chr1 should be the bigger chr
    if ( int(chr1) > int(chr2) ) {
      String tmp = chr1;
      chr1 = chr2;
      chr2 = tmp;
    }
    this.chr1 = (Chromosome) chromosomes.get(int(chr1));
    this.pos1 = pos1;
    this.chr2 = (Chromosome) chromosomes.get(int(chr2));
    this.pos2 = pos2;
        
    this.qual = qual;
    this.code = code;
    if ( this.chr1.number == this.chr2.number ) {
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
    this.circular_x1 = RADIUS*cos(this.pos1_rad);
    this.circular_y1 = RADIUS*sin(this.pos1_rad);
    this.circular_bezier1_x = (RADIUS-30)*cos(this.pos1_rad);
    this.circular_bezier1_y = (RADIUS-30)*sin(this.pos1_rad);
    this.circular_bezier2_x = (RADIUS-30)*cos(this.pos2_rad);
    this.circular_bezier2_y = (RADIUS-30)*sin(this.pos2_rad);
    this.circular_x2 = RADIUS*cos(this.pos2_rad);
    this.circular_y2 = RADIUS*sin(this.pos2_rad);

    this.linear_x1 = map(this.pos1, 0, this.chr1.len*1000, 0, width);
    this.linear_x2 = map(this.pos2, 0, this.chr2.len*1000, 0, width);
    
    if ( this.code.equals("DIST") ) {
      this.colour = color(0,0,0);
      this.linear_bezier_y = HEIGHT/8 - 40 + random(-5,5);
    } else if ( this.code.equals("FF") ) {
      this.colour = color(0,255,0);
      this.linear_bezier_y = HEIGHT/8 + 40 + random(-5,5);
    } else if ( this.code.equals("RR") ) {
      this.colour = color(0,0,255);
      this.linear_bezier_y = HEIGHT/8 + 40 + random(-5,5);
    }
    
    if ( chr1 == chr2 ) {
      this.chr1.intrachromosomal_read_pairs = ( ReadPair[] ) append(this.chr1.intrachromosomal_read_pairs, this);
    } else {
//      println(chr1 + " " + chr2);
//      ReadPair[] inter = ( ReadPair[] ) this.chr1.interchromosomal_read_pairs.get(chr2);
//      inter = ( ReadPair[] ) append(inter, this);
//      this.chr1.interchromosomal_read_pairs.put(chr2, inter);
    }
  }

  void draw_circular() {
    if ( this.qual >= qual_cutoff && this.intrachromosomal == false) {
      buffer_circular.stroke(this.colour, 1);
      buffer_circular.bezier(circular_x1,circular_y1,circular_bezier1_x,circular_bezier1_y,circular_bezier2_x,circular_bezier2_y,circular_x2,circular_y2);
    }
  }

  void draw_circular_highlighted() {
    if ( this.qual >= qual_cutoff && this.intrachromosomal  == false) {
      bezier(circular_x1,circular_y1,circular_bezier1_x,circular_bezier1_y,circular_bezier2_x,circular_bezier2_y,circular_x2,circular_y2);
    }
  }
  
  void draw_linear_intrachromosomal(PGraphics buffer, Chromosome chr) {
    if ( this.chr1.number == chr.number && this.intrachromosomal ) {
      if ( this.qual >= qual_cutoff ) {
        buffer.stroke(this.colour);
        buffer.bezier(this.linear_x1, buffer.height/2, this.linear_x1, linear_bezier_y, this.linear_x2, linear_bezier_y, this.linear_x2, buffer.height/2);
      }
    }
  }

  void draw_linear_intrachromosomal_highlighted(Chromosome chr, String position) {
//    if ( ( this.chr1.number == chr.number || this.chr2.number == chr.number ) && this.intrachromosomal && this.activated ) {
//      stroke(255,0,0);
//      float y;
//      if ( position == "top" ) {
//        y = HEIGHT/8;
//      } else {
//        y = 3*HEIGHT/8;
//      }
//      bezier(this.linear_x1, y, this.linear_x1, HEIGHT/2 + linear_bezier_y, this.linear_x2, HEIGHT/2 + linear_bezier_y, this.linear_x2, y);
//    }
  }
  
//  void draw_linear_interchromosomal(PGraphics buffer, Chromosome chr1, Chromosome chr2) {
//    
//  }
}
