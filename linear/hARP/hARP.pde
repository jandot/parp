Hashtable chromosomes = new Hashtable();
ReadPair[] read_pairs = new ReadPair[0];

int WIDTH = 1200;
int HEIGHT = 400;

int CHR_NUMBER = 17;
Chromosome chr;

int qual_cutoff = 0;

PGraphics buffer;
PImage img;
PImage ideogram;
PFont font;

void setup() {
  size(1200, 400);
  
  font = createFont("SansSerif", 10);
  textFont(font);

  rectMode(CORNERS);
  loadChromosomes();
  chr = (Chromosome) chromosomes.get(CHR_NUMBER);
  loadReadPairs();
  smooth();
  noLoop();

  drawStaticParts();
}

void drawStaticParts() {
  buffer = createGraphics(WIDTH, HEIGHT, JAVA2D);
  
  buffer.beginDraw();
  buffer.background(255);
  buffer.smooth();
  buffer.strokeCap(SQUARE);
  buffer.textFont(font);

  // Draw the ideogram
  ideogram = loadImage("ideograms/chr" + CHR_NUMBER + ".png");
  buffer.image(ideogram,0,0);
  
  // Draw the chromosome name and some characteristics
  buffer.fill(0);
  buffer.text("Chromosome " + CHR_NUMBER + " (" + nf(chr.len/1000000,0,2) + " Mb)", 5, 50 );

  // Draw the line representing the chromosome
  buffer.line(0,buffer.height/2,buffer.width, buffer.height/2);
  
  // Draw the read pairs
  buffer.noFill();
  buffer.stroke(0);
  buffer.strokeWeight(0.5);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    read_pairs[i].draw();
  }
  
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
  float ideogram_line_x = map(mouseX, 0, width, 0, ideogram.width);
  strokeWeight(2);
  stroke(0,255,0,200);
  line(ideogram_line_x, 0, ideogram_line_x, 50);
  
  // Draw position
  fill(0);
  text("Position: " + nfc(int(map(mouseX, 0, width, 0, chr.len)),0) + " bp", width/2, 20);
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
    if ( abs(read_pairs[i].x1 - mouseX ) < 5  || abs(read_pairs[i].x2 - mouseX) < 5 ) {
      read_pairs[i].activated = true;
    } else {
      read_pairs[i].activated = false;
    }
  }

  redraw();
}

