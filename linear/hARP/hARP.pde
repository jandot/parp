Hashtable chromosomes = new Hashtable();
ReadPair[] read_pairs = new ReadPair[0];

int WIDTH = 1200;
int HEIGHT = 400;

int CHR_NUMBER = 17;
Chromosome chr;

int ideogram_x1 = 3;
int ideogram_y1 = 3;

int qual_cutoff = 0;
float area;
float left_border = 0;
float zoom_box_ideogram_x1;
float zoom_box_ideogram_x2;
float zoom_box_ideogram_dx;
boolean zoom_box_left_activated = false;
boolean zoom_box_right_activated = false;

PGraphics buffer;
PImage img;
PImage ideogram;
PFont font;

void setup() {
  size(WIDTH, HEIGHT);
  
  font = createFont("SansSerif", 10);
  textFont(font);

  rectMode(CORNERS);
  loadChromosomes();
  chr = (Chromosome) chromosomes.get(CHR_NUMBER);
  ideogram = loadImage("ideograms/chr" + CHR_NUMBER + ".png");
  left_border = 0;
  area = chr.len;
  loadReadPairs();
  smooth();
  noLoop();

  zoom_box_ideogram_x1 = map(left_border, 0, chr.len, ideogram_x1, ideogram_x1 + ideogram.width);
  zoom_box_ideogram_x2 = map(left_border + area, 0, chr.len, ideogram_x1, ideogram_x1 + ideogram.width);
  zoom_box_ideogram_dx = zoom_box_ideogram_x2 - zoom_box_ideogram_x1;
  
  drawStaticParts();
}

void drawStaticParts() {
  buffer = createGraphics(WIDTH, HEIGHT, JAVA2D);
  
  buffer.beginDraw();
  buffer.background(255);
  buffer.smooth();
  buffer.strokeCap(SQUARE);
  buffer.rectMode(CORNERS);
  buffer.textFont(font);

  // Draw the ideogram
  buffer.image(ideogram,ideogram_x1, ideogram_y1);

  // Draw zoom box on ideogram
  buffer.fill(0,255,0,50);
  buffer.stroke(0);
  buffer.strokeWeight(1);
  buffer.rect(zoom_box_ideogram_x1,ideogram_y1,zoom_box_ideogram_x2,ideogram_y1 + ideogram.height);
  
  // Draw the chromosome name and some characteristics
  buffer.fill(0);
  buffer.text("Chromosome " + CHR_NUMBER + " (" + nf(chr.len/1000000,0,2) + " Mb; showing " + nf(left_border/1000000,0,2) + " to " + nf((left_border+area)/1000000,0,2) + " Mb)", 5, 50 );

  // Draw the line representing the chromosome
  buffer.line(0,buffer.height/2,buffer.width, buffer.height/2);
  
  // Draw the read pairs
  buffer.noFill();
  buffer.strokeWeight(0.5);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    read_pairs[i].draw();
  }

  // Draw quality cutoff slider (note: slider itself will be drawn in draw() itself!!)
  int qual_cutoff_x1 = 50;
  int qual_cutoff_y1 = buffer.height - 100;
  buffer.text("Quality cutoff", qual_cutoff_x1, qual_cutoff_y1 - textAscent());
  buffer.fill(225);
  buffer.strokeCap(ROUND);
  buffer.noStroke();
  buffer.rect(qual_cutoff_x1, qual_cutoff_y1, qual_cutoff_x1 + 20, qual_cutoff_y1 + 50);
  buffer.stroke(0);
  buffer.line(qual_cutoff_x1 + 10, qual_cutoff_y1 + 5, 60, qual_cutoff_y1 + 45);
  
  img = buffer.get(0, 0, buffer.width, buffer.height);
}

void draw() {
  background(200);
  
  image(img, 0, 0);
  drawHighlightedReadPairs();

  // Draw vertical green line
  noFill();
  strokeWeight(1);
  stroke(0,255,0,50);
  line(mouseX, 0, mouseX, height);
  
  // Draw green line on ideogram
  float ideogram_line_x = map(mouseX, 0, width, zoom_box_ideogram_x1, zoom_box_ideogram_x2);
  strokeWeight(2);
  stroke(0,255,0,200);
  line(ideogram_line_x, 0, ideogram_line_x, 50);
  
  strokeWeight(5);
  stroke(100);
  if ( zoom_box_left_activated ) {
    line(zoom_box_ideogram_x1, ideogram_y1, zoom_box_ideogram_x1, ideogram.height + 2*ideogram_y1);
  }
  if ( zoom_box_right_activated ) {
    line(zoom_box_ideogram_x2, ideogram_y1, zoom_box_ideogram_x2, ideogram.height + 2*ideogram_y1);
  }
  
  // Draw position
  fill(0);
  text("Position: " + nfc(int(map(mouseX, 0, width, left_border, left_border + area)),0) + " bp", width/2, 20);

  // Draw quality score cutoff
  float y_qual_cutoff = map(qual_cutoff, 0, 40, height - 95, height - 55);
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(55, y_qual_cutoff, 65, y_qual_cutoff);
  text(qual_cutoff, 55, height - 20);
}

