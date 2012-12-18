class World extends FWorld {
  
  color backgroundColor;
  Vector<Thing> things;
  
  World(color backgroundColor) {
    this.backgroundColor = backgroundColor;
    things = new Vector<Thing>();
  }
  
  void addThing(Thing t) {
    super.add(t);
    things.add(t);
  }
  
  Vector<Thing> getThingsInArea(float x, float y, float radius) {
    Vector<Thing> inArea = new Vector<Thing>();
    for (Thing t : things) {
      if (circleCollision(x, y, radius, t.x(), t.y(), t.size() * 0.5))
        inArea.add(t);
    }
    return inArea;
  }
  
  void step() {
    super.step();
    for (Thing t : things) {
      t.step(this);
    }
  }
  
  /*
  void draw() {
    background(backgroundColor);
    for (Thing t : things) {
      t.draw();
    }
  }*/
  
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
