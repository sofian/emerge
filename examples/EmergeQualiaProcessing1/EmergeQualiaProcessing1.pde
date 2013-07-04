// ******************************************************************
// This program is an example showing Qualia <-> Processing 
// interaction through OSC channel
// ******************************************************************
import fisica.*;
import oscP5.*;
import netP5.*;
import java.util.*;
import java.lang.reflect.*;

// Window and overall environment
final int     WINDOW_WIDTH  = 640;
final int     WINDOW_HEIGHT = WINDOW_WIDTH*3/4;
final int     FRAME_RATE = 30;
final float   ACTION_RADIUS_FACTOR = 2.0f;
final float   ACTION_RADIUS_BASE   = 20.0f;
final int     ACTION_COLOR = color(100, 50, 50, 100);
final color   WORLD_BACKGROUND_COLOR = #000000;
final float   WORLD_EDGE_RESTITUTION = 1.0f;
final boolean QUALIA_VERBOSE = false;
final boolean DONUT_MOUSE_SIMULATION = false; // set to true if you want to simulate fiducial tracking by click-dragging your mouse cursor
final boolean ATTRACTION_MODE = true;

// Munchkin related
final int   N_QUALIA_AGENTS = 12;
final int   N_MUNCHKINS = 0; // deprecated
final int   MUNCHKIN_MIN_SIZE = 5;
final int   MUNCHKIN_INITIAL_MAX_SIZE = 10;
final int   MUNCHKIN_EXPLODE_SIZE_THRESHOLD = 15;
final float MUNCHKIN_EXPLODE_BASE_PROBABILITY = 0.01f;
final float MUNCHKIN_INITIAL_HEAT = 0.5f;

final float MUNCHKIN_ATTRACTION_FACTOR = (ATTRACTION_MODE ? 1e5f : 1000.0f);
final int   MUNCHKIN_ATTRACTION_RADIUS   = (ATTRACTION_MODE ? 300 : 100);
final float MUNCHKIN_OBSERVATION_RADIUS = 100;
//final float MUNCHKIN_OBSERVATION_RADIUS_FACTOR = 4;
final float MUNCHKIN_RESTITUTION = 0.2f;
final float MUNCHKIN_DAMPING     = 10.0f;
final float MUNCHKIN_FRICTION    = 10.0f;
final float MUNCHKIN_DENSITY     = 1.0f;

// Donut related
final int   N_DONUTS = 1; // 216
final float DONUT_CURSOR_FORCE_MULTIPLIER = 400.0f;
final float DONUT_CURSOR_DAMPING = 100.0f;
final float DONUT_HEAT_INCREASE = 0.2f;
final float DONUT_INITIAL_HEAT = 0.5f;
final float DONUT_INITIAL_SIZE = 30;

final boolean DONUT_VERBOSE = false; // set to true to display extra donut information
final int   DONUT_IDLE_LIFETIME_MS = 30000; // idle time to allow before an untracked donut is removed
final int   DONUT_THRESHOLD_LIFETIME_MS = 10000; // if the threshold count has been reached at this booth, send a logout message to the sound system
final int   DONUT_THRESHOLD_COUNT = 10; // how many donuts at a booth before we send logoudle ones

// Heat decrease factors.
//final float HEAT_MAP_DECREASE_FACTOR = 0.05f;
//final float   HEAT_MAP_DECREASE_FACTOR = 1.0/255.0f;
final float   HEAT_DECREASE = 0.0f;
final float   HEAT_DECREASE_ON_ACTION = 0.0f;
//final float   HEAT_DECREASE = 0.0001f;
//final float   HEAT_DECREASE_ON_ACTION = 0.0001f;

final String  QUALIA_EXEC_FULL_PATH = "/home/tats/Documents/workspace/qualia/tests/osc/build/computer/main";
final int     BOOTH_OSC_IN_PORT        = 12000; // This Processing patch listens to this port for instructions.
final int     QUALIA_OSC_BASE_PORT     = 11000; // The base port of the Qualia agents in this booth. As many ports as munchkins will be used.
final String  QUALIA_OSC_IP            = "127.0.0.1"; // IP address of the machine running the Qualia agents

