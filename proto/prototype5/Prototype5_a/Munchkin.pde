// ******************************************************************
// This class represent a reinforcement learning agent, aka a munchkin.
// ******************************************************************
class Munchkin extends Thing
{
  int nation;
  int size;
  
  // ============================================
  // Constructors
  // ============================================
  Munchkin(int nation, float x, float y, float size, float heat)
  {
    super(nation, x, y, size, heat);
    this.nation = nation;
    setFillColor(getColor());
  }

  Munchkin(int nation, float x, float y, float size)
  {
    this(nation, x, y, size, 0.5f);
  }
  
  Munchkin(int nation, float x, float y)
  {
    this(nation, x, y, 1, 0.5f);
  }
  
  // ============================================
  // Setters & getters
  // ============================================  
  // Implement abstract methods.
  int getNation() { return nation; }
  
  int getColor()
  {
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
  
  Vector<Thing> getNeighbors(Booth booth, float radius)
  {
    Vector<Thing> things =  booth.getThingsInArea(x(), y(), radius);
//    try {
//    things.removeElement(this);
//    } catch (NoSuchElementException e) {}
    return things;
  }
  
  // ============================================
  // Member functions
  // ============================================ 
  void eat(Thing o)
  {
    if (!o.isDead())
    {
      // Size transfer.
      setSize(getSize() + 1);
      o.setSize(o.getSize() - 1);
      // Heat transfer.
      float heatTransfer = min(o.getHeat(), HEAT_ON_EAT);
      setHeat(getHeat() + heatTransfer - HEAT_DECREASE_ON_ACTION);
      o.setHeat(o.getHeat() - heatTransfer);
    }
  }
  
  void move(Booth booth)
  {
    // Move.
    float RANDOM_FORCE_STRENGTH = getHeat() * 100.0f;
    float fx = random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH);
    float fy = random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH);
    addForce( fx, fy );
    float forceStrength = sqrt(fx*fx + fy*fy);
    setHeat(getHeat() - constrain(forceStrength, 0.0f, 1.0f) * HEAT_DECREASE_ON_ACTION);
  }

  void step(Booth booth)
  {
    resetForces();    
    Vector<Thing> neighbors = getNeighbors(booth, getActionRadius());

    float neighborsStrength = 0;
    for (Thing n : neighbors)
    {
      if (n == this) continue;
      neighborsStrength += n.size();

      float d = distance(x(), y(), n.x(), n.y());
      
      float g = (size() + n.size()) / (d*d+0.0000001f) * 1000; // gravitation force
      //println(d + " " + g + " " + (n.x() - x()) / d * g);
      addForce( (n.x() - x()) / d * g, (n.y() - y()) / d * g );
    }
    
    if (neighborsStrength > size())
    { // they eat me!
      neighborsStrength -= size();
      Iterator<Thing> it = neighbors.iterator();
      while (it.hasNext() && neighborsStrength > 0)
      {
        Thing n = it.next();
        neighborsStrength -= n.size();
        n.eat(this);
      }
    }
    else
    {
      eat(neighbors.firstElement());
    }
    
    move(booth);
  }

  // Extra methods.
  Munchkin split()
  {
    float angle = random(0, 2*PI);
    float newSize = floor(size()/2);
    int xInc = (int) (cos(angle)*newSize/2);
    int yInc = (int) (sin(angle)*newSize/2);
    xInc = min(xInc, 1);
    yInc = min(yInc, 1);
    float newHeat = getHeat() / 2 - HEAT_DECREASE_ON_ACTION;
    setHeat(newHeat);
    setSize(newSize);
    Munchkin kid = new Munchkin(nation, constrain(x(), 10, width-10), constrain(y(), 10, height-10), newSize, newHeat);
    println("FUCK!!!");
    addForce( xInc*2000, yInc*2000 );
    kid.addForce( -xInc*2000, -yInc*2000 );
    return kid;
  }

  /*
  void draw()
  {
    ellipseMode(CENTER);
    noStroke();
    fill(getColor());
    stroke(getColor());
    if (size == 0)
    {
      println("This thing should be dead.");
    }
    else if (size == 1)
    {
      noSmooth();
      point(x, y);
    }
    else
    {
      smooth();
      ellipse(x, y, size, size);
    }
  }*/

  // Extra methods.
  /*
  Munchkin split()
  {
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
