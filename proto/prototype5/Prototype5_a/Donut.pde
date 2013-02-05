// ******************************************************************
// This class represents a user-controlled agent, aka a donut.
// ******************************************************************
class Donut
{  
  int ID;
  int size;
  int posX;
  int posY;
  
  // ============================================
  // Constructor
  // ============================================
  Donut(int id)
  {
    ID = id;
    size = 100;
    // Initialize the position outside the range of this world
    posX = -200;
    posY = -200;
  }
  
  // ============================================
  // Setters & getters
  // ============================================  
  int size() { return size; }
  
  void setPosition(int x, int y)
  {
    posX = x;
    posY = y;
  }
  
  // ============================================
  // Member functions
  // ============================================ 
  void draw()
  {
    ellipseMode(CENTER);
    noStroke();
    fill(color(0, 0, 255, cursorAction ? 100 : 50));
    smooth();
    ellipse(posX, posY, size, size);
  }
}
