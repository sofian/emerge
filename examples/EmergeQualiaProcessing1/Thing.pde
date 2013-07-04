// ******************************************************************
// This abstract class represents a physics-enabled object (forces can 
// be applied to it)
// ******************************************************************
abstract class Thing extends FCircle implements Comparable<Thing>
{
  static final int RED    = 0;
  static final int GREEN  = 1;
  static final int BLUE   = 2;
  static final int YELLOW = 3;
  static final int PURPLE = 4;
  static final int ORANGE = 5;
  
  static final int WHITE  = -1;
  
  static final int N_NATIONS = 3;
  
  int nation;

  private float heat;

  // ============================================
  // Constructor
  // ============================================
  Thing(int nation, float x, float y, float size, float heat)
  {
    super(size);
    setPosition(x, y);
    setFillColor(getColor());
    setHeat(heat);
    this.nation = nation;
  }

  // ============================================
  // Setters & getters
  // ============================================  
  // Deprecated (compatibility).
  float x() { return getX(); }
  float y() { return getY(); }
  float size() { return getSize(); }
  float getActionRadius() { return (getSize() * ACTION_RADIUS_FACTOR + ACTION_RADIUS_BASE) / 2; }
  int getNation() { return #000000; }
  float getHeat() { return heat; }
  void setHeat(float h)
  {
    if (!Float.isNaN(h))
    {
      heat = constrain(h, 0.0f, 1.0f);
    } 
  }
  int getColor() { return nationToColor(getNation()); } 
  
/*  boolean isPredatorOf(Thing o) {
    return (getPredatorNationOf(o.getNation()) == this.getNation());
  }
  
  boolean isPreyOf(Thing o) {
    return (getPreyNationOf(o.getNation()) == this.getNation());
  }
  */
  boolean isDead() { return size() <= 0; }

  // ============================================
  // Member functions
  // ============================================ 
  abstract void step(World world);
  
  int nationToColor(int n)
  {
    switch (n) {
      case RED:    return #ff0000;
      case GREEN:  return #00dd00;
      case BLUE:   return #9999ff;
      case YELLOW: return #ffffe0;
      case PURPLE: return #9b30ff;
      case ORANGE: return #ff3300;
      default:     return #ffffff;
    }
  }
  
  void draw(processing.core.PGraphics applet)
  {
    color c = nationToColor(nation);
    c = color( red(c), green(c), blue(c), 50);
    applet.fill(c);
    applet.noStroke();
    applet.ellipse(x(), y(), getActionRadius()*2, getActionRadius()*2);
    setFillColor(getColor());
    super.draw(applet);
  }
  
  public int compareTo(Thing o)
  {
    return (int) (size() - o.size());
  }
  
  public String toString()
  {
    return " ( " + x() + " " + y() + " " + getForceX() + " " + getForceY() + " )";
  }  
}
