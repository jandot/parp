String INPUT_FILE = "data.tsv";

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

Label[] chromosome_labels = new Label[0];

int chr_number_1 = 6;
int chr_number_2 = 22;

Chromosome chr1;
Chromosome chr2;

void setup() {
  size(WIDTH, HEIGHT);
  
  font = createFont("SansSerif", 16);
  
  loadChromosomes();
  loadReadPairs();
  addReadPairsToChromosomes();

  chr1 = (Chromosome) chromosomes.get(chr_number_1);
  chr2 = (Chromosome) chromosomes.get(chr_number_2);

  strokeCap(SQUARE);

  smooth();
  noLoop();

  drawStaticParts();
}

void drawStaticParts() {
  textFont(font);

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

  // First all the static stuff
  image(img_qualcutoffslider, WIDTH/2, 0);
  image(img_circular, 0, 0);
  image(img_linear_top, 0, HEIGHT/2);
  image(img_linear_bottom, 0, 3*HEIGHT/4);
  
  // Highlight readpairs
  translate(WIDTH/4, HEIGHT/4);
  drawHighlightedReadPairs();
  translate(-WIDTH/4, -HEIGHT/4);

  drawLinearInterchromosomal(); 

  // Draw quality score cutoff
  float y_qual_cutoff = map(qual_cutoff, 0, 40, HEIGHT/2 - 95, HEIGHT/2 - 55);
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(WIDTH/2 + 55, y_qual_cutoff, WIDTH/2 + 65, y_qual_cutoff);
  text(qual_cutoff, WIDTH/2 + 55, HEIGHT/2 - 20);

}

void drawLinearInterchromosomal() {
  stroke(0);
  strokeWeight(0.5);
  noFill();

  Chromosome chr = ( Chromosome ) chromosomes.get(chr_number_1);
  ReadPair[] inter = ( ReadPair[] ) chr.interchromosomal_read_pairs.get(chr_number_2);
  if ( inter != null ) {
    for ( int i = 0; i < inter.length; i++ ) {
      if ( inter[i].activated ) {
        stroke(255,0,0);
      } else {
        stroke(0);
      }
      bezier(inter[i].linear_x1, 375, inter[i].linear_x1, 425, inter[i].linear_x2, 475, inter[i].linear_x2, 525);
    }
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
  buffer_circular.strokeWeight(0.1);
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
