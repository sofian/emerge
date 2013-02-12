// ******************************************************************
// This class represent an environment, as observable by an agent.
// ******************************************************************
class QualiaOscMunchkin extends Munchkin
{
  float fx;
  float fy;
  //float xHeat;
  //float yHeat;
  //float xSize;
  //float ySize;  
  float xClosest;
  float yClosest;
  float distClosest;
  //float heatClosest;
  float sizeClosest;
  boolean hasClosest = false;
  boolean hasEaten = false;
  boolean wasEaten = false;
  
  // ============================================
  // Constructors
  // ============================================
  QualiaOscMunchkin(int nation, float x, float y, float size, float heat)
  {
    super(nation, x, y, size, heat);
  }

  QualiaOscMunchkin(int nation, float x, float y, float size)
  {
    super(nation, x, y, size);
  }
  
  QualiaOscMunchkin(int nation, float x, float y)
  {
    super(nation, x, y);
  }

  // ============================================
  // Member functions
  // ============================================ 
  void move(World world) 
  {
    // IMPORTANT: KEEP THESE LINES AS IS: THERE IS AN ISSUE WITH THE FORCES GETTING TO NAN IN SOME UNKNOWN CIRCUMSTANCES; THIS FIXES IT
    if (Double.isNaN(getForceX()) || Double.isNaN(getForceY()))
    {
      resetForces();
    }

    float heatFactor = getHeat() * getHeat() * 10;
    //print("FX FY : " + fx + " " + fy + " " + + heatFactor);
    fx *= heatFactor;
    fy *= heatFactor;
    //println("  --- > " + fx + " " + fy);
    addForce(fx, fy);
    //println(this);
    float forceStrength = sqrt(fx*fx + fy*fy);
    setHeat(getHeat() - constrain(forceStrength, 0.0f, 1.0f) * HEAT_DECREASE_ON_ACTION);
    resetMoveForce();
  }
  
  void step(World world) {
    hasEaten = wasEaten = false;
    super.step(world);
    
    float observationRadius = MUNCHKIN_OBSERVATION_RADIUS_FACTOR * getActionRadius();
    Vector<Thing> neighbors = getNeighbors(world, observationRadius);
    
    if (neighbors.size() == 0)
    {
      hasClosest = false;
      xClosest = (random(1.) < 0.5 ? -1 : +1) * observationRadius;
      yClosest = (random(1.) < 0.5 ? -1 : +1) * observationRadius;
      distClosest = 9999;
      /*heatClosest = */sizeClosest = 0;
    }
    else
    {
      hasClosest = true;
      distClosest = 9999;
      for (Thing t : neighbors)
      {
        float d = distance(x(), y(), t.x(), t.y());
        if (d < distClosest)
        {
          distClosest = d;
          xClosest = t.x() - x();
          yClosest = t.y() - y();
          sizeClosest = t.size();
          //heatClosest = t.getHeat();
        }
      }
    }

/*
    xHeat = 0;
    yHeat = 0;
    xSize = 0;
    ySize = 0;
    for (Thing t : neighbors) {
      float xdiff = map(x() - t.x(), -observationRadius, observationRadius, -1., +1.);
      float ydiff = map(y() - t.y(), -observationRadius, observationRadius, -1., +1.);
      float d = distance(x(), y(), t.x(), t.y());
      float power = 1-d; // closest are stronger
      xHeat += xdiff * t.getHeat();
      yHeat += ydist * t.getHeat();
      xSize += xdist * t.size();
      ySize += ydist * t.size();
    }
    */
    
    // Increase size every now and then.
    if (random(0.0, 1.0) <  0.1f / (size() * size() + 1))
    {
      setSize(size()+1);
    }
  }
  
  void resetMoveForce()
  {
    this.fx = this.fy = 0;
  }
  
  void addMoveForce(float fx, float fy)
  {
    this.fx += fx * ACTION_FORCE_FACTOR;
    this.fy += fy * ACTION_FORCE_FACTOR;
  }
  
  // ============================================
  // Setters & getters
  // ============================================  
  float getReward() {
    float baseReward = 0;
    
    // Absolute localization: try to avoid borders and occupy center ///////////////////////////////////////////////////////
    
    // Avoid borders at all costs
    int tooCloseToBorder = max(width/10, 10);
    if (x() < tooCloseToBorder || x() >= width-tooCloseToBorder || y() < tooCloseToBorder || y() >= height-tooCloseToBorder) {
      baseReward -= 10; // bad, very bad!
    }

    float distCenter = distance(x(), y(), width/2, height/2); // distance to center
    float dist01     = distance(x(), y(), width/2, height/2) / (width/2); // distance to center remapped to 01
    
    // Stay close to center.
    if (dist01 > 0.5)
      baseReward -= ( 0.1 + dist01);
    else
      baseReward += +(1 - dist01);
    
    // Center zone is delightful.
    if (distCenter < 2*tooCloseToBorder)
      baseReward += 1.0f;
      
    float normalizedDistClosest = (hasClosest ? distClosest / (float)width : 1.0);
    println(normalizedDistClosest + " " + baseReward);
    
    switch (nation) {

      // Cuddlers.
      case Thing.RED:
        return baseReward - normalizedDistClosest;
      
      // Normal.
      case Thing.GREEN:
        return baseReward - abs(normalizedDistClosest - 0.1);

      // Loners.
      case Thing.BLUE:
        return baseReward / 10 + normalizedDistClosest; // less influenced by wanting to stay in the center

      // Agressive.
      case Thing.YELLOW:
        return baseReward ;

      default:
        println("Wrong nation: " + nation);
        exit();
        return 0;
    }
  }
  
  float[] getObservation() {
    float[] obs = new float[] {

      map(x(), 0.0f, (float)width, -1., 1.),
      map(y(), 0.0f, (float)height, -1., 1.),
      getVelocityX() /100,
      getVelocityY() /100,
      
      hasClosest ? 1.0f : 0.0f,
      xClosest / (float)width,
      yClosest / (float)height,
      distClosest / (float)width,
      sizeClosest / 30,
      size() / 30,
/*      size()/30,
      getHeat(),
      xClosest,
      yClosest,
      heatClosest,
      sizeClosest/30,*/

      getReward()
    };
    if (obs.length-1 != OBSERVATION_DIM)
    {
      println("Wrong number of observations: " + obs.length);
      exit();
    }      
    return obs;
  }
 
  // Extra methods.
  Munchkin split()
  {
    float newSize = floor(size()/2);
    float newHeat = getHeat() / 2 - HEAT_DECREASE_ON_ACTION;
    float angle = random(0, 2*PI);
    int xInc = (int) (cos(angle)*newSize/2);
    int yInc = (int) (sin(angle)*newSize/2);
    xInc = min(xInc, 1);
    yInc = min(yInc, 1);
    //print("SPLIT: " + xInc + "," + yInc);
    addForce( xInc*100, yInc*100 );
    //println(" --> " + getForceX() + "," + getForceY());
    setHeat(newHeat);
    setSize(newSize);
    return null;
  }  
}
