void mouseMoved() {
  if ( mouseY < HEIGHT/2 ) {
    active_panel = 1;
  } else if ( mouseY < 3*HEIGHT/4 ) {
    active_panel = 2;
  } else {
    active_panel = 3;
  }
  
  if ( active_panel == 1 ) {
    for ( int i = 0; i < read_pair_counter; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(i);
      if ( ( abs(rp.circular_x1 - mouseX + WIDTH/4) < 5 && abs(rp.circular_y1 - mouseY + HEIGHT/4) < 5 )  || ( abs(rp.circular_x2 - mouseX + WIDTH/4) < 5 && abs(rp.circular_y2 - mouseY + HEIGHT/4) < 5 ) ) {
        rp.activated = true;
      } else {
        rp.activated = false;
      }
      read_pairs.put(rp.id, rp);
    }
  } else if ( active_panel == 2 ) {
    linearPanel.top_chromosome.zoom_box_left_activated = false;
    linearPanel.top_chromosome.zoom_box_right_activated = false;
    if ( ( mouseY >= HEIGHT/2 + linearPanel.top_chromosome.ideogram_y1 && mouseY <= HEIGHT/2 + linearPanel.top_chromosome.ideogram_y1 + linearPanel.top_chromosome.ideogram.height) ) {
      strokeWeight(5);
      stroke(50);
      if ( abs( mouseX - linearPanel.top_chromosome.zoom_box_ideogram_x1 ) < 5 ) {
        linearPanel.top_chromosome.zoom_box_left_activated = true;
      } else if ( abs(mouseX - linearPanel.top_chromosome.zoom_box_ideogram_x2 ) < 5 ) {
        linearPanel.top_chromosome.zoom_box_right_activated = true;
      }
    }
    
    for ( int i = 0; i < linearPanel.top_chromosome.chr.intrachromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.top_chromosome.chr.intrachromosomal_read_pair_ids[i]);
      if ( abs(rp.linear_x1 - mouseX) < 5 || abs(rp.linear_x2 - mouseX) < 5 ) {
        rp.activated = true;
      } else {
        rp.activated = false;
      }
      
      read_pairs.put(rp.id, rp);
    }
    for ( int i = 0; i < linearPanel.interchromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.interchromosomal_read_pair_ids[i]);
      if ( abs(rp.linear_x1 - mouseX) < 5 || abs(rp.linear_x2 - mouseX) < 5 ) {
        rp.activated = true;
      } else {
        rp.activated = false;
      }
      
      read_pairs.put(rp.id, rp);
    }
  } else if ( active_panel == 3 ) {
    for ( int i = 0; i < linearPanel.bottom_chromosome.chr.intrachromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.bottom_chromosome.chr.intrachromosomal_read_pair_ids[i]);
      if ( abs(rp.linear_x1 - mouseX) < 5 || abs(rp.linear_x2 - mouseX) < 5 ) {
        rp.activated = true;
      } else {
        rp.activated = false;
      }
      
      read_pairs.put(rp.id, rp);

    }
    for ( int i = 0; i < linearPanel.interchromosomal_read_pair_ids.length; i++ ) {
      ReadPair rp = ( ReadPair ) read_pairs.get(linearPanel.interchromosomal_read_pair_ids[i]);
      if ( abs(rp.linear_x1 - mouseX) < 5 || abs(rp.linear_x2 - mouseX) < 5 ) {
        rp.activated = true;
      } else {
        rp.activated = false;
      }
      
      read_pairs.put(rp.id, rp);
    }
  }
  drawBufferCircularHighlighted();
  drawBufferLinearHighlighted();
  redraw();
}

void mouseClicked() {
  if ( keyPressed && ( key == '1' || key == '2' ) ) {
    for ( int i = 0; i < chromosome_labels.length; i++ ) {
      if ( mouseX >= chromosome_labels[i].x1 && mouseX <= chromosome_labels[i].x2 && mouseY >= chromosome_labels[i].y1 && mouseY <= chromosome_labels[i].y2 ) {
        if ( key == '1' ) {
          chr_number_1 = chromosome_labels[i].label;
          chr1 = (Chromosome) chromosomes.get(chr_number_1);
        } else {
          chr_number_2 = chromosome_labels[i].label;
          chr2 = (Chromosome) chromosomes.get(chr_number_2);
        }
      }
    }
    linearPanel = new LinearPanel(chr_number_1, chr_number_2);
    drawBufferLinearIdeograms();
    drawBufferLinearZoom();
    drawBufferLinearHighlighted();
    redraw();
  }
}

void keyPressed() {
  if ( key == 's' ) {
    save("picture.png");
  }
  
}
