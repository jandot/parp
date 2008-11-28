String INPUT_FILE = "data.tsv";

Hashtable chromosomes = new Hashtable();
Hashtable read_pairs = new Hashtable();

int GENOME_SIZE = 3080419; // in kb
int WIDTH = 1200;
int HEIGHT = 600;
float DIAMETER = 3*HEIGHT/8;
float RADIUS = DIAMETER/2;

int qual_cutoff = 0;

int read_pair_counter = 0;

PGraphics buffer_circular;
PImage img_circular;
PGraphics buffer_linear_panel;
PImage img_linear_panel;
PGraphics buffer_qualcutoffslider;
PImage img_qualcutoffslider;

//ReadPair[] top_chromosome_intrachromosomal_read_pairs;
//ReadPair[] bottom_chromosome_intrachromosomal_read_pairs;

PFont font;

int active_panel = 0; // 1 = circular panel; 2 = top linear; 3 = bottom linear

LinearPanel linearPanel;

Label[] chromosome_labels = new Label[0];

int chr_number_1 = 1;
int chr_number_2 = 2;

Chromosome chr1;
Chromosome chr2;

void setup() {
  size(WIDTH, HEIGHT);
  
  font = createFont("SansSerif", 16);
  
  loadChromosomes();
  loadReadPairs();
//  addReadPairsToChromosomes();

  chr1 = (Chromosome) chromosomes.get(chr_number_1);
  chr2 = (Chromosome) chromosomes.get(chr_number_2);
  linearPanel = new LinearPanel(chr_number_1, chr_number_2);

  strokeCap(SQUARE);

  smooth();
  noLoop();

  drawStaticParts();
}

void draw() {
  background(255);

  // First all the static stuff
  image(img_qualcutoffslider, WIDTH/2, 0);
  image(img_circular, 0, 0);
  image(img_linear_panel, 0, HEIGHT/2);
  
  // Highlight readpairs
  translate(WIDTH/4, HEIGHT/4);
  drawCircularHighlightedReadPairs();
  translate(-WIDTH/4, -HEIGHT/4);

  drawLinearHighlightedReadPairs();

  // Draw quality score cutoff
  float y_qual_cutoff = map(qual_cutoff, 0, 40, HEIGHT/2 - 95, HEIGHT/2 - 55);
  stroke(0);
  strokeWeight(2);
  fill(0);
  line(WIDTH/2 + 55, y_qual_cutoff, WIDTH/2 + 65, y_qual_cutoff);
  text(qual_cutoff, WIDTH/2 + 55, HEIGHT/2 - 20);
}
