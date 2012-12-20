class Donut {
  
  int size;
  
  Donut() {
    size = 200;
  }
  
  int size() { return size; }
  
  void draw() {
    ellipseMode(CENTER);
    noStroke();
    fill(color(0, 0, 255, mousePressed ? 100 : 50));
    smooth();
    ellipse(mouseX, mouseY, size, size);
  }
}
