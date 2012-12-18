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
  
  int n = Munchkin.RED;
  for (int i=0; i<N_MUNCHKINS/3; i++) {
    world.addMunchkin(new Munchkin(Munchkin.RED,   (int)random(0,width/2-50), (int)random(0,height/2)));
    world.addMunchkin(new Munchkin(Munchkin.GREEN, (int)random(width/4, 3*width/4), (int)random(height/2,height)));
    world.addMunchkin(new Munchkin(Munchkin.BLUE,  (int)random(width/2+50, width), (int)random(0,height/2)));
  }
}

void draw() {
  if (!started) return;
  synchronized (world) {
    try {
      world.step();
      world.draw();
    } catch (ArrayIndexOutOfBoundsException e) {
      println(e);
      e.printStackTrace();
    }
  }
}

void keyPressed() {
  if (key == ' ')
    started = true;
}
