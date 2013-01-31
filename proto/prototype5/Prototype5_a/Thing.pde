abstract class Thing extends FCircle implements Comparable<Thing> {

  static final int RED   = 0;
  static final int GREEN = 1;
  static final int BLUE  = 2;
  static final int WHITE = -1;
  
  static final int N_NATIONS = 3;
  
  int nation;

  private float heat;

  Thing(int nation, float x, float y, float size, float heat) {
    super(size);
    setPosition(x, y);
    setDamping(10.0f);
    
//    setDamping(BOT_DAMPING);
//    setAngularDamping(BOT_ANGULAR_DAMPING);
//    setFriction(10.0f);
    setRestitution(1.0f);
    setFillColor(getColor());
    setNoStroke();
//    setRotatable(true);
    setDensity(1);
    setFillColor(getColor());
    setHeat(heat);
    this.nation = nation;
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
  
  void draw(processing.core.PGraphics applet) {
    color c = nationToColor(nation);
    c = color( red(c), green(c), blue(c), 50);
    applet.fill(c);
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
  
  float getHeat() { return heat; }
  void setHeat(float h) {
    if (!Float.isNaN(h))
      heat = constrain(h, 0.0f, 1.0f); 
  }
  
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
  
  public String toString() {
    return x() + " " + y() + " " + getForceX() + " " + getForceY();
  }
  
}
