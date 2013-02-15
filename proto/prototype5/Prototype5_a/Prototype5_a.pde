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
final float   WORLD_EDGE_RESTITUTION = 1.0f;
final boolean QUALIA_VERBOSE = false;
final boolean DONUT_MOUSE_SIMULATION = false; // set to true if you want to simulate fiducial tracking by click-dragging your mouse cursor

// Munchkin related
final int   N_MUNCHKINS = 0;
final int   MUNCHKIN_MIN_SIZE = 5;
final int   MUNCHKIN_INITIAL_MAX_SIZE = 10;
final int   MUNCHKIN_EXPLODE_SIZE_THRESHOLD = 15;
final float MUNCHKIN_EXPLODE_BASE_PROBABILITY = 0.01f;
final float MUNCHKIN_INITIAL_HEAT = 0.5f;
final int   N_QUALIA_AGENTS = 12;
final float MUNCHKIN_ATTRACTION_FACTOR = 200.0f;
final int   MUNCHKIN_ATTRACTION_RADIUS   = 100;
final float MUNCHKIN_OBSERVATION_RADIUS = 100;
//final float MUNCHKIN_OBSERVATION_RADIUS_FACTOR = 4;
final float MUNCHKIN_RESTITUTION = 0.2f;
final float MUNCHKIN_DAMPING     = 10.0f;
final float MUNCHKIN_FRICTION    = 10.0f;
final float MUNCHKIN_DENSITY     = 1.0f;

// Donut related
final int   N_DONUTS = 1; // 216
final float DONUT_CURSOR_FORCE_MULTIPLIER = 500.0f;
final float DONUT_CURSOR_DAMPING = 200.0f;
final float DONUT_HEAT_INCREASE = 0.2f;
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

final int     BOOTHID = 1;
final int     TOTAL_BOOTHS = 4;
final int     BOOTH_OSC_IN_PORT        = 12000 + (BOOTHID-1)*100; // This Processing patch listens to this port for instructions.
final int     QUALIA_OSC_BASE_PORT     = 11000 + (BOOTHID-1)*100; // The base port of the Qualia agents in this booth. As many ports as munchkins will be used.
final String  QUALIA_OSC_IP            = "127.0.0.1"; // IP address of the machine running the Qualia agents
final String  MAXMSP_LOGIC_IP          = "192.168.168.59"; // IP address of the machine consolidating the input from several booths
final int     MAXMSP_LOGIC_PORT_OUT    = 10000; // The port to use to send instructions to the logic server, and ultimately to the playback system
final int     DONUT_LOGIN_PORT         = 10001; // The port to use to send/receive instructions related to donut logins at each booth
final String  TUIO_TAG_IP              = "127.0.0.1"; // IP address of the machine running the fiducial tracker
final int     TUIO_TAG_PORT            = 4444; // The port of the communication from the fiducial tracker on this machine
final String  SOUND_OSC_IP             = "192.168.168.215"; // IP address of the machine running the fiducial tracker
final int     SOUND_OSC_PORT           = 8877; // The port of the communication from the fiducial tracker on this machine

final int N_ACTIONS_PER_DIM = 3;
final int ACTION_DIM = 2;
final int OBSERVATION_DIM = 11;
//final int N_ACTIONS_PER_DIM = 100;
final float ACTION_FORCE_FACTOR = 100.0f;
final float ACTION_NOISE_FACTOR = ACTION_FORCE_FACTOR / 3;

final int MAX_N_AGENTS = 100;

final boolean HUMAN_CONTROLLED_AGENT = false;
int[] humanControlledAction = new int[2];

QualiaOsc osc; // OSC server & client for Qualia
LogicOscClientServer oscLogic; // send positions derived from fisica, receive login information from other booths
FiducialOscClientServer oscFiducials; // send login information to other booths, receive TUIO fiducial information
SoundOscClient oscSound; // send information to the sound system

