class Munchkin implements Comparable<Munchkin> {
  int x, y;
  int vx, vy; // speed
  int size;
  // later Nation nation;
  
  Munchkin(int x, int y, int size) {
    this.x = x;
    this.y = y;
    this.size = size;
    vx = 0;
    vy = 0;
    _constrain();
  }
  
  Munchkin(int x, int y) {
    this(x, y, 1);
  }

  public int compareTo(Munchkin o) {
    return (size - o.size);
  }
  
  void _constrain() {
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
  }
  
  void step(World world)
  {
    // Move.
    if ((int)random(30) == 0) {
      vx += round(random(-1,1));
      vy += round(random(-1,1));
    }
    
    x += vx;
    y += vy;
    
    vx -= 0.05*vx;
    vy -= 0.05*vy;
    
    x += random(-1,2);
    y += random(-1,2);
    
    _constrain();
  }
  
  Munchkin split() {
    float angle = random(0, 2*PI);
    int newSize = size/2;
    int xInc = (int) (cos(angle)*size*2);
    int yInc = (int) (sin(angle)*size*2);
    Munchkin kid = new Munchkin(x-xInc, y-yInc, newSize);
    x += xInc;
    y += yInc;
    size = newSize;
    _constrain();
    return kid;
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
