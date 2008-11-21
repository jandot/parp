class ReadPair {
  Chromosome chr1;
  int pos1;
  float x1;
  Chromosome chr2;
  int pos2;
  float x2;
  float bezier_y;
  String code;
  int qual;
  color colour;
  boolean intrachromosomal;
  boolean activated;
  
  ReadPair(String chr1, int pos1, String chr2, int pos2, int qual, String code) {
    this.chr1 = (Chromosome) chromosomes.get(int(chr1));
    this.pos1 = pos1;
    this.chr2 = (Chromosome) chromosomes.get(int(chr2));
    this.pos2 = pos2;
    this.qual = qual;
    this.code = code;
    if ( this.code.equals("DIST") ) {
      this.colour = color(0,0,0);
    } else if ( this.code.equals("FF") ) {
      this.colour = color(0,255,0);
    } else if ( this.code.equals("RR") ) {
      this.colour = color(0,0,255);
    }
    
    if ( chr1.equals(chr2) ) {
      intrachromosomal = true;
    } else {
      intrachromosomal = false;
    }
    this.activated = false;
    
    this.x1 = map(this.pos1, 0, this.chr1.len, 0, width);
    this.x2 = map(this.pos2, 0, this.chr2.len, 0, width);
    
    if ( code.equals("DIST") ) {
      this.bezier_y = height/2 - 80 + random(-10,10);
    } else {
      this.bezier_y = height/2 + 80 + random(-10,10);
    }
  }
  
  void draw() {
    if ( this.intrachromosomal && this.chr1.number == CHR_NUMBER ) {
      if ( this.qual >= qual_cutoff ) {
        buffer.stroke(this.colour);
        buffer.bezier(x1, buffer.height/2, x1, this.bezier_y, x2, this.bezier_y, x2, buffer.height/2);
      }
    }
  }
  
  void draw_highlighted() {
    if ( this.intrachromosomal && this.chr1.number == CHR_NUMBER ) {
      if ( this.qual >= qual_cutoff ) {
        bezier(x1, height/2, x1, this.bezier_y, x2, this.bezier_y, x2, height/2);
      }
    }
  }

  void update_x() {
    this.x1 = map(this.pos1, left_border, left_border + area, 0, width);
    this.x2 = map(this.pos2, left_border, left_border + area, 0, width);
  }
  
}
