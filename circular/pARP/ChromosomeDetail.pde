class ChromosomeDetail {
  String panel;
  Chromosome chr;
  float area;
  float left_border;
  int line_y;
  PImage ideogram;
  float ideogram_x1;
  float ideogram_y1;
  float zoom_box_ideogram_x1;
  float zoom_box_ideogram_x2;
  float zoom_box_ideogram_dx;
  boolean zoom_box_left_activated = false;
  boolean zoom_box_right_activated = false;

  ChromosomeDetail(Chromosome chr, String panel) {
    this.panel = panel;
    this.chr = chr;
    this.area = chr.len;
    this.left_border = 0;
    this.ideogram = loadImage("ideograms/chr" + this.chr.number + ".png");

    this.ideogram_x1 = 3;
    if ( this.panel == "top" ) {
      this.ideogram_y1 = 3;
      this.line_y = HEIGHT/8;
    } 
    else {
      this.ideogram_y1 = HEIGHT/2 - this.ideogram.height - 3;
      this.line_y = 3*HEIGHT/8;
    }

    this.zoom_box_ideogram_x1 = map(this.left_border, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_x2 = map(this.left_border + this.area, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_dx = this.zoom_box_ideogram_x2 - this.zoom_box_ideogram_x1;

  }

  void drawBufferLinearIdeograms() {
    buffer_linear_ideograms.image(this.ideogram, this.ideogram_x1, this.ideogram_y1);

    buffer_linear_ideograms.fill(0);
    buffer_linear_ideograms.text("Chromosome " + this.chr.number, this.ideogram.width + 10, this.ideogram_y1 + textAscent());
    buffer_linear_ideograms.line(0, this.line_y, buffer_linear_ideograms.width, this.line_y);

    buffer_linear_ideograms.noFill();
    buffer_linear_ideograms.strokeWeight(0.5);
  }

  void drawBufferLinearZoom() {
    // Draw the zoom box
    buffer_linear_zoom.fill(0,255,0,50);
    buffer_linear_zoom.stroke(0);
    buffer_linear_zoom.strokeWeight(1);
    buffer_linear_zoom.rect(this.zoom_box_ideogram_x1, this.ideogram_y1, this.zoom_box_ideogram_x2, this.ideogram_y1 + this.ideogram.height);
    buffer_linear_zoom.noFill();

    // Draw the intrachromosomal readpairs
    buffer_linear_zoom.strokeWeight(0.5);
    for ( int i = 0; i < this.chr.intrachromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(this.chr.intrachromosomal_read_pair_ids[i]);
      rp.drawBufferLinearZoom(this.line_y, this.panel);
    }
  }

  void drawBufferLinearHighlighted() {
    // Highlight the side of the zoombox when mouse hovers
    buffer_linear_highlighted.strokeWeight(5);
    buffer_linear_highlighted.stroke(100);
    buffer_linear_highlighted.strokeCap(ROUND);
    if ( this.zoom_box_left_activated ) {
      buffer_linear_highlighted.line(this.zoom_box_ideogram_x1, this.ideogram_y1, this.zoom_box_ideogram_x1, this.ideogram_y1 + this.ideogram.height);
    }
    if ( this.zoom_box_right_activated ) {
      buffer_linear_highlighted.line(this.zoom_box_ideogram_x2, this.ideogram_y1, this.zoom_box_ideogram_x2, this.ideogram_y1 + this.ideogram.height);
    }

    // Draw highlighted read pairs
    buffer_linear_highlighted.strokeCap(SQUARE);
    buffer_linear_highlighted.strokeWeight(1);
    buffer_linear_highlighted.stroke(255,0,0);
    for ( int i = 0; i < this.chr.intrachromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(this.chr.intrachromosomal_read_pair_ids[i]);
      if ( rp.activated ) {
        rp.drawBufferLinearHighlighted(this.line_y, this.panel);
      }
    }
  }

  void zoom(String border) {
    float x1 = this.zoom_box_ideogram_x1;
    float x2 = this.zoom_box_ideogram_x2;
    if ( border == "left" ) {
      x1 += mouseX - pmouseX;
    } 
    else {
      x2 += mouseX - pmouseX;
    }

    if ( x1 < x2 && x1 >= this.ideogram_x1 && x2 <= this.ideogram_x1 + this.ideogram.width ) {
      if ( border == "left" ) {
        this.zoom_box_ideogram_x1 = x1;
        this.left_border = map(this.zoom_box_ideogram_x1, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width, 0, this.chr.len);
      } 
      else {
        this.zoom_box_ideogram_x2 = x2;
      }
      this.zoom_box_ideogram_dx = this.zoom_box_ideogram_x2 - this.zoom_box_ideogram_x1;
      this.area = map(this.zoom_box_ideogram_dx, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width, 0, this.chr.len);

      for ( int i = 0; i < this.chr.intrachromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(this.chr.intrachromosomal_read_pair_ids[i]);
        rp.update_x(this.chr, this.left_border, this.area);
      }
      for ( int i = 0; i < linearPanel.interchromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.interchromosomal_read_pair_ids[i]);
        rp.update_x(this.chr, this.left_border, this.area);
      }

    }

  }

  void pan() {
    int dx = mouseX - pmouseX;
    if ( this.zoom_box_ideogram_x1 + dx >= this.ideogram_x1 && this.zoom_box_ideogram_x2 + dx <= this.ideogram_x1 + this.ideogram.width ) {
      this.zoom_box_ideogram_x1 += dx;
      this.zoom_box_ideogram_x2 = this.zoom_box_ideogram_x1 + this.zoom_box_ideogram_dx;

      this.left_border = map(this.zoom_box_ideogram_x1, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width, 0, this.chr.len);

      for ( int i = 0; i < this.chr.intrachromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(this.chr.intrachromosomal_read_pair_ids[i]);
        rp.update_x(this.chr, this.left_border, this.area);
      }

      for ( int i = 0; i < linearPanel.interchromosomal_read_pair_ids.length; i++ ) {
        ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.interchromosomal_read_pair_ids[i]);
        rp.update_x(this.chr, this.left_border, this.area);
      }
    }
  }

}
