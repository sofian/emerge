// ******************************************************************
// This class represents a user-controlled agent, aka a donut.
// ******************************************************************
class Donut extends FCircle implements Comparable<Donut>
{  
  int ID;
  int targetPosX;
  int targetPosY;
  int lastPosX;
  int lastPosY;
  int msLastTargetPosition; // the time of the last target position
  boolean soundLoggedOut = false; // whether or not the donut has been logged out of the sound system
  
  // ============================================
  // Constructor
  // ============================================
  Donut(int id)
  {
    // Initialize the position outside the range of this world
    super(100);
    setPosition(-200, 200);
    ID = id;
    targetPosX = 50;
    targetPosY = 50;
    msLastTargetPosition = millis(); // simulate initial instructions
  }
  
  // ============================================
  // Setters & getters
  // ============================================ 
  void setTargetPosition(int x, int y)
  {
    targetPosX = x;
    targetPosY = y;
    msLastTargetPosition = millis();
    
    if (DONUT_VERBOSE)
    {
      println("Donut " + ID + " has target pos: " + targetPosX + "\t" + targetPosY);
    }
  }
  
  // ============================================
  // Member functions
  // ============================================  
  public int compareTo(Donut d)
  {
    if (d.ID == ID)
    {
      return 0;
    }
    else
    {
      return 1;
    }
  }
  
  void draw(processing.core.PGraphics applet)
  {
    applet.ellipseMode(CENTER);
    applet.noStroke();
    applet.fill(color(0, 0, 255, cursorAction ? 100 : 50));
    applet.smooth();
    applet.ellipse(getX(), getY(), getSize(), getSize());
  }
  
  void step(World world)
  {    
    // Approach the target position
    float forceX = DONUT_CURSOR_FORCE_MULTIPLIER * (targetPosX-getX()) - DONUT_CURSOR_DAMPING * (lastPosX - getX());
    float forceY = DONUT_CURSOR_FORCE_MULTIPLIER * (targetPosY-getY()) - DONUT_CURSOR_DAMPING * (lastPosY - getY());
    lastPosX = (int)getX();
    lastPosY = (int)getY();
    addForce(forceX, forceY);
    if (DONUT_VERBOSE)
    {
      println("Target pos: [" + targetPosX + ";" + targetPosY + "]\nCurrentPos: [" + getX() + ";" + getY() + "]\nForces: [" + forceX + ";" + forceY + "]");
    }
    
    oscLogic.sendDonutPhysics(this);
    oscSound.sendDonutPhysics(this);
  }
}
