abstract class Thing extends FCircle implements Comparable<Thing> {

  static final int RED   = 0;
  static final int GREEN = 1;
  static final int BLUE  = 2;
  static final int WHITE = -1;
  
  static final int N_NATIONS = 3;

  Thing(float x, float y, float size) {
    super(size);
    setPosition(x, y);
    setDamping(10.0f);
//    setDamping(BOT_DAMPING);
//    setAngularDamping(BOT_ANGULAR_DAMPING);
//    setFriction(10.0f);
//    setRestitution(1.0f);
    setFillColor(getColor());
    setNoStroke();
//    setRotatable(true);
    setDensity(1);
    setFillColor(getColor());
  }

  void eat(Thing o) {
  }
  
  int nationToColor(int n) {
    switch (n) {
      case RED:   return #ff0000;
      case GREEN: return #00dd00;
      case BLUE:  return #9999ff;
      default:    return #ffffff;
    }
  }
  
  int getPreyNationOf(int nation) {
    return (nation + 1) % N_NATIONS;
  }
  
  int getPredatorNationOf(int nation) {
    return (nation + N_NATIONS - 1) % N_NATIONS;
  }

  void draw(processing.core.PGraphics applet) {
    applet.fill(ACTION_COLOR);
    applet.noStroke();
    applet.ellipse(x(), y(), getActionRadius()*2, getActionRadius()*2);
    setFillColor(getColor());
    super.draw(applet);
  }
  
  // Deprecated (compatibility).
  float x() { return getX(); }
  float y() { return getY(); }
  float size() { return getSize(); }
  float getActionRadius() { return (getSize() * ACTION_RADIUS_FACTOR + ACTION_RADIUS_BASE) / 2; }
  
  abstract int getNation();

  abstract void step(World world);
  
  abstract float getHeat();
  
//  abstract void draw();

//  abstract void eat(Thing o);

  int getColor() { return nationToColor(getNation()); }
  
  
  
/*  boolean isPredatorOf(Thing o) {
    return (getPredatorNationOf(o.getNation()) == this.getNation());
  }
  
  boolean isPreyOf(Thing o) {
    return (getPreyNationOf(o.getNation()) == this.getNation());
  }
  */
  boolean isDead() { return size() <= 0; }
  
  public int compareTo(Thing o) {
    return (int) (size() - o.size());
  }

}
