Hashtable chromosomes = new Hashtable();
ReadPair[] read_pairs = new ReadPair[0];

int GENOME_SIZE = 3080419; // in kb
int WIDTH = 1200;
int HEIGHT = 600;
float DIAMETER = 3*HEIGHT/8;
float RADIUS = DIAMETER/2;

int qual_cutoff = 0;

PGraphics buffer_circular;
PImage img_circular;
PGraphics buffer_linear_top;
PImage img_linear_top;
PImage ideogram_top;
PGraphics buffer_linear_bottom;
PImage img_linear_bottom;
PImage ideogram_bottom;
PGraphics buffer_qualcutoffslider;
PImage img_qualcutoffslider;
PImage tmp_ideogram;

PFont font;

int chr_number_1 = 16;
int chr_number_2 = 17;

Chromosome chr1;
Chromosome chr2;

void setup() {
  size(WIDTH, HEIGHT);
  
  font = createFont("SansSerif", 16);
  textFont(font);
  loadChromosomes();
  loadReadPairs();

  chr1 = (Chromosome) chromosomes.get(chr_number_1);
  chr2 = (Chromosome) chromosomes.get(chr_number_2);

  strokeCap(SQUARE);

  smooth();
  noLoop();

  drawStaticParts();
}

void drawStaticParts() {
  drawStaticCircular();
  drawStaticQualCutoffSlider();
  drawLinear(chr1, "top");
  drawLinear(chr2, "bottom");
}

void drawStaticQualCutoffSlider() {
  buffer_qualcutoffslider = createGraphics(WIDTH/2,HEIGHT/2,JAVA2D);

  buffer_qualcutoffslider.beginDraw();
  buffer_qualcutoffslider.background(255);
  buffer_qualcutoffslider.smooth();
  buffer_qualcutoffslider.textFont(font);

  // Draw  cutoff slider (note: slider itself will be drawn in draw() itself!!)
  buffer_qualcutoffslider.fill(0);
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
  image(img_qualcutoffslider, WIDTH/2, 0);
  image(img_circular, 0, 0);
  image(img_linear_top, 0, HEIGHT/2);
  image(img_linear_bottom, 0, 3*HEIGHT/4);
  
  translate(WIDTH/4, HEIGHT/4);
  drawHighlightedReadPairs();
  translate(-WIDTH/4, -HEIGHT/4);

  // Draw quality score cutoff
  float y_qual_cutoff = map(qual_cutoff, 0, 40, HEIGHT/2 - 95, HEIGHT/2 - 55);
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(WIDTH/2 + 55, y_qual_cutoff, WIDTH/2 + 65, y_qual_cutoff);
  text(qual_cutoff, WIDTH/2 + 55, HEIGHT/2 - 20);

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
  String[] rows = loadStrings("data.tsv");
  for ( int i = 0; i < rows.length; i++ ) {
    String[] fields = split(rows[i], TAB);

    ReadPair rp;
    if ( fields.length == 5 ) {
      rp = new ReadPair(fields[0], int(fields[1]), fields[2], int(fields[3]), fields[4], 20);
    } else {
      rp = new ReadPair(fields[0], int(fields[1]), fields[2], int(fields[3]), fields[4], int(fields[5]));
    }
    read_pairs = (ReadPair[]) append(read_pairs, rp);
  }
}

void drawChromosomes() {
  buffer_circular.strokeWeight(3);
  buffer_circular.stroke(0);
  for ( int i = 1; i <= 24; i++ ) {
    Chromosome chr = (Chromosome) chromosomes.get(i);
    chr.draw_circular();
  }
}

void drawReadPairs() {
  buffer_circular.strokeWeight(0.5);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    read_pairs[i].draw_circular();
  }
}

void drawHighlightedReadPairs() {
  noFill();
  stroke(255,0,0,50);
  strokeWeight(2);
  for ( int i = 0; i < read_pairs.length; i++ ) {
    if ( read_pairs[i].activated ) {
      read_pairs[i].draw_circular_highlighted();
      read_pairs[i].draw_linear_intrachromosomal_highlighted(chr1, "top");
      read_pairs[i].draw_linear_intrachromosomal_highlighted(chr2, "bottom");
    }
  }
}

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

