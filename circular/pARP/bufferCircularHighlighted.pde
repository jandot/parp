// buffer_circular_highlighted contains the dynamic part of the circular display: the highlighted read pairs
void drawBufferCircularHighlighted() {
  buffer_circular_highlighted = createGraphics(WIDTH/2, HEIGHT/2,JAVA2D);
  
  buffer_circular_highlighted.beginDraw();

  buffer_circular_highlighted.background(img_circular_all); // background is the circle with all readpairs drawn in grey
  buffer_circular_highlighted.noFill();

  buffer_circular_highlighted.translate(WIDTH/4, HEIGHT/4);
  buffer_circular_highlighted.smooth();
  buffer_circular_highlighted.strokeCap(SQUARE);
  buffer_circular_highlighted.textFont(font);

  // Draw the chromosomes and read pairs
  buffer_circular_highlighted.stroke(255,0,0,50);
  buffer_circular_highlighted.strokeWeight(2);
  
  for ( int i = 0; i < read_pair_counter; i++ ) {
    ReadPair rp = ( ReadPair ) read_pairs.get(i);
    if ( rp.activated ) {
      rp.drawBufferCircularHighlighted();
    }
  }

  buffer_circular_highlighted.translate(-WIDTH/4, -HEIGHT/4);
  buffer_circular_highlighted.endDraw();
  
  img_circular_highlighted = buffer_circular_highlighted.get(0, 0, buffer_circular_highlighted.width, buffer_circular_highlighted.height);
}
