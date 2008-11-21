Hashtable chromosomes = new Hashtable();
ReadPair[] read_pairs = new ReadPair[0];

int GENOME_SIZE = 3080419; // in kb
int WHOLE_SIZE = 800;
float PANEL_SIZE = WHOLE_SIZE/2;
float DIAMETER = 3*PANEL_SIZE/4;
float RADIUS = DIAMETER/2;

int qual_cutoff = 0;

PGraphics buffer_circular;
PImage img_circular;
PGraphics buffer_qualcutoffslider;
PImage img_qualcutoffslider;

PFont font;

void setup() {
  size(WHOLE_SIZE,WHOLE_SIZE);
  
  font = createFont("SansSerif", 16);
  textFont(font);
  loadChromosomes();
  loadReadPairs();

  strokeCap(SQUARE);

  smooth();
  noLoop();
  
  drawStaticParts();
}

void drawStaticParts() {
  drawStaticCircular();
  drawStaticQualCutoffSlider();
}

void drawStaticCircular() {
  buffer_circular = createGraphics(int(PANEL_SIZE),int(PANEL_SIZE),JAVA2D);
  
  buffer_circular.beginDraw();
  buffer_circular.background(255);
  buffer_circular.smooth();
  buffer_circular.strokeCap(SQUARE);
  buffer_circular.textFont(font);

  // Draw the chromosomes and read pairs
  buffer_circular.translate(PANEL_SIZE/2, PANEL_SIZE/2);
  drawChromosomes();
  buffer_circular.noFill();
  drawReadPairs();
  buffer_circular.translate(-PANEL_SIZE/2, -PANEL_SIZE/2);
  buffer_circular.endDraw();
  
  img_circular = buffer_circular.get(0, 0, buffer_circular.width, buffer_circular.height);
}
  
void drawStaticQualCutoffSlider() {
  buffer_qualcutoffslider = createGraphics(int(PANEL_SIZE),int(PANEL_SIZE),JAVA2D);
  
  buffer_qualcutoffslider.beginDraw();
  buffer_qualcutoffslider.background(255);
  buffer_qualcutoffslider.smooth();
  buffer_qualcutoffslider.textFont(font);
  
  // Draw  cutoff slider (note: slider itself will be drawn in draw() itself!!)
  buffer_qualcutoffslider.text("Quality cutoff", 50, buffer_qualcutoffslider.height - 100 - textAscent());
  buffer_qualcutoffslider.fill(225);
  buffer_qualcutoffslider.strokeCap(ROUND);
  buffer_qualcutoffslider.rect(50, buffer_qualcutoffslider.height - 100, 20, 50);
  
  buffer_qualcutoffslider.stroke(0);
  buffer_qualcutoffslider.line(60, buffer_qualcutoffslider.height - 95, 60, buffer_qualcutoffslider.height - 55);
  buffer_qualcutoffslider.endDraw();
  
  img_qualcutoffslider = buffer_qualcutoffslider.get(0, 0, buffer_qualcutoffslider.width, buffer_qualcutoffslider.height);
}

void draw() {
  background(255);
  image(img_qualcutoffslider, PANEL_SIZE, 0);
  image(img_circular, 0, 0);
  translate(PANEL_SIZE/2, PANEL_SIZE/2);
  drawHighlightedReadPairs();
  translate(-PANEL_SIZE/2, -PANEL_SIZE/2);
  
  // Draw quality score cutoff
  float y_qual_cutoff = map(qual_cutoff, 0, 40, PANEL_SIZE - 95, PANEL_SIZE - 55);
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(PANEL_SIZE + 55, y_qual_cutoff, PANEL_SIZE + 65, y_qual_cutoff);
  text(qual_cutoff, PANEL_SIZE + 55, PANEL_SIZE - 20);
}

void loadChromosomes() {
  String[] rows = loadStrings("meta_data.tsv");
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);
    
    Chromosome chr = new Chromosome(int(fields[0]), int(fields[1]), int(fields[2]), int(fields[3]));
    chromosomes.put(int(fields[0]),chr);
  }
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.calculateRadians();
  }
}

void loadReadPairs() {
  String[] rows = loadStrings("tmp.csv");
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);
    
    ReadPair rp = new ReadPair(fields[0], int(fields[1]), fields[2], int(fields[3]), int(fields[4]), fields[5]);
    read_pairs = (ReadPair[]) append(read_pairs, rp);
  }
}

void drawChromosomes() {
  buffer_circular.strokeWeight(3);
  buffer_circular.stroke(0);
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.draw();
  }
}

void drawReadPairs() {
  buffer_circular.strokeWeight(0.5);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    read_pairs[i].draw();
  }
}

void drawHighlightedReadPairs() {
  noFill();
  stroke(255,0,0,50);
  strokeWeight(2);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    if ( read_pairs[i].activated ) {
      read_pairs[i].draw_highlighted();
    }
  }
}

void mouseMoved() {
  for ( int i = 0; i < read_pairs.length; i++ ) {
    if ( ( abs(read_pairs[i].x1 - mouseX + PANEL_SIZE/2) < 5 && abs(read_pairs[i].y1 - mouseY + PANEL_SIZE/2) < 5 )  || ( abs(read_pairs[i].x2 - mouseX + PANEL_SIZE/2) < 5 && abs(read_pairs[i].y2 - mouseY + PANEL_SIZE/2) < 5 )) {
      read_pairs[i].activated = true;
    } else {
      read_pairs[i].activated = false;
    }
  }

  redraw();
}

void mouseDragged() {
  if ( mouseX >= PANEL_SIZE + 50 && mouseX <= PANEL_SIZE + 70 ) {
    if ( mouseY >= PANEL_SIZE - 95 && mouseY <= PANEL_SIZE - 55 ) {
      qual_cutoff = int(map(mouseY, PANEL_SIZE - 95, PANEL_SIZE - 55, 0, 40));
      drawStaticCircular();
    }
  }
  
  redraw();
}


void keyPressed() {
  if ( key == 's' ) {
    save("picture.png");
  }
}
