/**
 * ControlP5 button.
 * this example shows how to create buttons with controlP5.
 * 
 * by andreas schlegel, 2009
 */
//import controlP5.*;

import Mapper.*;
import Mapper.Db.*;

import java.util.LinkedList;
import java.util.Queue;

final int DIM_OBSERVATIONS = 3;
final int DIM_ACTIONS = 1;

final Device dev = new Device("prototype3-gui", 9000);
Device.Signal observation;
Device.Signal action;

final int OFF = 0;
final int ON  = 1;

int nextAction = OFF;

int userState  = OFF;
int agentState = OFF;

final int COLOR_OFF  = color(0, 0, 0);
final int COLOR_ON = color(128, 128, 128);
final int COLOR_BACKGROUND = color(255, 255, 255);

final int BASE_HEIGHT = 480;

//final int CIRCULAR_BUFFER_SIZE = 16;
//LinkedList circularBuffer = new LinkedList();

//MovingAverage[] observationAverages = new MovingAverage[DIM_OBSERVATIONS-1];
float observationVec[] = new float[DIM_OBSERVATIONS+1];

final float REWARD_DECAY = 0.01;
MovingAverage movingReward = new MovingAverage(0, REWARD_DECAY);
float totalReward = 0;

LinkedList circularRewardBuffer = new LinkedList();

void setup() {
  noCursor();
  size((int)BASE_HEIGHT * 4/3, BASE_HEIGHT);
  smooth();
  
  frameRate(30);

//  for (int i=0; i<CIRCULAR_BUFFER_SIZE; i++)
//    circularBuffer.add(new Float(0)); // dummy

  for (int i=0; i<width; i++)
    circularRewardBuffer.add(new Float(0)); // dummy
//  controlP5 = new ControlP5(this);
//  
//  buttonUser = controlP5.addButton("user", 1, width/5, height/3, width/5, height/3);
//  buttonUser.setLabel(null);
//  buttonUser.setColorBackground(COLOR_PULL);
//  
//  buttonAgent = controlP5.addButton("agent", 1, 3*width/5, height/3, width/5, height/3);
//  buttonAgent.setLabel(null);
//  buttonAgent.setColorBackground(COLOR_PULL);
  initMapper();
}

void drawButton(int x, int y, int state) {
  noStroke();
  fill( state == ON ? COLOR_ON : COLOR_OFF );
  rect( x, y, width/5, height/3 );
}

void drawAll() {
  drawButtons();
  drawObservations();
  drawReward();
}
  
void drawButtons() {
  background(COLOR_BACKGROUND);
  drawButton(width/5, height/3, userState);
  drawButton(3*width/5, height/3, agentState);
}

void drawObservations() {
  for (int i=0; i<DIM_OBSERVATIONS; i++) {
    fill( 255 - constrain( observationVec[i] * 255, 0, 255) );
    rect(i*width/DIM_OBSERVATIONS, 9*height/10, width/DIM_OBSERVATIONS, height/10);
  }
}  

int _rewardToY(float r) {
  return (int) ((r + 1) / 2.0 * (height / 3));
}

void drawReward() {
  stroke(0, 0, 255);
  int lastY = _rewardToY(((Number) circularRewardBuffer.get(0)).floatValue());
  for (int x=1; x<width; x++) {
    float r = ((Number) circularRewardBuffer.get(x)).floatValue();
    int y =  _rewardToY(r);
    line(x-1,lastY,x,y);
    lastY=y;
    //println( "Point at: (" + x + "," + y + ")" );
  }
  // baseline
  stroke(128,0,0);
  line(0, height/3/2, width-1, height/3/2);
}

int counter = 0;
float reward = 0;

int lastOn = 0;
int lastOff = 0;

