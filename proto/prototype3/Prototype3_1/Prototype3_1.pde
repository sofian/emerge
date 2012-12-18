/**
 * ControlP5 button.
 * this example shows how to create buttons with controlP5.
 * 
 * by andreas schlegel, 2009
 */
//import controlP5.*;

import Mapper.*;
import Mapper.Db.*;

//ControlP5 controlP5;
//Button buttonUser, buttonAgent;

final int DIM_OBSERVATIONS = 8;
final int DIM_ACTIONS = 1;

final Device dev = new Device("prototype3-gui", 9000);
Device.Signal observation;
Device.Signal action;

final int OFF = 0;
final int ON  = 1;

int nextAction = OFF;

int userState  = OFF;
int agentState = OFF;

final int COLOR_ON  = color(0, 0, 0);
final int COLOR_OFF = color(128, 128, 128);
final int COLOR_BACKGROUND = color(255, 255, 255);

final int BASE_HEIGHT = 480;

MovingAverage[] observationAverages = new MovingAverage[DIM_OBSERVATIONS-1];
float observationVec[] = new float[DIM_OBSERVATIONS+1];

final float REWARD_DECAY = 0.1;
MovingAverage movingReward = new MovingAverage(0, REWARD_DECAY);

void setup() {
  noCursor();
  size((int)BASE_HEIGHT * 4/3, BASE_HEIGHT);
  smooth();
  
  frameRate(8);

  int n = 4;
  for (int i=0; i<observationAverages.length; i++) {
    observationAverages[i] = new MovingAverage(0, n);
    n += 2;
  }

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

void draw() {
  // Wait for agent to take action.
  while (dev.poll(1) == 0);
  
  // State automatically changes.
  agentState = nextAction;

  // Redraw.
  drawButtons();
  drawObservations();

  // Compile reward.
  float reward = 0;
  if (agentState == userState)
    reward ++;
  else
    reward --;

  movingReward.update(reward);
  
  // Push observation.
  int j=0;
  observationVec[j++] = userState; // last user action
  observationVec[j++] = observationAverages[0].get() - userState;
  observationAverages[0].update(userState);
  observationAverages[1].update(userState);
  for (int i=2; i<observationAverages.length; i++) {
//    observationVec[j++] = observationAverages[i].get();
    observationVec[j] = observationAverages[i].get() - observationAverages[i-1].get();
    observationAverages[i].update(userState);
    j++;
  }
  observationVec[j++] = reward;
  
//  for (int i=0; i<observationVec.length; i++)
//    print(observationVec[i] + " ");
//  println();
  observation.update( observationVec );
}

void mousePressed() {
  userState = ON;
  drawButtons();
}

void mouseReleased() {
  userState = OFF;
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

