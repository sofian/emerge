class Munchkin implements Comparable<Munchkin> {
  
  static final int RED   = #ff0000;
  static final int GREEN = #00dd00;
  static final int BLUE  = #9999ff;
  
  int nation;
  float x, y;
  float vx, vy; // speed
  int size;
  
  Munchkin(int nation, int x, int y, int size) {
    this.nation = nation;
    this.x = x;
    this.y = y;
    this.size = size;
    vx = 0;
    vy = 0;
    _constrain();
  }
  
  Munchkin(int nation, int x, int y) {
    this(nation, x, y, 1);
  }

  public int compareTo(Munchkin o) {
    return (size - o.size);
  }
  
  boolean isPredatorOf(Munchkin m) {
    return ((nation == RED && m.nation == GREEN) ||
            (nation == GREEN && m.nation == BLUE) ||
            (nation == BLUE && m.nation == RED));
  }
  
  void _constrain() {
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
  }
  
  void step(World world)
  {
    // Move.
    if ((int)random(30) == 0) {
      vx = round(random(-1.0,1.0));
      vy = round(random(-1.0,1.0));
    }
    
    x += vx;
    y += vy;
    
    vx -= 0.01*vx;
    vy -= 0.01*vy;
    
    x += random(-1,1);
    y += random(-1,1);
    
    _constrain();
  }
  
  Munchkin split() {
    float angle = random(0, 2*PI);
    int newSize = size/2;
    int xInc = (int) (cos(angle)*size*2);
    int yInc = (int) (sin(angle)*size*2);
    Munchkin kid = new Munchkin(nation, (int)(x-xInc), (int)(y-yInc), newSize);
    x += xInc;
    y += yInc;
    size = newSize;
    _constrain();
    return kid;
  }

  void draw() {
    ellipseMode(CENTER);
    noStroke();
    fill(nation);
    stroke(nation);
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
