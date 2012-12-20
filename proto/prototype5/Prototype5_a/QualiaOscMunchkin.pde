class QualiaOscMunchkin extends Munchkin {

  float fx;
  float fy;
  
  float xHeat;
  float yHeat;
  float xSize;
  float ySize;
  
  
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
//    println(fx + ", " + fy);
    float heatFactor = getHeat() * getHeat() * 10;
    fx *= heatFactor;
    fy *= heatFactor;
    addForce(fx, fy);
    float forceStrength = sqrt(fx*fx + fy*fy);
    setHeat(getHeat() - constrain(forceStrength, 0.0f, 1.0f) * HEAT_DECREASE_ON_ACTION);
    resetMoveForce();
  }
  
  void step(World world) {
    super.step(world);
    
    float observationRadius = 4 * getActionRadius();
    Vector<Thing> neighbors = world.getThingsInArea(x(), y(), observationRadius);

    xHeat = 0;
    yHeat = 0;
    xSize = 0;
    ySize = 0;
    for (Thing t : neighbors) {
      float xdist = map(x() - t.x(), -observationRadius, observationRadius, -1., +1.);
      float ydist = map(y() - t.y(), -observationRadius, observationRadius, -1., +1.);
      xHeat += xdist * t.getHeat();
      yHeat += ydist * t.getHeat();
      xSize += xdist * t.size();
      ySize += ydist * t.size();
    }
    
    if (random(0.0, 1.0) < 0.1/(size()+1)) setSize(size()+1);
  }
  
  void resetMoveForce() {
    this.fx = this.fy = 0;
  }
  
  void addMoveForce(float fx, float fy) {
    this.fx += fx * ACTION_FORCE_FACTOR;
    this.fy += fy * ACTION_FORCE_FACTOR;
  }
  
  float getReward() {
    return  10*getHeat()
            + getSize()
            + abs(getVelocityX()) + abs(getVelocityY()) // like to move
            + (xHeat*xHeat + yHeat*yHeat) // attracted by heat
            - sqrt(xSize*xSize + ySize*ySize) // repelled by size
            + 10*(1 - distance(x(), y(), width/2, height/2) / width); // occupy the center
    //return getHeat()*5 + getSize();
    //return getHeat() + x() + y();
  }
  
  float[] getObservation() {
    return new float[] {
      x()/width,
      y()/height,
      abs(getVelocityX()),
      abs(getVelocityY()),
      size(),
      getHeat(),
      xHeat,
      yHeat,
      xSize,
      ySize,
      
      getReward()
    };
  }
  
  // Extra methods.
  Munchkin split() {
    float newSize = floor(size()*.8);
    float newHeat = getHeat() / 2 - HEAT_DECREASE_ON_ACTION;
    setHeat(newHeat);
    setSize(newSize);
    return null;
  }
  
}
