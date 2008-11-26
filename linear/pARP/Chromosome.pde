class Chromosome {
  int number;
  float len;
  int centr;
  
  Chromosome(int number, int len, int centr_start, int centr_stop) {
    this.number = number;
    this.len = len;
    this.centr = (centr_start + centr_stop)/2;
  }
}
