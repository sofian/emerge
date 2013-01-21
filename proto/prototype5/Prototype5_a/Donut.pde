class Donut {
  
  int ID;
  int size;
  int posX;
  int posY;
  
  Donut(int id) {
    ID = id;
    size = 100;
    // Initialize the position outside the range of this world
    posX = -200;
    posY = -200;
  }
  
  int size() { return size; }
  
  void setPosition(int x, int y) {
    posX = x;
    posY = y;
  }
      
  void draw() {
    ellipseMode(CENTER);
    noStroke();
    fill(color(0, 0, 255, cursorAction ? 100 : 50));
    smooth();
    ellipse(posX, posY, size, size);
  }
}
