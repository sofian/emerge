final int FRAME_RATE = 30;

final color WORLD_BACKGROUND_COLOR = #000000;
final int N_MUNCHKINS = 1000;

Munchkin theMunchkin;
World    world;
volatile boolean started = false;

void setup() {
  //size(400, 200);
  size(1280, 768);
 // size(1200, 800);
  frameRate(FRAME_RATE);
  smooth();
  
  world = new World(WORLD_BACKGROUND_COLOR);
  
  for (int i=0; i<N_MUNCHKINS; i++)
    world.addMunchkin(new Munchkin((int)random(width), (int)random(height)));
}

void draw() {
  if (!started) return;
  synchronized (world) {
    try {
      world.step();
      world.draw();
    } catch (ArrayIndexOutOfBoundsException e) {
      println(e);
    }
  }
}

void keyPressed() {
  started = true;
}