void draw() {
  counter ++;
  if ((counter%8)==0) {
    mousePressed();
  }
  else if ((counter%8)==4) {
    mouseReleased();
  }
  if (counter > 8) counter = 0;
  
  // Redraw.
//  drawButtons();
//  drawObservations();
  drawAll();

    // Push observation.
//  circularBuffer.remove();
//  circularBuffer.add(userState);
  
  int k=0;
  observationVec[k++] = userState;
  observationVec[k++] = lastOn  / 16.0;
  observationVec[k++] = lastOff / 16.0;

  for (int i=0; i<observationVec.length; i++)
    print(observationVec[i] + " ");
  println();
  
  // Wait for agent to take action.
  if (dev.poll(0) != 0) {
    
    // State automatically changes.
    agentState = nextAction;
  
    // Compile reward.
    if (agentState == userState)
      reward = 1;
    else
      reward = -1;
  
    movingReward.update(reward);
    totalReward += reward;

    // Push reward.
    circularRewardBuffer.remove();
    circularRewardBuffer.add(movingReward.get());
    
    observationVec[DIM_OBSERVATIONS] = reward;
    
    observation.update( observationVec );
    
  }
  
  lastOn++;
  lastOff++;
}

void mousePressed() {
  userState = ON;
  lastOn = 0;
  drawButtons();
}

void mouseReleased() {
  userState = OFF;
  lastOff = 0;
  drawButtons();
}

void initMapper() {
  
  action = dev.add_input("/action", DIM_ACTIONS, 'i', "", new Double(0.0), null, 
    new InputListener() {
      public void onInput(int[] v) {
        System.out.println("Receiving action: "+Arrays.toString(v));
        nextAction = v[0];
      }
    }
  );

  System.out.println("Input signal name: "+action.name());

  observation = dev.add_output("/observation", DIM_OBSERVATIONS + 1, 'f', "", new Double(0.0), new Double(1.0));
  System.out.println("Output signal index: "+observation.index());
  System.out.println("Zeroeth output signal name: "+dev.get_output_by_index(0).name());

//  out1.query_remote(inp2);

//  dev.set_property("width", new PropertyValue(256));
//  dev.set_property("height", new PropertyValue(12.5));
//  dev.set_property("depth", new PropertyValue("67"));
//  
//  out1.set_property("width", new PropertyValue(128));
//  out1.set_property("height", new PropertyValue(6.25));
//  out1.set_property("depth", new PropertyValue("test"));
//  out1.set_property("deletethis", new PropertyValue("or me"));
//  out1.remove_property("deletethis");
//
//  System.out.println("Looking up `height': "
//    + out1.properties().property_lookup("height"));
//  System.out.println("Looking up `width': "
//    + out1.properties().property_lookup("width"));
//  System.out.println("Looking up `depth': "
//    + out1.properties().property_lookup("depth"));

  System.out.println("Waiting for ready...");
  while (!dev.ready ()) {
    dev.poll(100);
  }
  System.out.println("Device is ready.");

  System.out.println("Device name: "+dev.name());
  System.out.println("Device port: "+dev.port());
  System.out.println("Device ordinal: "+dev.ordinal());
  System.out.println("Device interface: "+dev.iface());
  System.out.println("Device ip4: "+dev.ip4());
}



class MovingAverage {
  float _alpha;
  float _value;

  /**
   * Constructs the moving average, starting with #startValue# as its value. The #alphaOrN# argument
   * has two options:
   * - if <= 1 then it's used directly as the alpha value
   * - if > 1 then it's used as the "number of items that are considered from the past" (*)
   * (*) Of course this is an approximation. It actually sets the alpha value to 2 / (n - 1)
   */
  MovingAverage(float startValue, float alphaOrN) {
    _value = startValue;
    _alpha = (alphaOrN > 1 ?
               2 / (alphaOrN - 1) :
               alphaOrN);
    println(_value);
    println(_alpha);
    println("----");
  }

  /**
   * Updates the moving average with new value #v#.
   */
  void update(float v) {
    _value -= _alpha * (_value - v);
  }

  /**
   * Returns the value of the moving average.
   */
  float get() { return _value; }

  /**
   * Resets the moving average to #startValue#.
   */
  void reset(float startValue) {
    _value = startValue;
  }
};