final int N_ACTIONS_PER_DIM = ATTRACTION_MODE ? 2 : 3;
final int ACTION_DIM = ATTRACTION_MODE ? 1 : 2;

final int OBSERVATION_DIM = (ATTRACTION_MODE ? 5 : 11);
final float ACTION_FORCE_FACTOR = 200.0f;
final float ACTION_NOISE_FACTOR = ACTION_FORCE_FACTOR / 3;

final int MAX_N_AGENTS = 100;

final boolean HUMAN_CONTROLLED_AGENT = false;
int[] humanControlledAction = new int[2];

QualiaOsc osc; // OSC server & client for Qualia

World    world;
volatile boolean started = true;
boolean       cursorAction = true;

Process[] procs = new Process[N_QUALIA_AGENTS];

// ============================================
// Overall initialization
// ============================================
void setup()
{
  killQualia();
  prepareExitHandler();
  
  // NOTE: We can't use P2D because we need to make a loadPixels() in the Booth class and it makes everything very slow.
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
  noCursor();
  frameRate(FRAME_RATE);
  
  Fisica.init(this);
  
  world = new World(WORLD_BACKGROUND_COLOR);
  world.setEdges();
  world.setGravity(0, 0); // no x,y gravity
  world.setEdgesRestitution(WORLD_EDGE_RESTITUTION);

  // The osc client and server for communication with Qualia
  osc = new QualiaOsc(MAX_N_AGENTS, BOOTH_OSC_IN_PORT, QUALIA_OSC_BASE_PORT, QUALIA_OSC_IP, new EmergeEnvironmentManager(world));
    
  // Launch the Qualia agents
  for (int i=0; i<N_QUALIA_AGENTS; i++)
  {    
    String actionParams = String.valueOf(N_ACTIONS_PER_DIM);
    for (int j=1; j<ACTION_DIM; j++)
    {
      actionParams += "," + String.valueOf(N_ACTIONS_PER_DIM);
    }
    
    String[] execParams = { QUALIA_EXEC_FULL_PATH, String.valueOf(i), String.valueOf(OBSERVATION_DIM), String.valueOf(ACTION_DIM), actionParams, "-port", String.valueOf(QUALIA_OSC_BASE_PORT), "-rport", String.valueOf(BOOTH_OSC_IN_PORT) };

    // Launch process and record pid
    // somehow open() refuses to work under Linux
    procs[i] = (platform == WINDOWS ? open(execParams) : exec(execParams));
    
      
    println("Launched Qualia agent " + i);

    try
    {
      Thread.sleep(100);
    }
    catch (InterruptedException e)
    {
      println(e);
    }
  }
    
  // Wait for init and start messages.
  // Wait for init().
  try
  {
    while (!osc.getManager().allMarked()) Thread.sleep(100);
    println("Init done");
    osc.getManager().unmarkAll();
    for (int i=0; i<N_QUALIA_AGENTS; i++)
    {
      osc.sendResponseInit(i);
    }
  
    // Wait for start().
    while (!osc.getManager().allMarked())
    {
      Thread.sleep(100);
    }
    println("Start done");
    osc.getManager().unmarkAll();
    for (int i=0; i<N_QUALIA_AGENTS; i++)
    {
      println("Handling " + i);
      osc.sendResponseStart(i, osc.getManager().get(i).getObservation());
      Thread.sleep(10); // necessary on a slower machine
    }
  }
  catch (InterruptedException e)
  {
    println(e);
  }
  
  if (DONUT_MOUSE_SIMULATION)
  {
    Donut cursorControlledDonut = world.donuts.get(new Integer(0));
    cursorControlledDonut.setPosition(width/2, height/2);
    cursorControlledDonut.setTargetPosition(width/2, height/2);
  }
}

