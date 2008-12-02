String INPUT_FILE = "data.tsv";

Hashtable chromosomes = new Hashtable();
Hashtable read_pairs = new Hashtable();

long GENOME_SIZE = 3080419000L;
int WIDTH = 1200;
int HEIGHT = 600;
float DIAMETER = 3*HEIGHT/8;
float RADIUS = DIAMETER/2;

int qual_cutoff = 0;

int read_pair_counter = 0;

PGraphics buffer_circular_all;
PImage img_circular_all;
PGraphics buffer_circular_highlighted;
PImage img_circular_highlighted;
PGraphics buffer_linear_ideograms;
PImage img_linear_ideograms;
PGraphics buffer_linear_zoom;
PImage img_linear_zoom;
PGraphics buffer_linear_highlighted;
PImage img_linear_highlighted;

PGraphics buffer_linear_panel;
PImage img_linear_panel;
PGraphics buffer_qualcutoffslider;
PImage img_qualcutoffslider;

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
  textFont(font);
  
  loadChromosomes();
  loadReadPairs();

  chr1 = (Chromosome) chromosomes.get(chr_number_1);
  chr2 = (Chromosome) chromosomes.get(chr_number_2);
  linearPanel = new LinearPanel(chr_number_1, chr_number_2);

  strokeCap(SQUARE);

  smooth();
  noLoop();

  drawInitialBuffers();
}

void drawInitialBuffers() {
  drawBufferCircularAll();
  drawBufferCircularHighlighted();
  drawBufferLinearIdeograms();
  drawBufferLinearZoom();
  drawBufferLinearHighlighted();
}

void draw() {
  background(255);

  image(img_circular_highlighted, 0, 0);
  translate(0,HEIGHT/2);
  image(img_linear_highlighted,0,0);
  
  translate(0,-HEIGHT/2);
  
  fill(0);
  text(mouseX + ";" + mouseY, width-100, 50);
  
  if ( active_panel == 2 ) {
    float bp_position = map(mouseX, 0, width, linearPanel.top_chromosome.left_border/1000000, (linearPanel.top_chromosome.left_border + linearPanel.top_chromosome.area)/1000000);//20.00, 32.00);
    text("Basepair position: " + bp_position + " Mb", width/2, 20);
  } else if ( active_panel == 3 ) {
    float bp_position = map(mouseX, 0, width, linearPanel.bottom_chromosome.left_border/1000000, (linearPanel.bottom_chromosome.left_border + linearPanel.bottom_chromosome.area)/1000000);//20.00, 32.00);
    text("Basepair position: " + bp_position + " Mb", width/2, 20);
  }
}
