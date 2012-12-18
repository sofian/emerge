class World {
  
  color backgroundColor;
  Vector<Thing> things;
  
  World(color backgroundColor) {
    this.backgroundColor = backgroundColor;
    things = new Vector<Thing>();
  }
  
  void addThing(Thing t) {
    things.add(t);
  }
  
  Vector<Thing> getThingsInArea(int x, int y, float radius) {
    Vector<Thing> inArea = new Vector<Thing>();
    for (Thing t : things) {
      if (circleCollision(x, y, radius, t.x(), t.y(), t.size() * 0.5))
        inArea.add(t);
    }
    return inArea;
  }
  
  void step() {
    
    // Compute munchkin-munchkin interactions/conflicts.
    Collections.sort(things);
    Collections.reverse(things); // sort from biggest to smallest
    for (Thing t : things) {
      t.step(this);
      
      // Resolve conflicts.
      Vector<Thing> inArea = world.getThingsInArea((int)t.x(), (int)t.y(), t.size()*3);
      inArea.remove(t); // remove itself from the lot
      
     // Keep only things it can eat.
      Iterator<Thing> it = inArea.iterator();
      while (it.hasNext()) {
        Thing o = it.next();
        if (!t.isPredatorOf(o))
          it.remove();
      }

      if (inArea.size() > 0) {
        
        Collections.sort(inArea); // sort from smallest to biggest
   
        int groupSize = 0;
        for (Thing o : inArea) {
            if (o.isPredatorOf(t))
              groupSize += 3*o.size();
            else
              groupSize += o.size();
        }
        
        if (groupSize > t.size()) {
          inArea.lastElement().eat(t);
        } else { // Eat smallest
          t.eat(inArea.firstElement());
        }
      }
    }
    
    Iterator<Thing> it = things.iterator();
    Vector<Thing> splitted = new Vector<Thing>();
    while (it.hasNext()) {
      Thing t = it.next();
      // Clean.
      if (t.isDead())
        it.remove();
      // Split.
      else if (t instanceof Munchkin) {
        Munchkin m = (Munchkin) t;
        if (m.size() <= 0)
          it.remove();
        else if (m.size() > 50) {
            println("Split!");
            splitted.add(m.split());
        }
      }
    }
    
    things.addAll(splitted);
  }
  
  void draw() {
    background(backgroundColor);
    for (Thing t : things) {
      t.draw();
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
