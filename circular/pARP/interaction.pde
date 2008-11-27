void mouseMoved() {
  for ( int i = 0; i < read_pairs.length; i++ ) {
    if ( ( abs(read_pairs[i].circular_x1 - mouseX + WIDTH/4) < 5 && abs(read_pairs[i].circular_y1 - mouseY + HEIGHT/4) < 5 )  || ( abs(read_pairs[i].circular_x2 - mouseX + WIDTH/4) < 5 && abs(read_pairs[i].circular_y2 - mouseY + HEIGHT/4) < 5 ) ) {
      read_pairs[i].activated = true;
    } else {
      read_pairs[i].activated = false;
    }
  }

  redraw();
}

void mouseClicked() {
  if ( keyPressed && ( key == '1' || key == '2' ) ) {
    for ( int i = 0; i < chromosome_labels.length; i++ ) {
      if ( mouseX >= chromosome_labels[i].x1 && mouseX <= chromosome_labels[i].x2 && mouseY >= chromosome_labels[i].y1 && mouseY <= chromosome_labels[i].y2 ) {
        if ( key == '1' ) {
          chr_number_1 = chromosome_labels[i].label;

          chr1 = (Chromosome) chromosomes.get(chr_number_1);
          drawLinear(chr1, "top");
        } else {
          chr_number_2 = chromosome_labels[i].label;
          chr2 = (Chromosome) chromosomes.get(chr_number_2);
          drawLinear(chr2, "bottom");
        }
      }
    }
    redraw();
  }
}

void mouseDragged() {
  if ( mouseX >= WIDTH/2 + 50 && mouseX <= WIDTH/2 + 70 ) {
    if ( mouseY >= HEIGHT/2 - 95 && mouseY <= HEIGHT/2 - 55 ) {
      qual_cutoff = int(map(mouseY, HEIGHT/2 - 95, HEIGHT/2 - 55, 0, 40));
      drawStaticCircular();
      drawLinear(chr1, "top");
      drawLinear(chr2, "bottom");
    }
  }


  redraw();
}


void keyPressed() {
  if ( key == 's' ) {
    save("picture.png");
  }
}
