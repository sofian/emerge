class QualiaOscMunchkin extends Munchkin {

  float fx;
  float fy;
  
  float xHeat;
  float yHeat;
  float xSize;
  float ySize;
  
  float xClosest;
  float yClosest;
  float heatClosest;
  float sizeClosest;
  boolean hasClosest = false;
  
  boolean hasEaten = false;
  boolean wasEaten = false;
  
  QualiaOscMunchkin(int nation, float x, float y, float size, float heat) {
    super(nation, x, y, size, heat);
  }

  QualiaOscMunchkin(int nation, float x, float y, float size) {
    super(nation, x, y, size);
  }
  
  QualiaOscMunchkin(int nation, float x, float y) {
    super(nation, x, y);
  }

  void move(World world) {
    // IMPORTANT: KEEP THESE LINES AS IS: THERE IS AN ISSUE WITH THE FORCES GETTING TO NAN IN SOME UNKNOWN CIRCUMSTANCES; THIS FIXES IT
    if (Double.isNaN(getForceX()) || Double.isNaN(getForceY()))
      resetForces();

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
    
    float observationRadius = 4 * getActionRadius();
    Vector<Thing> neighbors = getNeighbors(world, observationRadius);
    
    if (neighbors.size() == 0) {
      hasClosest = false;
      xClosest = (random(1.) < 0.5 ? -1 : +1) * observationRadius;
      yClosest = (random(1.) < 0.5 ? -1 : +1) * observationRadius;
      heatClosest = sizeClosest = 0;
    } else {
      hasClosest = true;
      float dMin = 9999;
      for (Thing t : neighbors) {
        float d = distance(x(), y(), t.x(), t.y());
        if (d < dMin) {
          d = dMin;
          xClosest = t.x() - x();
          yClosest = t.y() - y();
          sizeClosest = t.size();
          heatClosest = t.getHeat();
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
    if (random(0.0, 1.0) < 0.1f/(size()*size()+1))
      setSize(size()+1);
  }
  
  void resetMoveForce() {
    this.fx = this.fy = 0;
  }
  
  void addMoveForce(float fx, float fy) {
    this.fx += fx * ACTION_FORCE_FACTOR;
    this.fy += fy * ACTION_FORCE_FACTOR;
  }
  
  float getReward() {
    float baseReward = 0;
    
    if (x() < 10 || x() >= width-10 || y() < 10 || y() >= height-10)
      baseReward -= 100; // bad, very bad!

    float distCenter = distance(x(), y(), width/2, height/2); // distance to center
    float dist01 = distance(x(), y(), width/2, height/2) / (width/2); // distance to center remapped to 01
    
    if (dist01 > 0.5)
      baseReward += -(1+10*dist01);
    else
      baseReward += +10*(1-dist01);
                       
    if (nation == Thing.RED)
      return baseReward;
      else if (nation == Thing.BLUE)
      return -baseReward;
      
    switch (nation) {

      // Predators.
      case Thing.RED:
        return baseReward
               + (hasClosest ? size() - sizeClosest : -10)  // happy to be close to a smaller sized munchkin
               + 10*(hasEaten ? 1+getSize() : 0);           // happy when it eats
//        return baseReward + getSize() + (xHeat*xHeat + yHeat*yHeat) + (hasEaten ? 100 : 0); // predators
      
      // Preys.
      case Thing.BLUE:
        return baseReward 
               + (hasClosest ? -sizeClosest : 10)           // unhappy to be close to munchkin, especially big ones / happy to be alone
               + (wasEaten ? -100 : 0);                     // unhappy when eaten
//        return baseReward - (getSize() < 2 ? 100 : 0) - sqrt(xSize*xSize + ySize*ySize) + (wasEaten ? -100 : 0); // preys

      default:
        return baseReward 
               + 10*getHeat()
               + getSize()
               + abs(getVelocityX()) + abs(getVelocityY()); // like to move
//            + (xHeat*xHeat + yHeat*yHeat) // attracted by heat
//            - sqrt(xSize*xSize + ySize*ySize); // repelled by size
    }
  }
  
  float[] getObservation() {
    return new float[] {
      x()/width,
      y()/height,
      getVelocityX() /100,
      getVelocityY() /100,
      size()/30,
      getHeat(),
      xClosest,
      yClosest,
      heatClosest,
      sizeClosest/30,
      
      getReward()
    };
  }

  void eat(Thing o) {
    super.eat(o);
    if (o instanceof QualiaOscMunchkin)
      ((QualiaOscMunchkin)o).wasEaten = true;
    hasEaten = true;
  }
  
  // Extra methods.
  Munchkin split() {
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
