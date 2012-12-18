import fisica.*;

final int WINDOW_WIDTH  = 1280;
final int WINDOW_HEIGHT = 768;
//final int WINDOW_WIDTH  = 640;
//final int WINDOW_HEIGHT = 480;

final int FRAME_RATE = 30;
final float ACTION_RADIUS_FACTOR = 2.0f;
final float ACTION_RADIUS_BASE   = 20.0f;
final int ACTION_COLOR = color(100, 50, 50, 100);

final color WORLD_BACKGROUND_COLOR = #000000;
final int N_MUNCHKINS = 600;
final int   MUNCHKIN_INITIAL_SIZE = 5;
final float MUNCHKIN_INITIAL_HEAT = 0.8f;

// Heat related
final int   HEAT_MAP_GRADIENT_STEPS = 10;
final float HEAT_MAP_TRANSFER_FACTOR = 0.001f;
final float HEAT_ON_EAT = 0.05f;
final float HEAT_MAP_INITIAL_HEAT = 0f;
final float HEAT_TRACE_SIZE_FACTOR = 5.0f;

// Heat decrease factors.
//final float HEAT_MAP_DECREASE_FACTOR = 0.05f;
final float HEAT_MAP_DECREASE_FACTOR = 0.001f;
final float HEAT_DECREASE = 0.001f;
final float HEAT_DECREASE_ON_ACTION = 0.001f;

Donut theDonut;
World    world;
volatile boolean started = true;

void setup() {
  // NOTE: We can't use P2D because we need to make a loadPixels() in the World class and it makes everything very slow.
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
//  size(WINDOW_WIDTH, WINDOW_HEIGHT, P2D);
  //frameRate(FRAME_RATE);
  //smooth();
  //noCursor();
  
  Fisica.init(this);
  
  world = new World(WORLD_BACKGROUND_COLOR);
  world.setEdges();
  world.setGravity(0, 0); // no x,y gravity

  //theDonut = new Donut();
  //world.addThing(theDonut);
  
  int n = Munchkin.RED;
  for (int i=0; i<N_MUNCHKINS/3; i++) {
    world.addThing(new Munchkin(Munchkin.RED,   (int)random(0,width), (int)random(0,height), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT));
//    world.addThing(new Munchkin(Munchkin.RED,   (int)random(0,width/2-50), (int)random(0,height/2), 10));
//    world.addThing(new Munchkin(Munchkin.GREEN, (int)random(width/4, 3*width/4), (int)random(height/2,height), 10));
//    world.addThing(new Munchkin(Munchkin.BLUE,  (int)random(width/2+50, width), (int)random(0,height/2), 10));
  }
}

void draw() {
  //background(#000000);
  if (!started) return;
  try {
    synchronized (world) {
      world.step();
      world.draw();
    }
  } catch (Exception e) {
    println(e);
    e.printStackTrace();
  }
}

float distance(float x1, float y1, float x2, float y2) {
  float xdiff = x1 - x2;
  float ydiff = y1 - y2;
  return sqrt( xdiff*xdiff + ydiff*ydiff );
}

