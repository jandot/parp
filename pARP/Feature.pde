class Feature {
  int id;
  Chromosome chr;
  int start;
  int stop;
  float x1;
  float x2;
  boolean visible;

  Feature(String chr, int start, int stop) {
    this.id = feature_counter;
    feature_counter++;
    this.chr = ( Chromosome ) chromosomes.get(int(chr));
    this.start = start;
    this.stop = stop;
    this.x1 = map(this.start, 0, this.chr.len, 0, width);
    this.x2 = map(this.stop, 0, this.chr.len, 0, width);

    this.visible = true;
    this.chr.addFeature(this);
  }

  void drawBufferLinearZoom(int line_y, String position) {
    if ( this.visible ) {
      int y1;
      int y2;
      if ( position == "top" ) {
        y1 = line_y - 25;
        y2 = line_y - 20;
      } 
      else {
        y1 = line_y + 20;
        y2 = line_y + 25;
      }
      buffer_linear_zoom.rect(this.x1, y1, this.x2, y2);
    }
  }

  void update_x(Chromosome chr, float left_border, float area) {
    this.x1 = map(this.start, left_border, left_border + area, 0, width);
    this.x2 = map(this.stop, left_border, left_border + area, 0, width);

    if ( this.x1 > width || this.x2 < 0 ) {
      this.visible = false;
    } 
    else {
      this.visible = true;
    }
  }

}

