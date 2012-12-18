import fisica.*;

final int FRAME_RATE = 30;
final float ACTION_RADIUS_FACTOR = 2.0f;
final float ACTION_RADIUS_BASE   = 20.0f;
final int ACTION_COLOR = #220000;

final color WORLD_BACKGROUND_COLOR = #000000;
final int N_MUNCHKINS = 600;

Donut theDonut;
World    world;
volatile boolean started = false;

void setup() {
  //size(400, 200);
  size(1280, 768);
 // size(1200, 800);
  frameRate(FRAME_RATE);
  smooth();
  noCursor();
  
  Fisica.init(this);
  
  world = new World(WORLD_BACKGROUND_COLOR);
  world.setEdges();
  world.setGravity(0, 0); // no x,y gravity
  
  //theDonut = new Donut();
  //world.addThing(theDonut);
  
  int n = Munchkin.RED;
  for (int i=0; i<N_MUNCHKINS/3; i++) {
    world.addThing(new Munchkin(Munchkin.RED,   (int)random(0,width), (int)random(0,height), 5));
//    world.addThing(new Munchkin(Munchkin.RED,   (int)random(0,width/2-50), (int)random(0,height/2), 10));
//    world.addThing(new Munchkin(Munchkin.GREEN, (int)random(width/4, 3*width/4), (int)random(height/2,height), 10));
//    world.addThing(new Munchkin(Munchkin.BLUE,  (int)random(width/2+50, width), (int)random(0,height/2), 10));
  }
}

void draw() {
  background(#000000);
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

void keyPressed() {
  if (key == ' ')
    started = true;
}

float distance(float x1, float y1, float x2, float y2) {
  float xdiff = x1 - x2;
  float ydiff = y1 - y2;
  return sqrt( xdiff*xdiff + ydiff*ydiff );
}

