class Munchkin extends Thing {
  
  int nation;
  int size;
  
  Munchkin(int nation, float x, float y, float size, float heat) {
    super(x, y, size, heat);
    this.nation = nation;
    setFillColor(getColor());
  }

  Munchkin(int nation, float x, float y, float size) {
    this(nation, x, y, size, 0.5f);
  }
  
  Munchkin(int nation, float x, float y) {
    this(nation, x, y, 1, 0.5f);
  }

  // Implement abstract methods.
  int getNation() { return nation; }
  
  int getColor() {
    float h = getHeat();
    colorMode(RGB);
    int high = #ff0000;
    int low  = #0000ff;
    float colorHue = h * (float)hue(high) + (1-h) * (float)hue(low);
    //println("HUE: " + colorHue);
    colorMode(HSB);
    int col = color((int)colorHue, 255, 255);
    colorMode(RGB);
    return col;
  }

//  int size() { return this.size; }
//  int x() { return (int)this.x; }
//  int y() { return (int)this.y; }
  
  void eat(Thing o) {
    if (!o.isDead()) {
      // Size transfer.
      setSize(getSize() + 1);
      o.setSize(o.getSize() - 1);
      // Heat transfer.
      float heatTransfer = min(o.getHeat(), HEAT_ON_EAT);
      setHeat(getHeat() + heatTransfer - HEAT_DECREASE_ON_ACTION);
      o.setHeat(o.getHeat() - heatTransfer);
    }
  }

  void step(World world)
  {
    resetForces();
    
    Vector<Thing> neighbors = world.getThingsInArea(x(), y(), getActionRadius());

    float neighborsStrength = 0;
    for (Thing n : neighbors) {
      if (n == this) continue;
      neighborsStrength += n.size();

      float d = distance(x(), y(), n.x(), n.y());
      
      float g = (size() + n.size()) / (d*d+0.0000001f) * 1000; // gravitation force
      //println(d + " " + g + " " + (n.x() - x()) / d * g);
      addForce( (n.x() - x()) / d * g, (n.y() - y()) / d * g );
    }
    
    if (neighborsStrength > size()) { // they eat me!
      neighborsStrength -= size();
      Iterator<Thing> it = neighbors.iterator();
      while (it.hasNext() && neighborsStrength > 0) {
        Thing n = it.next();
        neighborsStrength -= n.size();
        n.eat(this);
      }
    }
    else
      eat(neighbors.firstElement());
      
    // Move.
    float RANDOM_FORCE_STRENGTH = getHeat() * 100.0f;
    addForce( random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH), random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH) );
    float forceStrength = abs(getForceX()) + abs(getForceY());
    setHeat(getHeat() - constrain(forceStrength, 0.0f, 1.0f) * HEAT_DECREASE_ON_ACTION);
  }

  // Extra methods.
  Munchkin split() {
    float angle = random(0, 2*PI);
    float newSize = floor(size()/2);
    int xInc = (int) (cos(angle)*newSize/2);
    int yInc = (int) (sin(angle)*newSize/2);
    float newHeat = getHeat() / 2 - HEAT_DECREASE_ON_ACTION;
    Munchkin kid = new Munchkin(nation, constrain(x(), 10, width-10), constrain(y(), 10, height-10), newSize, newHeat);
    setHeat(newHeat);
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
