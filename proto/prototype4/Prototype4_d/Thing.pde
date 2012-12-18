abstract class Thing implements Comparable<Thing> {

  static final int RED   = 0;
  static final int GREEN = 1;
  static final int BLUE  = 2;
  static final int WHITE = -1;
  
  static final int N_NATIONS = 3;

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

  abstract int getNation();

  abstract int size();
  abstract int x();
  abstract int y();
  
  abstract void step(World world);
  abstract void draw();

  abstract void eat(Thing o);

  int getColor() { return nationToColor(getNation()); }
  
  boolean isPredatorOf(Thing o) {
    return (getPredatorNationOf(o.getNation()) == this.getNation());
  }
  
  boolean isPreyOf(Thing o) {
    return (getPreyNationOf(o.getNation()) == this.getNation());
  }
  
  boolean isDead() { return size() <= 0; }
  
  public int compareTo(Thing o) {
    return (size() - o.size());
  }

}
