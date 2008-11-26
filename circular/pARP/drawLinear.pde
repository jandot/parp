void drawLinear(Chromosome chr, String position) {
  PGraphics tmp_buffer;
  
  int panel_height = HEIGHT/4;
  int ideogram_x1 = 3;
  int ideogram_y1;
  int line_y = panel_height/2;
  float left_border = 0;
  float area = chr.len;
  float zoom_box_ideogram_x1;
  float zoom_box_ideogram_x2;
  float zoom_box_ideogram_dx;
  boolean zoom_box_left_activated = false;
  boolean zoom_box_right_activated = false;
  
  
  tmp_ideogram = loadImage("ideograms/chr" + chr.number + ".png");
  if ( position == "top" ) {
    ideogram_y1 = 3;
  } else {
    ideogram_y1 = panel_height - tmp_ideogram.height - 3;
  }

  zoom_box_ideogram_x1 = map(left_border, 0, chr.len, ideogram_x1, ideogram_x1 + tmp_ideogram.width);
  zoom_box_ideogram_x2 = map(left_border + area, 0, chr.len, ideogram_x1, ideogram_x1 + tmp_ideogram.width);
  zoom_box_ideogram_dx = zoom_box_ideogram_x2 - zoom_box_ideogram_x1;
  
  tmp_buffer = createGraphics(WIDTH,HEIGHT/4,JAVA2D);
  tmp_buffer.beginDraw();
  tmp_buffer.background(255);
  tmp_buffer.smooth();
  tmp_buffer.strokeCap(SQUARE);
  tmp_buffer.rectMode(CORNERS);
  tmp_buffer.textFont(font);

  tmp_buffer.image(tmp_ideogram, ideogram_x1, ideogram_y1);
  tmp_buffer.fill(0);
  tmp_buffer.text("chr " + chr.number, tmp_ideogram.width + 5, ideogram_y1 + textAscent());
  tmp_buffer.stroke(0);
  tmp_buffer.strokeWeight(1);
  tmp_buffer.line(0,line_y, WIDTH, line_y);

  tmp_buffer.noFill();
  tmp_buffer.strokeWeight(0.5);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    read_pairs[i].draw_linear_intrachromosomal(tmp_buffer, chr);
  }

  tmp_buffer.endDraw();
  
  if ( position == "top" ) {
    img_linear_top = tmp_buffer.get(0, 0, tmp_buffer.width, tmp_buffer.height);
  } else {
    img_linear_bottom = tmp_buffer.get(0, 0, tmp_buffer.width, tmp_buffer.height);
  }
}