World    world;
volatile boolean started = true;
boolean       cursorAction = true;

// ============================================
// Overall initialization
// ============================================
void setup()
{
  killQualia();
  
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
  oscLogic = new LogicOscClientServer(MAXMSP_LOGIC_IP, DONUT_LOGIN_PORT, MAXMSP_LOGIC_PORT_OUT); 
  oscFiducials = new FiducialOscClientServer(TUIO_TAG_IP, TUIO_TAG_PORT);
  oscSound = new SoundOscClient(SOUND_OSC_IP, SOUND_OSC_PORT);
    
  // Launch the Qualia agents
  if (platform == WINDOWS)
  {
    for (int i=(BOOTHID-1)*N_QUALIA_AGENTS; i<=(BOOTHID-1)*N_QUALIA_AGENTS+N_QUALIA_AGENTS-1; i++)
    {
      String execFullPath = "C:/Qualia/QualiaOSC.exe";
      
      String actionParams = String.valueOf(N_ACTIONS_PER_DIM);
      for (int j=1; j<ACTION_DIM; j++)
      {
        actionParams += "," + String.valueOf(N_ACTIONS_PER_DIM);
      }
      
      String[] execParams = { execFullPath, String.valueOf(i), String.valueOf(OBSERVATION_DIM), String.valueOf(ACTION_DIM), actionParams, "-softmax", "-port", String.valueOf(QUALIA_OSC_BASE_PORT), "-rport", String.valueOf(BOOTH_OSC_IN_PORT) };
      //println(execParams);
      Process p = open(execParams);
      println("Booth " + BOOTHID + "\tLaunched Qualia agent " + i);
  
      try
      {
        Thread.sleep(100);
      }
      catch (InterruptedException e)
      {
        println(e);
      }
    }
  }
  else
  {
    println("Please launch " + (N_QUALIA_AGENTS-1) + " agents with ids " + ((BOOTHID-1)*N_QUALIA_AGENTS) + " to " + ((BOOTHID-1)*N_QUALIA_AGENTS+N_QUALIA_AGENTS-2));

    try
    {
      Thread.sleep(2500);
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
    for (int i=(BOOTHID-1)*N_QUALIA_AGENTS; i<=(BOOTHID-1)*N_QUALIA_AGENTS+N_QUALIA_AGENTS-1; i++)
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
    for (int i=(BOOTHID-1)*N_QUALIA_AGENTS; i<=(BOOTHID-1)*N_QUALIA_AGENTS+N_QUALIA_AGENTS-1; i++)
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
    Donut cursorControlledDonut = world.donuts.get(new Integer((BOOTHID-1)*N_QUALIA_AGENTS));
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
      
      for (int i=(BOOTHID-1)*N_QUALIA_AGENTS; i<=(BOOTHID-1)*N_QUALIA_AGENTS+N_QUALIA_AGENTS-1; i++)
      {
        EmergeEnvironment env = (EmergeEnvironment)osc.getManager().get(i);
        oscLogic.emergeSendMunchkinInfo(i, (Munchkin)env.getMunchkin());
      }

      for (int i=(BOOTHID-1)*N_QUALIA_AGENTS; i<=(BOOTHID-1)*N_QUALIA_AGENTS+N_QUALIA_AGENTS-1; i++)
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
    Donut cursorControlledDonut = world.donuts.get(new Integer((BOOTHID-1)*N_QUALIA_AGENTS));
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

void killQualia()
{
  if (platform == WINDOWS)
  {
    println("Killing Qualia instances..."); 
    String[] params = { "taskkill.exe", "/IM", "QualiaOSC.exe", "/F"};
    open(params);
  }
}

void dispose()
{
  killQualia();
  try {
    Thread.sleep(500);
  } catch (InterruptedException e) {
    println(e);
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
      oscSound.sendDonutContact(d1, d2, contact.getX(), contact.getY());
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
