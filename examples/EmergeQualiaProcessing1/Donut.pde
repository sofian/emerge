// ******************************************************************
// This class represents a user-controlled agent, aka a donut.
// ******************************************************************
class Donut extends Thing
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
    super(Thing.WHITE, -200, 200, DONUT_INITIAL_SIZE, DONUT_INITIAL_HEAT);
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
  public int compareTo(Thing d)
  {
    if (d instanceof Donut)
      return ((Donut)d).ID == ID ? 0 : 1;
    else
      return 1;
  }
  
  void draw(processing.core.PGraphics applet)
  {
    applet.ellipseMode(CENTER);
    applet.noStroke();
    applet.fill(color(0, 0, 255, cursorAction ? 100 : 50));
    applet.smooth();
    applet.ellipse(getX(), getY(), getSize(), getSize());
    applet.fill(color(255,0,0));
    applet.ellipse(targetPosX, targetPosY, 10, 10);
  }
  
  void step(World world)
  {    
//    resetForces();
    // Approach the target position
    //float forceX = DONUT_CURSOR_FORCE_MULTIPLIER * (targetPosX-getX()) - DONUT_CURSOR_DAMPING * (lastPosX - getX());
    //float forceY = DONUT_CURSOR_FORCE_MULTIPLIER * (targetPosY-getY()) - DONUT_CURSOR_DAMPING * (lastPosY - getY());
    float dx = targetPosX-getX();
    float dy = targetPosY-getY();
    float forceX = DONUT_CURSOR_FORCE_MULTIPLIER * dx - DONUT_CURSOR_DAMPING * getVelocityX();
    float forceY = DONUT_CURSOR_FORCE_MULTIPLIER * dy - DONUT_CURSOR_DAMPING * getVelocityY();
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
