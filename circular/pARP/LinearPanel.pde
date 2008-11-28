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

  void drawBufferLinearIdeograms() {
    buffer_linear_ideograms = createGraphics(WIDTH, this.height, JAVA2D);
    buffer_linear_ideograms.beginDraw();
    buffer_linear_ideograms.background(255);
    buffer_linear_ideograms.smooth();
    buffer_linear_ideograms.strokeCap(SQUARE);
    buffer_linear_ideograms.rectMode(CORNERS);
    buffer_linear_ideograms.textFont(font);
    this.top_chromosome.drawBufferLinearIdeograms();
    this.bottom_chromosome.drawBufferLinearIdeograms();
    buffer_linear_ideograms.endDraw();
  }

  void drawBufferLinearZoom() {
    buffer_linear_zoom = createGraphics(WIDTH, this.height, JAVA2D);
    buffer_linear_zoom.beginDraw();
    buffer_linear_zoom.background(img_linear_ideograms);
    buffer_linear_zoom.smooth();
    buffer_linear_zoom.strokeCap(SQUARE);
    buffer_linear_zoom.rectMode(CORNERS);
    buffer_linear_zoom.textFont(font);
    
    // First draw the zoom highlight box and intrachromosomal readpairs
    this.top_chromosome.drawBufferLinearZoom();
    this.bottom_chromosome.drawBufferLinearZoom();
    
    // Then draw the interchromosomal readpairs
    buffer_linear_zoom.stroke(0);
    if ( this.interchromosomal_read_pair_ids != null ) {
      for ( int i = 0; i < this.interchromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(this.interchromosomal_read_pair_ids[i]);
        if ( rp.qual >= qual_cutoff ) {
          float top_x;
          float bottom_x;
          if ( rp.chr1 == top_chromosome.chr ) {
            top_x = rp.linear_x1;
            bottom_x = rp.linear_x2;
          } else {
            top_x = rp.linear_x2;
            bottom_x = rp.linear_x1;
          }
          buffer_linear_zoom.bezier(top_x, top_chromosome.line_y, top_x, top_chromosome.line_y + 25, bottom_x, bottom_chromosome.line_y - 25, bottom_x, bottom_chromosome.line_y);
        }
      }
    }
    
    buffer_linear_zoom.endDraw();
  }
  
  void drawBufferLinearHighlighted() {
    buffer_linear_highlighted = createGraphics(WIDTH, this.height, JAVA2D);
    buffer_linear_highlighted.beginDraw();
    buffer_linear_highlighted.background(img_linear_zoom);
    buffer_linear_highlighted.smooth();
    buffer_linear_highlighted.strokeCap(SQUARE);
    buffer_linear_highlighted.rectMode(CORNERS);
    buffer_linear_highlighted.textFont(font);
    buffer_linear_highlighted.strokeWeight(1);
    buffer_linear_highlighted.stroke(255,0,0);
    buffer_linear_highlighted.noFill();
    
    // First draw the zoom highlight box and intrachromosomal readpairs
    this.top_chromosome.drawBufferLinearHighlighted();
    this.bottom_chromosome.drawBufferLinearHighlighted();
    
    // Then draw the interchromosomal readpairs
    if ( this.interchromosomal_read_pair_ids != null ) {
      stroke(255,0,0);
      for ( int i = 0; i < this.interchromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(this.interchromosomal_read_pair_ids[i]);
        if ( rp.activated && rp.qual >= qual_cutoff ) {
          float top_x;
          float bottom_x;
          if ( rp.chr1 == top_chromosome.chr ) {
            top_x = rp.linear_x1;
            bottom_x = rp.linear_x2;
          } else {
            top_x = rp.linear_x2;
            bottom_x = rp.linear_x1;
          }
          buffer_linear_highlighted.bezier(top_x, top_chromosome.line_y, top_x, top_chromosome.line_y + 25, bottom_x, bottom_chromosome.line_y - 25, bottom_x, bottom_chromosome.line_y);
        }
      }
    }
    
    buffer_linear_highlighted.endDraw();
  }
  
}
