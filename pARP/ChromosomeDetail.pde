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
  Button[] buttons = new Button[0];

  ChromosomeDetail(Chromosome chr, String panel) {
    this.panel = panel;
    this.chr = chr;
    this.area = chr.len;
    this.left_border = 0;
    this.ideogram = loadImage("data/ideograms/chr" + this.chr.number + ".png");

    this.ideogram_x1 = 3;
    if ( this.panel == "top" ) {
      this.ideogram_y1 = 3;
      this.line_y = int(height/8);
    } else {
      this.ideogram_y1 = height/2 - this.ideogram.height - 3;
      this.line_y = int(3*height/8);
    }

    this.zoom_box_ideogram_x1 = map(this.left_border, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_x2 = map(this.left_border + this.area, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_dx = this.zoom_box_ideogram_x2 - this.zoom_box_ideogram_x1;

    Button button = new Button(this, "zoom", "Complete", "show_complete");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "zoom", "zoom out 10x", "zoom_out_10x");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "zoom", "zoom out 3x", "zoom_out_3x");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "zoom", "zoom in 3x", "zoom_in_3x");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "zoom", "zoom in 10x", "zoom_in_10x");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "pan", "<<", "left_large");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "pan", "<", "left_small");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "pan", ">", "right_small");
    this.buttons = ( Button[] ) append(this.buttons, button);
    button = new Button(this, "pan", ">>", "right_large");
    this.buttons = ( Button[] ) append(this.buttons, button);
  }

  void drawBufferLinearIdeograms() {
    buffer_linear_ideograms.image(this.ideogram, this.ideogram_x1, this.ideogram_y1);

    buffer_linear_ideograms.stroke(0);
    buffer_linear_ideograms.line(0, this.line_y, buffer_linear_ideograms.width, this.line_y);

    for ( int i = 0; i < this.buttons.length; i++ ) {
      this.buttons[i].draw();
    }
    
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
    
    // Draw features
    buffer_linear_zoom.fill(255,0,0);
    buffer_linear_zoom.noStroke();
    for ( int i = 0; i < this.chr.feature_ids.length; i++ ) {
      Feature f = ( Feature ) features.get(this.chr.feature_ids[i]);
      f.drawBufferLinearZoom(this.line_y, this.panel);
    }
    buffer_linear_zoom.noFill();

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
    
    buffer_linear_highlighted.fill(0);
    buffer_linear_highlighted.text("Chromosome " + this.chr.number + " (" + formatter.format(this.chr.len/1000) + "kb). Cursor position: " + formatter.format(map(mouseX, 0, buffer_linear_highlighted.width, this.left_border, this.left_border + this.area)) + "bp", this.ideogram.width + 10, this.ideogram_y1 + textAscent());
    buffer_linear_highlighted.noFill();
  }

  void zoomByDrag(String border) {
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
      for ( int i = 0; i < this.chr.feature_ids.length; i++ ) {
        Feature f = ( Feature ) features.get(this.chr.feature_ids[i]);
        f.update_x(this.chr, this.left_border, this.area);
      }

    }

  }

  void zoomByStep(String action) {
    if ( action == "show_complete" ) {
      this.left_border = 0;
      this.area = this.chr.len;
    } else if ( action == "zoom_in_10x" ) {
      this.area = max(this.area/10, 10);
    } else if ( action == "zoom_in_3x" ) {
      this.area = max(this.area/3, 10);
    } else if ( action == "zoom_out_3x" ) {
      this.area = min(this.area*3, this.chr.len);
      if ( this.left_border + this.area > this.chr.len ) {
        this.left_border = this.chr.len - this.area;
      }
    } else if ( action == "zoom_out_10x" ) {
      this.area = min(this.area*10, this.chr.len);
      if ( this.left_border + this.area > this.chr.len ) {
        this.left_border = this.chr.len - this.area;
      }
      
    }
    this.zoom_box_ideogram_x1 = map(this.left_border, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_x2 = map(this.left_border + this.area, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_dx = this.zoom_box_ideogram_x2 - this.zoom_box_ideogram_x1;
    
    for ( int i = 0; i < this.chr.intrachromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(this.chr.intrachromosomal_read_pair_ids[i]);
      rp.update_x(this.chr, this.left_border, this.area);
    }
    for ( int i = 0; i < linearPanel.interchromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.interchromosomal_read_pair_ids[i]);
      rp.update_x(this.chr, this.left_border, this.area);
    }
    for ( int i = 0; i < this.chr.feature_ids.length; i++ ) {
      Feature f = ( Feature ) features.get(this.chr.feature_ids[i]);
      f.update_x(this.chr, this.left_border, this.area);
    }
  }

  void panByDrag() {
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
      
      for ( int i = 0; i < this.chr.feature_ids.length; i++ ) {
        Feature f = ( Feature ) features.get(this.chr.feature_ids[i]);
        f.update_x(this.chr, this.left_border, this.area);
      }
      
      for ( int i = 0; i < this.chr.feature_ids.length; i++ ) {
        Feature f = ( Feature ) features.get(this.chr.feature_ids[i]);
        f.update_x(this.chr, this.left_border, this.area);
      }
    }
  }

  void panByStep(String action) {
    if ( action == "left_large" ) {
      this.left_border = max(this.left_border - this.area,0);
    } else if ( action == "left_small" ) {
      this.left_border = max(this.left_border - this.area/2,0);
    } else if ( action == "right_small" ) {
      this.left_border = min(this.left_border + this.area/2,(this.chr.len - this.area) - 10);
    } else if ( action == "right_large" ) {
      this.left_border = min(this.left_border + this.area,(this.chr.len - this.area) - 10);
    }
    this.zoom_box_ideogram_x1 = map(this.left_border, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_x2 = map(this.left_border + this.area, 0, this.chr.len, this.ideogram_x1, this.ideogram_x1 + this.ideogram.width);
    this.zoom_box_ideogram_dx = this.zoom_box_ideogram_x2 - this.zoom_box_ideogram_x1;
    
    for ( int i = 0; i < this.chr.intrachromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(this.chr.intrachromosomal_read_pair_ids[i]);
      rp.update_x(this.chr, this.left_border, this.area);
    }
    for ( int i = 0; i < linearPanel.interchromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.interchromosomal_read_pair_ids[i]);
      rp.update_x(this.chr, this.left_border, this.area);
    }
    for ( int i = 0; i < this.chr.feature_ids.length; i++ ) {
      Feature f = ( Feature ) features.get(this.chr.feature_ids[i]);
      f.update_x(this.chr, this.left_border, this.area);
    }
  }
  
  void applyButton(String type, String action) {
    if ( type == "zoom" ) {
      this.zoomByStep(action);
    } else {
      this.panByStep(action);
    }
  }
}

