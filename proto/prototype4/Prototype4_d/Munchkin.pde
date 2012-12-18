class Munchkin extends Thing {
  
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

  // Implement abstract methods.
  int getNation() { return nation; }

  int size() { return this.size; }
  int x() { return (int)this.x; }
  int y() { return (int)this.y; }
  
  void eat(Thing o) {
    size++;
    if (o instanceof Munchkin)
      ((Munchkin)o).size--;
    else {
      // Eat max.
      int n = ((Donut)o).getMaxNationEaten();
      ((Donut)o).nEaten[n] = max(((Donut)o).nEaten[n] - 1, 0);
    }
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
  
  void draw() {
    ellipseMode(CENTER);
    noStroke();
    fill(getColor());
    stroke(getColor());
    if (size == 0)
      println("This thing should be dead.");
    else if (size == 1) {
      noSmooth();
      point(x, y);
    } else {
      smooth();
      ellipse(x, y, size, size);
    }
  }

  // Extra methods.
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

  void _constrain() {
    x = constrain(x, 0, width);
    y = constrain(y, 0, height);
  }
 
}
