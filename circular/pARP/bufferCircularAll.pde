// buffer_circular_all contains the static part of the circular display: the chromosomes and all interchromosomal read pairs in grey
void drawBufferCircularAll() {
  buffer_circular_all = createGraphics(WIDTH/2, HEIGHT/2,JAVA2D);
  
  buffer_circular_all.beginDraw();
  buffer_circular_all.background(255);
  buffer_circular_all.smooth();
  buffer_circular_all.strokeCap(SQUARE);
  buffer_circular_all.textFont(font);

  // Draw the chromosomes and read pairs
  buffer_circular_all.translate(WIDTH/4, HEIGHT/4);

  buffer_circular_all.strokeWeight(3);
  buffer_circular_all.stroke(0);
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.drawBufferCircularAll();
  }

  buffer_circular_all.noFill();

  buffer_circular_all.strokeWeight(0.1);
  for ( int i = 0; i < read_pair_counter; i++ ) {
    ReadPair rp = ( ReadPair ) read_pairs.get(i);
    rp.drawBufferCircularAll();
  }

  buffer_circular_all.translate(-WIDTH/4, -HEIGHT/4);
  buffer_circular_all.endDraw();
  
  img_circular_all = buffer_circular_all.get(0, 0, buffer_circular_all.width, buffer_circular_all.height);
}
