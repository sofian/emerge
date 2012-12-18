class World {
  
  color backgroundColor;
  Vector<Munchkin> munchkins;
  
  World(color backgroundColor) {
    this.backgroundColor = backgroundColor;
    munchkins = new Vector<Munchkin>();
  }
  
  void addMunchkin(Munchkin m) {
    munchkins.add(m);
  }
  
  Vector<Munchkin> getMunchkinsInArea(int x, int y, float radius) {
    Vector<Munchkin> mInArea = new Vector<Munchkin>();
    for (Munchkin m : munchkins) {
      if (circleCollision(x, y, radius, m.x, m.y, m.size * 0.5))
        mInArea.add(m);
    }
    return mInArea;
  }
  
  
  void step() {
    Collections.sort(munchkins);
    Collections.reverse(munchkins); // sort from biggest to smallest
    for (Munchkin m : munchkins) {
      //print(m.size + " ");
      m.step(this);
      
      // Resolve conflicts.
      Vector<Munchkin> inArea = world.getMunchkinsInArea(m.x, m.y, m.size*3);
      inArea.remove(m); // remove itself from the lot
      
      if (inArea.size() > 0) {
        Collections.sort(inArea); // sort from smallest to biggest
        int groupSize = 0;
        for (Munchkin o : inArea) {
            groupSize += o.size;
        }
        
        if (groupSize > m.size) {
          m.size--;
        } else { // Eat smallest
          m.size++;
          Munchkin smallest = inArea.get(0);
          smallest.size--;
        }
      }
    }
    
    Iterator<Munchkin> it = munchkins.iterator();
    while (it.hasNext()) {
      Munchkin m = it.next();
      if (m.size <= 0)
        it.remove();
    }
    
    println();
  }
  
  void draw() {
    background(backgroundColor);
    for (Munchkin m : munchkins) {
      m.draw();
    }
  }
  
  /**
   * Check if two circle collide
   * x_1, y_1, radius_1 defines the first circle
   * x_2, y_2, radius_2 defines the second circle
   * From: http://wiki.processing.org/w/Circle-Circle_intersection
   */
  boolean circleCollision(float x_1, float y_1, float radius_1, float x_2, float y_2, float radius_2)
  {
    return dist(x_1, y_1, x_2, y_2) < radius_1 + radius_2;
  }
}
