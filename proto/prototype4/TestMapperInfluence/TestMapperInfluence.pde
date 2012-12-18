import Mapper.*;
import Mapper.Db.*;

final Device dev = new Device("influence-gui", 9000);
Device.Signal[] inputSignal = new Device.Signal[2];
Device.Signal[] outputSignal = new Device.Signal[2]; // position

final int WINDOW_SIZE = 400;

float[] input = new float[2];

void setup()
{
  size( WINDOW_SIZE, WINDOW_SIZE );
  frameRate( 24 );
  smooth();
  ellipseMode( CENTER );
  noStroke();
  colorMode(RGB, 1.0);
  
  initMapper();
}

float myx = 0;
float myy = 0;

void draw() // step
{
  background(1.0);
//  noCursor(); // pourquoi dois-je le repeter???
  
  // Wait for input.
  //while (dev.poll(1) == 0);
  
  // Process input.
  float inx = input[0];
  float iny = input[1];
  println("IN: " + inx + "," + iny);
  
  outputSignal[0].update( new float[] { (float)mouseX / (float)width } );
  outputSignal[1].update( new float[] { (float)mouseY / (float)height } );
}

void initMapper() {
  
  inputSignal[0] = dev.add_input("/input/x", 1, 'f', "", new Double(0.0), null,
    new InputListener() {
      public void onInput(float[] v) {
        System.out.println("Receiving action (x): "+Arrays.toString(v));
        input[0] = v[0];
      }
    }
  );
  inputSignal[1] = dev.add_input("/input/y", 1, 'f', "", new Double(0.0), null,
    new InputListener() {
      public void onInput(float[] v) {
        System.out.println("Receiving action (y): "+Arrays.toString(v));
        input[1] = v[0];
      }
    }
  );

//  println("Input signal name: "+inputSignal.name());

  outputSignal[0] = dev.add_output("/output/x", 1, 'f', "", new Double(0.0), new Double(1.0));
  outputSignal[1] = dev.add_output("/output/y", 1, 'f', "", new Double(0.0), new Double(1.0));

  println("Waiting for ready...");
  while (!dev.ready ()) {
    dev.poll(100);
  }
  println("Device is ready.");

  println("Device name: "+dev.name());
  println("Device port: "+dev.port());
  println("Device ordinal: "+dev.ordinal());
  println("Device interface: "+dev.iface());
  println("Device ip4: "+dev.ip4());
}

