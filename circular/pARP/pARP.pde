import java.text.NumberFormat;

String INPUT_FILE = "data.tsv";

NumberFormat formatter = new DecimalFormat(",###");

Hashtable chromosomes = new Hashtable();
Hashtable read_pairs = new Hashtable();

long GENOME_SIZE = 3080419000L;
int WIDTH = 1200;
int HEIGHT = 600;
float DIAMETER = 3*HEIGHT/8;
float RADIUS = DIAMETER/2;

int qual_cutoff = 0;
float max_qual;

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
  
  font = createFont("SansSerif", 12);
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

  // Draw vertical green line
  if ( active_panel == 2 || active_panel == 3 ) {
    noFill();
    strokeWeight(2);
    stroke(0,255,0,50);
    line(mouseX, HEIGHT/2 + linearPanel.top_chromosome.line_y - 50, mouseX, HEIGHT/2 + linearPanel.bottom_chromosome.line_y + 50);
    
    // Draw green line on ideogram
    strokeWeight(2);
    stroke(0,255,0,200);
    float ideogram_line_x = map(mouseX, 0, width, linearPanel.top_chromosome.zoom_box_ideogram_x1, linearPanel.top_chromosome.zoom_box_ideogram_x2);
    line(ideogram_line_x, HEIGHT/2 + linearPanel.top_chromosome.ideogram_y1 - 2, ideogram_line_x, HEIGHT/2 + linearPanel.top_chromosome.ideogram_y1 + linearPanel.top_chromosome.ideogram.height + 4);
    ideogram_line_x = map(mouseX, 0, width, linearPanel.bottom_chromosome.zoom_box_ideogram_x1, linearPanel.bottom_chromosome.zoom_box_ideogram_x2);
    line(ideogram_line_x, HEIGHT/2 + linearPanel.bottom_chromosome.ideogram_y1 - 2, ideogram_line_x, HEIGHT/2 + linearPanel.bottom_chromosome.ideogram_y1 + linearPanel.bottom_chromosome.ideogram.height + 4);
  }

  // Show current quality score cutoff
  fill(0);
  text("Quality score cutoff: " + qual_cutoff, WIDTH/2, 50);
}
