import Mapper.*;
import Mapper.Db.*;

int[] action = new int[2];
final int N_ACTIONS = 10;
final int HALF_N_ACTIONS = N_ACTIONS/2;
float reward;

float[] input = new float[2];

float movingReward = 0;
final float REWARD_DECAY = 0.1;

final Device dev = new Device("javatest", 9000);

Mapper.Device.Signal sigMouseX = dev.add_output("mouse_x", 1, 'f', "", new Double(0), null);
Mapper.Device.Signal sigMouseY = dev.add_output("mouse_y", 1, 'f', "", new Double(0), null);

void setup() {
  size(480, 640);
  smooth();
  noStroke();
  noCursor();
/*  Mapper.Device.Signal inp1 = dev.add_input("insig1", 1, 'f', "Hz", new Double(2.0), null,
            new InputListener() {
                public void onInput(float[] v) {
                    System.out.println("in onInput(): "+Arrays.toString(v));
                }});*/


}

void update() {
//  for (int i=0; i<2; i++) {
//    action[i] = (int) random(-HALF_N_ACTIONS+1, HALF_N_ACTIONS);
//  action = (action + 1) % 256; // fake
//  reward = (action > 128 ? 1 : -1);
  input[0] = mouseX/ (float)width;
  input[1] = mouseY/ (float)height;
  
  sigMouseX.update( new float[] { input[0] } );
  sigMouseY.update( new float[] { input[1] } );
  
  movingReward -= REWARD_DECAY * (movingReward - reward);
  
  dev.poll(0);
}

void drawBackground() {
  colorMode(HSB, 255);
  background(128,255,255);
//  background(action, 255, 255);
}

void drawFace() {
//  stroke();
  noStroke();
  colorMode(RGB, 255);
  fill(0); // black
  ellipseMode(CENTER);
  
  int xLeft  = width/3;
  int xRight = 2*width/3;
  int yTop   = height/3;
  int yLow   = 2*height/3;
  int eyeWidth  = width/10;
  int eyeHeight = 2*eyeWidth;
  int smileWidth = xRight - xLeft;
  int xAnchorLeft    = xLeft  + smileWidth/3;
  int xAnchorRight   = xRight - smileWidth/3;
  int smileWidthFactor = width/20;
  
  // eyes
  ellipse(xLeft,  yTop, eyeWidth, eyeHeight);
  ellipse(xRight, yTop, eyeWidth, eyeHeight);
  
  // smile
  stroke(0);
  strokeWeight(10);
  noFill();
//  bezier(xLeft, yLow, xAnchorLeft, yLow, xAnchorRight, yLow, xRight, yLow);
  int yHappiness = (int) (constrain(movingReward, -1.0, 1.0) * height/10) / 2;
//  int yHappiness = height/10;
  bezier(xLeft-smileWidthFactor, yLow+yHappiness, 
         xAnchorLeft, yLow-yHappiness, 
         xAnchorRight, yLow-yHappiness, 
         xRight+smileWidthFactor, yLow+yHappiness);
}

void drawFly() {
  noStroke();
  fill(0);
  ellipseMode(CENTER);
  int xBody  = (int) (input[0] * width);
  int yBody = (int) (input[1] * height);
  ellipse(xBody, yBody, 3, 3); // body
  stroke(0);
  noFill();
  strokeWeight(2);
  ellipse(xBody-2, yBody+2, 5, 3); // left wing
  ellipse(xBody+2, yBody+2, 5, 3); // right wing
}

void draw() {
  update();
  drawBackground();
  drawFace();
  drawFly();
}
