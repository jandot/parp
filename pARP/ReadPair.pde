class ReadPair {
  int id;
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
  float bezier_random;
  boolean visible;
  
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
    this.id = read_pair_counter;
    read_pair_counter++;
    if ( int(chr1) > int(chr2) ) {
      String tmp = chr1;
      chr1 = chr2;
      chr2 = tmp;
    }
    this.chr1 = (Chromosome) chromosomes.get(int(chr1));
    this.pos1 = pos1;
    this.chr2 = (Chromosome) chromosomes.get(int(chr2));
    this.pos2 = pos2;
    this.bezier_random = random(-5,5);
    this.visible = true;
    
    this.qual = qual;
    if ( max_qual < qual ) { max_qual = qual; };
    if ( min_qual > qual ) { min_qual = qual; };
    this.code = code;
    if ( this.chr1.number == this.chr2.number ) {
      intrachromosomal = true;
    } else {
      intrachromosomal = false;
    }
    this.activated = false;

    this.pos1_whole_genome = this.chr1.start_whole_genome + this.pos1;
    this.pos2_whole_genome = this.chr2.start_whole_genome + this.pos2;

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

    this.linear_x1 = map(this.pos1, 0, this.chr1.len, 0, width);
    this.linear_x2 = map(this.pos2, 0, this.chr2.len, 0, width);
    
    if ( this.code.equals("DIST") ) {
      this.colour = color(0,0,0);
    } else if ( this.code.equals("FF") ) {
      this.colour = color(0,255,0);
    } else if ( this.code.equals("RR") ) {
      this.colour = color(0,0,255);
    }
    
    if ( this.intrachromosomal ) {
      this.chr1.addReadPair(this);
    } else {
      this.chr2.addReadPair(this, this.chr1);
      this.chr1.addReadPair(this, this.chr2);
    }

  }

  void drawBufferCircularAll() {
    if ( this.qual >= qual_cutoff && this.intrachromosomal == false) {
      buffer_circular_all.stroke(this.colour, 1);
      buffer_circular_all.bezier(circular_x1,circular_y1,circular_bezier1_x,circular_bezier1_y,circular_bezier2_x,circular_bezier2_y,circular_x2,circular_y2);
    }
  }

  void drawBufferCircularHighlighted() {
    if ( this.qual >= qual_cutoff && this.intrachromosomal  == false) {
      buffer_circular_highlighted.bezier(circular_x1,circular_y1,circular_bezier1_x,circular_bezier1_y,circular_bezier2_x,circular_bezier2_y,circular_x2,circular_y2);
    }
  }
  
  void drawBufferLinearZoom(int line_y, String position) {
    if ( this.qual >= qual_cutoff && this.visible ) {
      float linear_bezier_y;
      int dy;
      if ( position == "top" ) {
        dy = 20;
      } else {
        dy = -20;
      }
      if ( this.code.equals("DIST") ) {
        linear_bezier_y = line_y - dy + this.bezier_random;
      } else {
        linear_bezier_y = line_y + dy + this.bezier_random;
      }
      buffer_linear_zoom.stroke(this.colour);
      buffer_linear_zoom.bezier(this.linear_x1, line_y, this.linear_x1, linear_bezier_y, this.linear_x2, linear_bezier_y, this.linear_x2, line_y);
    }
  }
  
  void drawBufferLinearHighlighted(int line_y, String position) {
    if ( this.qual >= qual_cutoff && this.visible ) {
      float linear_bezier_y;
      int dy;
      if ( position == "top" ) {
        dy = 20;
      } else {
        dy = -20;
      }
      if ( this.code.equals("DIST") ) {
        linear_bezier_y = line_y - dy + this.bezier_random;
      } else {
        linear_bezier_y = line_y + dy + this.bezier_random;
      }
      buffer_linear_highlighted.bezier(this.linear_x1, line_y, this.linear_x1, linear_bezier_y, this.linear_x2, linear_bezier_y, this.linear_x2, line_y);
    }
  }

  void update_x(Chromosome chr, float left_border, float area) {
//    if ( this.intrachromosomal ) {
//      if ( ( this.pos1 < left_border || this.pos1 > left_border + area ) && ( this.pos2 < left_border || this.pos2 > left_border + area) ) {
//        this.visible = false;
//      } else {
//        this.visible = true;
//      }
//    } else {
//      if ( this.chr1 == chr ) {
//        if ( ( this.pos1 < linearPanel.top_chromosome.left_border || this.pos1 > linearPanel.top_chromosome.left_border + linearPanel.top_chromosome.area ) && ( this.pos2 < linearPanel.bottom_chromosome.left_border || this.pos2 > linearPanel.bottom_chromosome.left_border + linearPanel.bottom_chromosome.area ) ) {
//          this.visible = false;
//        } else {
//          this.visible = true;
//        }
//      } else { // chr2 = topchromosome
//        if ( ( this.pos2 < linearPanel.top_chromosome.left_border || this.pos2 > linearPanel.top_chromosome.left_border + linearPanel.top_chromosome.area ) && ( this.pos1 < linearPanel.bottom_chromosome.left_border || this.pos1 > linearPanel.bottom_chromosome.left_border + linearPanel.bottom_chromosome.area ) ) {
//          this.visible = false;
//        } else {
//          this.visible = true;
//        }
//      }
//    }
  
//    if ( this.visible ) {
      if ( this.intrachromosomal ) {
        this.linear_x1 = map(this.pos1, left_border, left_border + area, 0, width);
        this.linear_x2 = map(this.pos2, left_border, left_border + area, 0, width);
      } else {
        if ( this.chr1 == chr ) {
          this.linear_x1 = map(this.pos1, left_border, left_border + area, 0, width);
        } else {
          this.linear_x2 = map(this.pos2, left_border, left_border + area, 0, width);
        }
      }
      
      if ( ( this.linear_x1 < 0 || this.linear_x1 > width ) && ( this.linear_x2 < 0 || this.linear_x2 > width ) ) {
        this.visible = false;
      } else {
        this.visible = true;
      }

//    }

  }
}
