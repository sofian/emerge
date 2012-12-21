class Donut {
  
  int size;
  
  Donut() {
    size = 200;
  }
  
  int size() { return size; }
  
  void draw() {
    ellipseMode(CENTER);
    noStroke();
    fill(color(0, 0, 255, cursorAction ? 100 : 50));
    smooth();
    ellipse(cursorX, cursorY, size, size);
  }
}
