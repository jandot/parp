class Label {
  int x1;
  int y1;
  int x2;
  int y2;
  int label;
  
  Label(int x1, int y1, int dx, int dy, int label) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = this.x1 + dx;
    this.y2 = this.y1 + dy;
    this.label = label;
  }
}
