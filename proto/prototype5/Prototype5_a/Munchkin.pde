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

    setDamping(MUNCHKIN_DAMPING);
    setRestitution(MUNCHKIN_RESTITUTION);
    setDensity(MUNCHKIN_DENSITY);
    setFriction(MUNCHKIN_FRICTION);
    
//    setDamping(BOT_DAMPING);
//    setAngularDamping(BOT_ANGULAR_DAMPING);
//    setFriction(10.0f);
    setFillColor(getColor());
    setNoStroke();
//    setRotatable(true);
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
  
  Vector<Thing> getNeighbors(World world, float radius)
  {
    Vector<Thing> things =  world.getThingsInArea(x(), y(), radius);
    if (things.contains(this)) {
      try {
      things.removeElement(this);
      } catch (NoSuchElementException e) {}
    }
    return things;
  }
  
  // ============================================
  // Member functions
  // ============================================ 
  void move(World world) {
    // Move.
    float RANDOM_FORCE_STRENGTH = getHeat() * 100.0f;
    float fx = random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH);
    float fy = random(-RANDOM_FORCE_STRENGTH,RANDOM_FORCE_STRENGTH);
    addForce( fx, fy );
    float forceStrength = sqrt(fx*fx + fy*fy);
    setHeat(getHeat() - constrain(forceStrength, 0.0f, 1.0f) * HEAT_DECREASE_ON_ACTION);
  }

  void step(World world)
  {
    resetForces();
    
    Vector<Thing> neighbors = getNeighbors(world, MUNCHKIN_ATTRACTION_RADIUS);

    float neighborsStrength = 0;
    for (Thing n : neighbors)
    {
      if (n == this) continue;
      neighborsStrength += n.size();

      float d = distance(x(), y(), n.x(), n.y());
      
      float g = (getMass() * n.getMass()) / (d*d + 1e-10f) * MUNCHKIN_ATTRACTION_FACTOR; // gravitation force
      addForce( (n.x() - x()) * g, (n.y() - y()) * g );
    }
    
    if (neighborsStrength > size())
    { // they eat me!
      neighborsStrength -= size();
      Iterator<Thing> it = neighbors.iterator();
      while (it.hasNext() && neighborsStrength > 0)
      {
        Thing n = it.next();
        neighborsStrength -= n.size();
      }
    }
    else
    {
//      eat(neighbors.firstElement());
    }
    
    move(world);
  }
  
  void explode() {
    float newSize = floor(size()/2);
    if (newSize > MUNCHKIN_MIN_SIZE)
      newSize = random(MUNCHKIN_MIN_SIZE, newSize);
    float angle = random(0, 2*PI);
    int xInc = (int) (cos(angle)*newSize/2);
    int yInc = (int) (sin(angle)*newSize/2);
    xInc = min(xInc, 1);
    yInc = min(yInc, 1);
    //print("SPLIT: " + xInc + "," + yInc);
    addForce( xInc*1000, yInc*1000 );
    //println(" --> " + getForceX() + "," + getForceY());
    //setHeat(newHeat);
    setSize(newSize);
  }
 
}
