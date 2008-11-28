void drawStaticParts() {
  textFont(font);

  drawStaticCircularPanel();
  drawStaticQualCutoffSlider();
  drawStaticLinearPanel();
}

void drawStaticCircularPanel() {
  buffer_circular = createGraphics(WIDTH/2, HEIGHT/2,JAVA2D);
  
  buffer_circular.beginDraw();
  buffer_circular.background(255);
  buffer_circular.smooth();
  buffer_circular.strokeCap(SQUARE);
  buffer_circular.textFont(font);

  // Draw the chromosomes and read pairs
  buffer_circular.translate(WIDTH/4, HEIGHT/4);
  drawStaticCircularChromosomes();
  buffer_circular.noFill();
  drawStaticCircularReadPairs();
  buffer_circular.translate(-WIDTH/4, -HEIGHT/4);
  buffer_circular.endDraw();
  
  img_circular = buffer_circular.get(0, 0, buffer_circular.width, buffer_circular.height);
}

void drawStaticCircularChromosomes() {
  buffer_circular.strokeWeight(3);
  buffer_circular.stroke(0);
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.draw_circular();
  }
}

void drawStaticCircularReadPairs() {
  buffer_circular.strokeWeight(0.1);
  for ( int i = 0; i < read_pair_counter; i++ ) {
    ReadPair rp = ( ReadPair ) read_pairs.get(i);
    rp.draw_circular();
  }
}

void drawStaticLinearPanel() {
  linearPanel.drawStatic();
  img_linear_panel = buffer_linear_panel.get(0, 0, buffer_linear_panel.width, linearPanel.height);
}

void drawStaticQualCutoffSlider() {
  buffer_qualcutoffslider = createGraphics(WIDTH/2,HEIGHT/2,JAVA2D);

  buffer_qualcutoffslider.beginDraw();
  buffer_qualcutoffslider.background(255);
  buffer_qualcutoffslider.smooth();
  buffer_qualcutoffslider.textFont(font);

  // Draw  cutoff slider (note: slider itself will be drawn in draw() itself!!)
  buffer_qualcutoffslider.fill(0);
  buffer_qualcutoffslider.text("Quality cutoff", 50, buffer_qualcutoffslider.height - 100 - textAscent());
  buffer_qualcutoffslider.fill(225);
  buffer_qualcutoffslider.strokeCap(ROUND);
  buffer_qualcutoffslider.rect(50, buffer_qualcutoffslider.height - 100, 20, 50);

  buffer_qualcutoffslider.stroke(0);
  buffer_qualcutoffslider.line(60, buffer_qualcutoffslider.height - 95, 60, buffer_qualcutoffslider.height - 55);
  buffer_qualcutoffslider.endDraw();

  img_qualcutoffslider = buffer_qualcutoffslider.get(0, 0, buffer_qualcutoffslider.width, buffer_qualcutoffslider.height);
}