void loadChromosomes() {
  String[] rows = loadStrings("meta_data.tsv");
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);
    
    Chromosome chr = new Chromosome(int(fields[0]), int(fields[1]), int(fields[2]), int(fields[3]));
    chromosomes.put(int(fields[0]),chr);
  }
}

void loadReadPairs() {
  String[] rows = loadStrings("data.tsv");
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);
    
    ReadPair rp = new ReadPair(fields[0], int(fields[1]), fields[2], int(fields[3]), int(fields[4]), fields[5]);
    read_pairs = (ReadPair[]) append(read_pairs, rp);
  }
}

void drawHighlightedReadPairs() {
  noFill();
  stroke(255,0,0,100);
  strokeWeight(2);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    if ( read_pairs[i].activated ) {
      read_pairs[i].draw_highlighted();
    }
  }
}

void zoom(String border) {
  float x1 = zoom_box_ideogram_x1;
  float x2 = zoom_box_ideogram_x2;
  if ( border == "left" ) {
    x1 += mouseX - pmouseX;
  } else {
    x2 += mouseX - pmouseX;
  }
  
  if ( x1 < x2 && x1 >= ideogram_x1 && x2 <= ideogram_x1 + ideogram.width ) {
    if ( border == "left" ) {
      zoom_box_ideogram_x1 = x1;
      left_border = int(map(zoom_box_ideogram_x1, ideogram_x1, ideogram_x1 + ideogram.width, 0, chr.len));
    } else {
      zoom_box_ideogram_x2 = x2;
    }
    zoom_box_ideogram_dx = zoom_box_ideogram_x2 - zoom_box_ideogram_x1;
    area = int(map(zoom_box_ideogram_dx, ideogram_x1, ideogram_x1 + ideogram.width, 0, chr.len));

    for ( int i = 0; i < read_pairs.length; i++ ) {
      read_pairs[i].update_x();
    }
  
    drawStaticParts();
    redraw();
    
  }
  
}

void pan() {
  int dx = mouseX - pmouseX;
  if ( zoom_box_ideogram_x1 + dx >= ideogram_x1 && zoom_box_ideogram_x2 + dx <= ideogram_x1 + ideogram.width ) {
    zoom_box_ideogram_x1 += dx;
    zoom_box_ideogram_x2 = zoom_box_ideogram_x1 + zoom_box_ideogram_dx;
  
    left_border = int(map(zoom_box_ideogram_x1, ideogram_x1, ideogram_x1 + ideogram.width, 0, chr.len));
    
    for ( int i = 0; i < read_pairs.length; i++ ) {
      read_pairs[i].update_x();
    }
      
    drawStaticParts();
    redraw();
  }
}

void mouseMoved() {
  for ( int i = 0; i < read_pairs.length; i++ ) {    
    if ( abs(read_pairs[i].x1 - mouseX ) < 5  || abs(read_pairs[i].x2 - mouseX) < 5 ) {
      read_pairs[i].activated = true;
    } else {
      read_pairs[i].activated = false;
    }
  }

  zoom_box_left_activated = false;
  zoom_box_right_activated = false;
  if ( ( mouseY >= 5 && mouseY <= ideogram.height + 5) ) {
    strokeWeight(5);
    stroke(50);
    if ( abs( mouseX - zoom_box_ideogram_x1 ) < 5 ) {
      zoom_box_left_activated = true;
    } else if ( abs(mouseX - zoom_box_ideogram_x2 ) < 5 ) {
      zoom_box_right_activated = true;
    }
  }

  redraw();
}

void mouseDragged() {
  if ( ( pmouseY >= 5 && pmouseY <= ideogram.height + 5 ) ) {
    if ( abs( pmouseX - zoom_box_ideogram_x1 ) < 5 ) {
      zoom("left");
    } else if ( abs(pmouseX - zoom_box_ideogram_x2 ) < 5 ) {
      zoom("right");
    } else if ( pmouseX > zoom_box_ideogram_x1 + 5 && pmouseX < zoom_box_ideogram_x2 - 5 ) {
      pan();
    }
  }
  
  if ( mouseX >= 50 && mouseX <= 70 ) {
    if ( mouseY >= height - 95 && mouseY <= height - 55 ) {
      qual_cutoff = int(map(mouseY, height-95, height-55, 0, 40));
      drawStaticParts();
      redraw();
    }
  }
}
