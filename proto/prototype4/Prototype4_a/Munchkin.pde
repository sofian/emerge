class Munchkin implements Comparable<Munchkin> {
  int x, y;
  int size;
  // later Nation nation;
  
  Munchkin(int x, int y) {
    this.x = x;
    this.y = y;
    this.size = 1;
  }
  
  public int compareTo(Munchkin o) {
    return (size - o.size);
  }
  
  void step(World world)
  {
    // Move.
    x += random(-1,2);
    y += random(-1,2);
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
  }

  void draw() {
    ellipseMode(CENTER);
    noStroke();
    fill(#ff4500);
    stroke(#ff4500);
    if (size == 0)
      return;
    else if (size == 1) {
      noSmooth();
      point(x, y);
    } else {
      smooth();
      ellipse(x, y, size, size);
    }
  }
}
