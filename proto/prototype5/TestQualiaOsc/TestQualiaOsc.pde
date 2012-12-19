import oscP5.*;
import netP5.*;
import java.util.*;


final int CONTROLLER_OSC_PORT        = 12000;
final int CONTROLLER_OSC_REMOTE_PORT = 11000;
final String CONTROLLER_OSC_IP = "127.0.0.1";

QualiaOsc osc;

void setup() {
  size(400, 200);
  
  osc = new QualiaOsc(CONTROLLER_OSC_PORT, CONTROLLER_OSC_REMOTE_PORT, CONTROLLER_OSC_IP, new TestQualiaEnvironmentManager());
}

void draw() {
  background(0);
  //println("-- N. instances: " + osc.getManager().nInstances());
  for (int id=0; id<osc.getManager().nInstances(); id++) {
    println("[" + id + "] = " + ((TestQualiaEnvironment)osc.getManager().get(id)).currentState());
  }
}
