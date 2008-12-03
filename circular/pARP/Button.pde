class Button {
  ChromosomeDetail chromosome_detail;
  String contents;
  String action;
  String type;
  float x1;
  float x2;
  float y1;
  float y2;
  
  Button(ChromosomeDetail chromosome_detail, String type, String contents, String action) {
    this.chromosome_detail = chromosome_detail;
    this.type = type;
    this.contents = contents;
    this.action = action;

    if ( chromosome_detail.buttons.length > 0 ) {
      this.x1 = chromosome_detail.buttons[chromosome_detail.buttons.length - 1].x2 + 10;
    } else {
      this.x1 = chromosome_detail.ideogram.width + 10;
    }
    this.x2 = this.x1 + textWidth(this.contents);
    this.y1 = chromosome_detail.ideogram_y1 + 1.2*textAscent();
    this.y2 = this.y1 + textAscent();
  }
  
  void draw() {
    buffer_linear_ideograms.fill(240);
    buffer_linear_ideograms.noStroke();
    buffer_linear_ideograms.rect(this.x1, this.y1, this.x1 + textWidth(this.contents) + 4, this.y1 + textAscent() + 4);
    buffer_linear_ideograms.fill(0);
    buffer_linear_ideograms.text(this.contents, this.x1, this.y1 + textAscent());
  }
}
