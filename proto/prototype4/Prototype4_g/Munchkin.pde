class Munchkin extends Thing {
  
  int nation;
//  float x, y;
//  float vx, vy; // speed
  int size;
  
  Munchkin(int nation, float x, float y, float size) {
    super(x, y, size);
    this.nation = nation;
    setFillColor(getColor());
  }
  
  Munchkin(int nation, float x, float y) {
    this(nation, x, y, 1);
  }

  // Implement abstract methods.
  int getNation() { return nation; }

//  int size() { return this.size; }
//  int x() { return (int)this.x; }
//  int y() { return (int)this.y; }
  
  void eat(Thing o) {
    if (!o.isDead()) {
      setSize(getSize() + 1);
      o.setSize(o.getSize() - 1);
    }
  }

  void step(World world)
  {
    resetForces();
    
    Vector<Thing> neighbors = world.getThingsInArea(x(), y(), getActionRadius());
    //println("N n.: " + neighbors.size());
    for (Thing n : neighbors) {
      if (n == this) continue;
      
      float d = distance(x(), y(), n.x(), n.y());
      
      if (d < size() && n.size() <= size())
        eat(n);
      
      float g = (size() + n.size()) / (d*d) * 1000; // gravitation force
      //println(d + " " + g + " " + (n.x() - x()) / d * g);
      addForce( (n.x() - x()) / d * g, (n.y() - y()) / d * g );
    }
    
    // Move.
    float RANDOM_FORCE_STRENGTH = 100.0f;
    addForce( random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH), random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH) );
  }

  // Extra methods.
  Munchkin split() {
    float angle = random(0, 2*PI);
    float newSize = floor(size()/2);
    int xInc = (int) (cos(angle)*newSize/2);
    int yInc = (int) (sin(angle)*newSize/2);
    Munchkin kid = new Munchkin(nation, constrain(x(), 10, width-10), constrain(y(), 10, height-10), newSize);
//    Munchkin kid = new Munchkin(nation, width/2, height/2, 10);
    //setVelocity(0, 0);
    //setPosition(x()+xInc, y()+yInc);
    setSize(newSize);
    addForce( xInc*1000, yInc*1000 );
    kid.addForce( -xInc*1000, -yInc*1000 );
    return kid;
  }

  /*
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
  }*/

  // Extra methods.
  /*
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
  }*/

 
}
