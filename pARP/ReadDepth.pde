class ReadDepth {
  Chromosome chr;
  int position;
  float x;
  float value;
  boolean visible;

  ReadDepth(String chr, int position, float value) {
    this.chr = ( Chromosome ) chromosomes.get(int(chr));
    this.position = position;
    this.value = value;
    this.x = map(this.position, 0, this.chr.len, 0, width);

    this.visible = true;
    this.chr.addReadDepth(this);
  }

  void drawBufferLinearZoom(int line_y, String position) {
    if ( this.visible ) {
      float y;
      if ( position == "top" ) {
        y = line_y - 25 - 2*this.value;
      } 
      else {
        y = line_y + 25 + 2*this.value;
      }
      buffer_linear_zoom.ellipse(this.x, y, 1,1);
    }
  }

  void update_x(Chromosome chr, float left_border, float area) {
    if ( this.position > (left_border + area) || this.position < left_border ) {
      this.visible = false;
    } 
    else {
      this.x = map(this.position, left_border, left_border + area, 0, width);
      this.visible = true;
    }
  }

}
