import fisica.*;
import oscP5.*;
import netP5.*;
import java.util.*;

// Window and overall environment
final int     WINDOW_WIDTH  = 640;
final int     WINDOW_HEIGHT = WINDOW_WIDTH*3/4;
final int     FRAME_RATE = 60; // was 30
final float   ACTION_RADIUS_FACTOR = 2.0f;
final float   ACTION_RADIUS_BASE   = 20.0f;
final int     ACTION_COLOR = color(100, 50, 50, 100);
final color   WORLD_BACKGROUND_COLOR = #000000;

// Munchkins and donuts
final int     N_MUNCHKINS = 0;
final int     MUNCHKIN_INITIAL_SIZE = 5;
final float   MUNCHKIN_INITIAL_HEAT = 0.5f;
final float   DONUT_HEAT_INCREASE = 0.2f;
final int     N_DONUTS = 216;
final int     N_BOOTHS = 5;

// Heat related
final int     HEAT_MAP_GRADIENT_STEPS = 10;
final float   HEAT_MAP_ABSORPTION_FACTOR = 0.1f; // proportion of heat absorbed by the munchkins when there is MORE heat in the map than in the munchkin
final float   HEAT_MAP_DISSIPATION_FACTOR = 0.001f; // proportion of heat dissipated from the munchkins to the heat map when there is LESS heat in the map than in the munchkin
final float   HEAT_MAP_SPREAD_FACTOR = 0.05f; // 
final float   HEAT_ON_EAT = 0.05f;
final float   HEAT_MAP_INITIAL_HEAT = 0.0f;
final float   HEAT_TRACE_SIZE_FACTOR = 5.0f;

// Heat decrease factors.
//final float HEAT_MAP_DECREASE_FACTOR = 0.05f;
final float   HEAT_MAP_DECREASE_FACTOR = 1.0/255.0f;
final float   HEAT_DECREASE = 0.0001f;
final float   HEAT_DECREASE_ON_ACTION = 0.0001f;

final int     CONTROLLER_OSC_PORT        = 12000;
final int     CONTROLLER_OSC_REMOTE_PORT = 11000;
final int     BRUNO_OSC_REMOTE_PORT      = 10000;
final String  CONTROLLER_OSC_IP = "127.0.0.1";
final String  BRUNO_OSC_IP      = "127.0.0.1";
//final String BRUNO_OSC_IP      = "192.168.123.208";

final int     N_ACTIONS_XY = 100;
final float   ACTION_FORCE_FACTOR = 100.0f;

QualiaOsc     osc;
HashMap<Integer, Booth> booths = new HashMap<Integer, Booth>(); // identified by their ID
int            activeBooth = 0;
volatile boolean started = true;
boolean       cursorAction = true;

// ============================================
// Overall initialization
// ============================================
void setup()
{
  // NOTE: We can't use P2D because we need to make a loadPixels() in the Booth class and it makes everything very slow.
  size(WINDOW_WIDTH, WINDOW_HEIGHT, P2D);
  noCursor();
  frameRate(30);
  
  Fisica.init(this);
  
  for (int i=1; i<=N_BOOTHS; i++)
  {
    Booth booth = new Booth(i, WORLD_BACKGROUND_COLOR);
    booth.setEdges();
    booth.setGravity(0, 0); // no x,y gravity
    booths.put(i, booth);
  }
  activeBooth = 1;

  osc = new QualiaOsc(CONTROLLER_OSC_PORT, CONTROLLER_OSC_REMOTE_PORT, CONTROLLER_OSC_IP, BRUNO_OSC_REMOTE_PORT, BRUNO_OSC_IP, new EmergeEnvironmentManager(booths));
    
  /*
  int n = Munchkin.RED;
  for (int i=0; i<N_MUNCHKINS; i++)
  {
    booth.addThing(new Munchkin(Munchkin.RED,   (int)random(0,width), (int)random(0,height), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT));
//    booth.addThing(new Munchkin(Munchkin.RED,   (int)random(0,width/2-50), (int)random(0,height/2), 10));
//    booth.addThing(new Munchkin(Munchkin.GREEN, (int)random(width/4, 3*width/4), (int)random(height/2,height), 10));
//    booth.addThing(new Munchkin(Munchkin.BLUE,  (int)random(width/2+50, width), (int)random(0,height/2), 10));
  }  
  try
  {
    Thread.sleep(1000);
  }
  catch (InterruptedException e)
  {
    println(e);
  }
  */
}

// ============================================
// Draw
// ============================================
void draw()
{
  synchronized (booths)
  {
    //background(#000000);    
    if (!started) return;
    try
    {
      Booth booth = booths.get(activeBooth);
      booth.draw();
      
      for (int i=0; i<osc.getManager().nInstances(); i++)
      {
        EmergeEnvironment env = (EmergeEnvironment)osc.getManager().get(i);
        osc.emergeSendMunchkinInfo(i, (Munchkin)env.getMunchkin());
      }
    }
    catch (ConcurrentModificationException e)
    {
      for(;;)
      {
        try
        {
          Thread.sleep(1000);
        }
        catch (InterruptedException e1)
        {
          continue;
        }
        break;
      }
    }
    catch (ArrayIndexOutOfBoundsException e)
    {
      println(e);
      e.printStackTrace();
    }
  }
}

// ============================================
// Get the distance between vectors
// ============================================
float distance(float x1, float y1, float x2, float y2)
{
  float xdiff = x1 - x2;
  float ydiff = y1 - y2;
  return sqrt( xdiff*xdiff + ydiff*ydiff );
}

// ============================================
// Draw a gradient circle
// ============================================
void circleGradient(PGraphics g, int x, int y, int size, float min, float max, float blending)
{
  g.ellipseMode(CENTER);
  g.noStroke();
  for (int s=size; s>=1; s--)
  {
    g.fill(lerp(min, max, 1-(float)s / (float)size), blending);
    g.ellipse(x, y, s, s);
  }
}

// ============================================
// The mouse controls the donut with ID 0 in the active booth
// ============================================
void mouseMoved()
{
  float mouseXNorm = (float)mouseX / WINDOW_WIDTH;
  float mouseYNorm = (float)mouseY / WINDOW_HEIGHT;
  // The mouse interacts with the first donut in the first booth
  booths.get(activeBooth).emergeDonutXY(0, mouseXNorm, mouseYNorm);
}

// ============================================
// Mouse drag is the same as mouse motion 
// ============================================
void mouseDragged()
{
  mouseMoved();
}

// Change the active booth with the keyboard
void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == LEFT)
    {
      activeBooth--;
      if (activeBooth < 1)
      {
        activeBooth = N_BOOTHS;
      }
    }
    else if (keyCode == RIGHT)
    {
      activeBooth++;
      if (activeBooth > N_BOOTHS)
      {
        activeBooth = 1;
      }
    }
  }
}
