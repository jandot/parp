class LinearPanel {
  int y1;
  int height;
  ChromosomeDetail top_chromosome;
  ChromosomeDetail bottom_chromosome;
  int[] interchromosomal_read_pair_ids;
  
  LinearPanel(int chr1, int chr2) {
    this.y1 = HEIGHT/2;
    this.height = HEIGHT/2;
    this.top_chromosome = new ChromosomeDetail(( Chromosome ) chromosomes.get(chr1), "top");
    this.bottom_chromosome = new ChromosomeDetail(( Chromosome ) chromosomes.get(chr2), "bottom");
    this.interchromosomal_read_pair_ids = ( int[] ) top_chromosome.chr.interchromosomal_read_pair_ids.get(chr2);
  }

  void drawStatic() {
    buffer_linear_panel = createGraphics(WIDTH, this.height, JAVA2D);
    buffer_linear_panel.beginDraw();
    buffer_linear_panel.background(255);
    buffer_linear_panel.smooth();
    buffer_linear_panel.strokeCap(SQUARE);
    buffer_linear_panel.rectMode(CORNERS);
    buffer_linear_panel.textFont(font);
    this.top_chromosome.draw();
    this.bottom_chromosome.draw();
    buffer_linear_panel.stroke(0);
    drawInterChromosomalStatic();
  }
  
  void drawIntraChromosomalDynamic() {
    translate(0, HEIGHT/2);
    this.top_chromosome.drawHighlightedReadPairs();
    this.bottom_chromosome.drawHighlightedReadPairs();
    translate(0, -HEIGHT/2);
  }
  
  void drawInterChromosomalStatic() {
    if ( this.interchromosomal_read_pair_ids != null ) {
      for ( int i = 0; i < this.interchromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(this.interchromosomal_read_pair_ids[i]);
        if ( rp.qual >= qual_cutoff ) {
          buffer_linear_panel.bezier(rp.linear_x1, top_chromosome.line_y, rp.linear_x1, top_chromosome.line_y + 25, rp.linear_x2, bottom_chromosome.line_y - 25, rp.linear_x2, bottom_chromosome.line_y);
        }
      }
    }
  }
  
  void drawInterChromosomalDynamic() {
    translate(0, HEIGHT/2);
    if ( this.interchromosomal_read_pair_ids != null ) {
      stroke(255,0,0);
      for ( int i = 0; i < this.interchromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(this.interchromosomal_read_pair_ids[i]);
        if ( rp.activated && rp.qual >= qual_cutoff ) {
          bezier(rp.linear_x1, top_chromosome.line_y, rp.linear_x1, top_chromosome.line_y + 25, rp.linear_x2, bottom_chromosome.line_y - 25, rp.linear_x2, bottom_chromosome.line_y);
        }
      }
    }
    translate(0, -HEIGHT/2);
  }

}
