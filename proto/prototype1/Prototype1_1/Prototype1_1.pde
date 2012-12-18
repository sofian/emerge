int action;
float reward;

float[] input = new float[2];

float movingReward = 0;
final float REWARD_DECAY = 0.1;

void setup() {
  size(480, 640);
  smooth();
  noStroke();
  noCursor();
}

void update() {
  action = (action + 1) % 256; // fake
  reward = (action > 128 ? 1 : -1);
  input[0] = mouseX/ (float)width;
  input[1] = mouseY/ (float)height;
  
  movingReward -= REWARD_DECAY * (movingReward - reward);
}

void drawBackground() {
  colorMode(HSB, 255);
  background(action, 255, 255);
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
