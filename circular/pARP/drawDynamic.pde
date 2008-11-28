void drawCircularHighlightedReadPairs() {
  noFill();
  stroke(255,0,0,50);
  strokeWeight(2);
  
  for ( int i = 0; i < read_pair_counter; i++ ) {
    ReadPair rp = ( ReadPair ) read_pairs.get(i);
    if ( rp.activated ) {
      rp.draw_circular_highlighted();
    }
  }
}

void drawLinearHighlightedReadPairs() {
  linearPanel.drawIntraChromosomalDynamic();
  linearPanel.drawInterChromosomalDynamic();
}
