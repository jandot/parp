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
    for ( int i = 0; i < chromosome_labels.length; i++ ) {
      Label l = chromosome_labels[i];
      if ( mouseX > l.x1 && mouseX < l.x2 && mouseY > l.y1 && mouseY < l.y2 ) {
        chromosome_labels[i].active = true;
      } else {
        chromosome_labels[i].active = false;
      }
    }
    
  } else if ( active_panel == 2 || active_panel == 3 ) {
    // Highlight read pairs around cursor for top chromosome
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

    // Highlight read pairs around cursor for bottom chromosome    
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
  
  // Show grey drag bar at side of ideogram
  if ( active_panel == 2 ) {
    linearPanel.top_chromosome.zoom_box_left_activated = false;
    linearPanel.top_chromosome.zoom_box_right_activated = false;
    
    if ( pmouseY >= HEIGHT/2 + 5 && pmouseY <= HEIGHT/2 + linearPanel.top_chromosome.ideogram.height + 5 ) {
      if ( abs(pmouseX - linearPanel.top_chromosome.zoom_box_ideogram_x1) < 5 ) {
        linearPanel.top_chromosome.zoom_box_left_activated = true;
      } else if ( abs(pmouseX - linearPanel.top_chromosome.zoom_box_ideogram_x2) < 5 ) {
        linearPanel.top_chromosome.zoom_box_right_activated = true;
      }
    }
  } else if ( active_panel == 3 ) {
    linearPanel.bottom_chromosome.zoom_box_left_activated = false;
    linearPanel.bottom_chromosome.zoom_box_right_activated = false;
    
    if ( pmouseY <= HEIGHT - 5 && pmouseY >= HEIGHT - linearPanel.bottom_chromosome.ideogram.height - 5 ) {
      if ( abs(pmouseX - linearPanel.bottom_chromosome.zoom_box_ideogram_x1) < 5 ) {
        linearPanel.bottom_chromosome.zoom_box_left_activated = true;
      } else if ( abs(pmouseX - linearPanel.bottom_chromosome.zoom_box_ideogram_x2) < 5 ) {
        linearPanel.bottom_chromosome.zoom_box_right_activated = true;
      }
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
    linearPanel.top_chromosome.zoomByStep("complete");
    linearPanel.bottom_chromosome.zoomByStep("complete");
    drawBufferLinearIdeograms();
    drawBufferLinearZoom();
    drawBufferLinearHighlighted();
    redraw();
  } else {
    for ( int i = 0; i < linearPanel.top_chromosome.buttons.length; i++ ) {
      if ( mouseX > linearPanel.top_chromosome.buttons[i].x1 && mouseX < linearPanel.top_chromosome.buttons[i].x2 && mouseY > HEIGHT/2 + linearPanel.top_chromosome.buttons[i].y1 && mouseY < HEIGHT/2 + linearPanel.top_chromosome.buttons[i].y2 ) {
        linearPanel.top_chromosome.applyButton(linearPanel.top_chromosome.buttons[i].type, linearPanel.top_chromosome.buttons[i].action);
        drawBufferLinearZoom();
        drawBufferLinearHighlighted();
        redraw();
      }
    }
    for ( int i = 0; i < linearPanel.bottom_chromosome.buttons.length; i++ ) {
      if ( mouseX > linearPanel.bottom_chromosome.buttons[i].x1 && mouseX < linearPanel.bottom_chromosome.buttons[i].x2 && mouseY > HEIGHT/2 + linearPanel.bottom_chromosome.buttons[i].y1 && mouseY < HEIGHT/2 + linearPanel.bottom_chromosome.buttons[i].y2 ) {
        linearPanel.bottom_chromosome.applyButton(linearPanel.bottom_chromosome.buttons[i].type, linearPanel.bottom_chromosome.buttons[i].action);
        drawBufferLinearZoom();
        drawBufferLinearHighlighted();
        redraw();
      }
    }
  }
}

void mouseDragged() {
  if ( active_panel == 2 ) {
    if ( pmouseY >= HEIGHT/2 + 5 && pmouseY <= HEIGHT/2 + linearPanel.top_chromosome.ideogram.height + 5 ) {
      if ( abs(pmouseX - linearPanel.top_chromosome.zoom_box_ideogram_x1) < 5 ) {
        linearPanel.top_chromosome.zoomByDrag("left");
      } else if ( abs(pmouseX - linearPanel.top_chromosome.zoom_box_ideogram_x2) < 5 ) {
        linearPanel.top_chromosome.zoomByDrag("right");
      } else if ( pmouseX > linearPanel.top_chromosome.zoom_box_ideogram_x1 + 5 && pmouseX < linearPanel.top_chromosome.zoom_box_ideogram_x2 - 5 ) {
        linearPanel.top_chromosome.panByDrag();
      }
    }
  } else if ( active_panel == 3 ) {
    if ( pmouseY <= HEIGHT - 5 && pmouseY >= HEIGHT - linearPanel.bottom_chromosome.ideogram.height - 5 ) {
      if ( abs(pmouseX - linearPanel.bottom_chromosome.zoom_box_ideogram_x1) < 5 ) {
        linearPanel.bottom_chromosome.zoomByDrag("left");
      } else if ( abs(pmouseX - linearPanel.bottom_chromosome.zoom_box_ideogram_x2) < 5 ) {
        linearPanel.bottom_chromosome.zoomByDrag("right");
      } else if ( pmouseX > linearPanel.bottom_chromosome.zoom_box_ideogram_x1 + 5 && pmouseX < linearPanel.bottom_chromosome.zoom_box_ideogram_x2 - 5 ) {
        linearPanel.bottom_chromosome.panByDrag();
      }
    }
  }
  drawBufferLinearZoom();
  drawBufferLinearHighlighted();
  redraw();
}

void keyPressed() {
  if ( key == 's' ) {
    save("picture.png");
  } else if ( key == CODED ) {
    if ( keyCode == UP ) {
      if ( qual_cutoff < max_qual ) {
        qual_cutoff += 1;
      }
    } else if ( keyCode == DOWN ) {
      if ( qual_cutoff > min_qual ) {
        qual_cutoff -= 1;
      }
    }
    drawBufferCircularAll();
    drawBufferCircularHighlighted();
    drawBufferLinearZoom();
    drawBufferLinearHighlighted();
    redraw();
  }
}