// ============================================
// Draw
// ============================================
void draw()
{
  synchronized (world)
  {
    //background(#000000);
    if (!started) return;
    try
    {
      while (!osc.getManager().allMarked()) Thread.sleep(100);
      osc.getManager().unmarkAll();
    }
    catch (InterruptedException e)
    {
      println(e);
    }

    try
    {
      world.step();
      world.draw();
      
      for (int i=0; i<N_QUALIA_AGENTS; i++)
      {
        EmergeEnvironment env = (EmergeEnvironment)osc.getManager().get(i);
      }

      for (int i=0; i<N_QUALIA_AGENTS; i++)
      {
        osc.sendResponseStep(i, osc.getManager().get(i).getObservation());
      }
      
      // Safe moment to remove the donuts marked for deletion
      world.removeDonuts();      
    } catch (ConcurrentModificationException e) {
      for(;;) {
        try {
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
void mouseMoved() {
  if (DONUT_MOUSE_SIMULATION)
  {
    Donut cursorControlledDonut = world.donuts.get(new Integer(0));
    cursorControlledDonut.setTargetPosition(mouseX, mouseY);
  }
}

// ============================================
// Mouse drag is the same as mouse motion 
// ============================================
void mouseDragged()
{
  mouseMoved();
}

void keyPressed()
{
  if (HUMAN_CONTROLLED_AGENT)
  {
    int x = humanControlledAction[0];
    int y = humanControlledAction[1];
    if (key == CODED) {
      switch (keyCode) {
        case LEFT:  x--; break;
        case RIGHT: x++; break;
        case UP:    y--; break;
        case DOWN:  y++; break;
      }
    }
    x = constrain(x, -N_ACTIONS_PER_DIM/2, +N_ACTIONS_PER_DIM/2+1);
    y = constrain(y, -N_ACTIONS_PER_DIM/2, +N_ACTIONS_PER_DIM/2+1);
    humanControlledAction[0] = x;
    humanControlledAction[1] = y;
  }
}

// Source: http://www.golesny.de/p/code/javagetpid
int getUnixPID(Process process) throws Exception
{
  if (process.getClass().getName().equals("java.lang.UNIXProcess"))
  {
    Class cl = process.getClass();
    Field field = cl.getDeclaredField("pid");
    field.setAccessible(true);
    Object pidObject = field.get(process);
    return (Integer) pidObject;
  }
  else
  {
    throw new IllegalArgumentException("Needs to be a UNIXProcess");
  }
}

void killQualia()
{
  println("Killing Qualia instances..."); 
  if (platform == WINDOWS)
  {
    String[] params = { "taskkill.exe", "/IM", QUALIA_EXEC_FULL_PATH, "/F"};
    open(params);
  }
  else
  {
    for (int i=0; i<N_QUALIA_AGENTS; i++) 
    {
      // Try to send a SIGINT signal to the processes (they are meant to clean up nicely when receiving SIGINT)
      if (procs[i] != null) 
      {
        try {
          String[] sigintParams = {"kill", "-2", String.valueOf(getUnixPID(procs[i])) };
          exec( sigintParams );
        } catch (Exception e) {}
      }
    }

    try {
      Thread.sleep(500);
    } catch (InterruptedException e) {
      println(e);
    }

    for (int i=0; i<N_QUALIA_AGENTS; i++) 
    {
      // Try to destroy the processes.
      if (procs[i] != null) 
      {
        procs[i].destroy(); // kill the process
      }
    }
    
    // Send a killall command.
    String[] params = { "killall", QUALIA_EXEC_FULL_PATH };
    exec(params);
    exec(params); // I need to do it twice, don't know why       
  }

}

void contactStarted(FContact contact)
{
  try
  {
    Donut d1 = (Donut)contact.getBody1();
    Donut d2 = (Donut)contact.getBody2();
    if (d1 != null && d2 != null)
    {
//      oscSound.sendDonutContact(d1, d2, contact.getX(), contact.getY());
    }
  }
  //catch (InvocationTargetException e)
  catch (Exception e)
  {
  }
}

void contactPersisted(FContact contact)
{
}

void contactEnded(FContact contact)
{
}

private void prepareExitHandler() {

  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
  
    public void run() {
      System.out.println("Shutdown");
      killQualia();
    }
  
  }));

}
