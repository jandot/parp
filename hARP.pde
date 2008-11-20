Hashtable chromosomes = new Hashtable();
ReadPair[] read_pairs = new ReadPair[0];

int GENOME_SIZE = 3080419; // in kb
int WHOLE_SIZE = 800;
float PANEL_SIZE = WHOLE_SIZE;
float DIAMETER = 3*PANEL_SIZE/4;
float RADIUS = DIAMETER/2;

int qual_cutoff = 0;

PGraphics buffer;
PImage img;
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
  buffer = createGraphics(WHOLE_SIZE,WHOLE_SIZE,JAVA2D);
  
  buffer.beginDraw();
  buffer.background(255);
  buffer.smooth();
  buffer.strokeCap(SQUARE);
  buffer.textFont(font);

  // Draw the chromosomes and read pairs
  buffer.translate(PANEL_SIZE/2, PANEL_SIZE/2);
  buffer.strokeWeight(3);
  buffer.stroke(0);
  drawChromosomes();
  buffer.noFill();
  drawReadPairs();
  buffer.translate(-PANEL_SIZE/2, -PANEL_SIZE/2);

  // Draw quality cutoff slider (note: slider itself will be drawn in draw() itself!!)
  buffer.text("Quality cutoff", 50, buffer.height - 100 - textAscent());
  buffer.fill(225);
  buffer.strokeCap(ROUND);
  buffer.rect(50, buffer.height - 100, 20, 50);
  
  buffer.stroke(0);
  buffer.line(60, buffer.height - 95, 60, buffer.height - 55);
  
  img = buffer.get(0, 0, buffer.width, buffer.height);
}

void draw() {
  background(255);
  image(img, 0, 0);
  translate(PANEL_SIZE/2, PANEL_SIZE/2);
  drawHighlightedReadPairs();
  translate(-PANEL_SIZE/2, -PANEL_SIZE/2);
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
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.draw();
  }
}

void drawReadPairs() {
  for ( int i = 0; i < read_pairs.length; i++ ) {
    read_pairs[i].draw();
  }
}

void drawHighlightedReadPairs() {
  noFill();
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
  if ( mouseX >= 50 && mouseX <= 70 ) {
    if ( mouseY >= height - 95 && mouseY <= height - 55 ) {
      qual_cutoff = int(map(mouseY, height-95, height-55, 0, 40));
      println(qual_cutoff);
      drawStaticParts();
    }
  }
  
  redraw();
}


void keyPressed() {
  if ( key == 's' ) {
    save("picture.png");
  }
}
