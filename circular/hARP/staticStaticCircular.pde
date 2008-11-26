void drawStaticCircular() {
  buffer_circular = createGraphics(WIDTH/2, HEIGHT/2,JAVA2D);
  
  buffer_circular.beginDraw();
  buffer_circular.background(255);
  buffer_circular.smooth();
  buffer_circular.strokeCap(SQUARE);
  buffer_circular.textFont(font);

  // Draw the chromosomes and read pairs
  buffer_circular.translate(WIDTH/4, HEIGHT/4);
  drawChromosomes();
  buffer_circular.noFill();
  drawReadPairs();
  buffer_circular.translate(-WIDTH/4, -HEIGHT/4);
  buffer_circular.endDraw();
  
  img_circular = buffer_circular.get(0, 0, buffer_circular.width, buffer_circular.height);
}
