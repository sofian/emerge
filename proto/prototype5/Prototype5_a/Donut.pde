// ******************************************************************
// This class represents a user-controlled agent, aka a donut.
// ******************************************************************
class Donut extends FCircle
{  
  int ID;
  int targetPosX;
  int targetPosY;
  
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
  }
  
  // ============================================
  // Setters & getters
  // ============================================ 
  void setTargetPosition(int x, int y)
  {
    targetPosX = x;
    targetPosY = y;
    println("New target position: " + x + "\t" + y);
  }
  
  // ============================================
  // Member functions
  // ============================================  
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
    float forceX = DONUT_CURSOR_FORCE_MULTIPLIER * (targetPosX-getX());
    float forceY = DONUT_CURSOR_FORCE_MULTIPLIER * (targetPosY-getY());
    addForce(forceX, forceY);
    println("Target pos: [" + targetPosX + ";" + targetPosY + "]\nCurrentPos: [" + getX() + ";" + getY() + "]\nForces: [" + forceX + ";" + forceY + "]");
    
    // Inform Max/MSP client of physics-enabled position
    NetAddress remote = new NetAddress("127.0.0.1", 4444);
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/donut/xyphysics");
    msg.add(ID);
    msg.add(getX());
    msg.add(getY());
    osc.oscP5.send(msg, remote);
  }
}
