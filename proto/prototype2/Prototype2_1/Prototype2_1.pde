import traer.physics.*;
import Mapper.*;
import Mapper.Db.*;

ParticleSystem physics = new ParticleSystem();

final int BASE_ATTRACTION_STRENGTH = 3000;
final int ATTRACTION_MIN_DISTANCE  = 5;

final int BUBBLE_DIAM = 35;

final int DIM_OBSERVATIONS = 7;
final int DIM_ACTIONS = 1;

final Device dev = new Device("prototype2-gui", 9000);
Device.Signal observation;
Device.Signal action;

int nextAction = 0;

Bubble agent;
Bubble user;
Attraction magnetism;

float movingReward = 0.5;
float score = 0;
//float chargeBalance = 0;

boolean agentChangedCharge = false;

final float REWARD_DECAY = 0.1;

void setup()
{
  size( 400, 400 );
  frameRate( 24 );
  smooth();
  ellipseMode( CENTER );
  noStroke();
  noCursor();
  colorMode(RGB, 1.0);
  
  agent = new Bubble(1.0, random( 0, width ), random( 0, height ) );
  user  = new Bubble(1.0, random( 0, width ), random( 0, height ) );
//  user.getParticle().makeFixed();
  
  magnetism = physics.makeAttraction( agent.getParticle(), user.getParticle(), 0, ATTRACTION_MIN_DISTANCE);
  
  initMapper();
}

void draw() // step
{
  noCursor(); // pourquoi dois-je le repeter???
  
  // Wait for agent to take action.
  while (dev.poll(1) == 0);

  // Take the action.
  agentChangedCharge = (nextAction == 0 && agent.getCharge() >= 0) || (nextAction == 1 && agent.getCharge() < 0);
  agent.setCharge( nextAction == 0 ? -1 : +1 );
//  chargeBalance += agent.getCharge();
  
  // Update magnetic forces.
  magnetism.setStrength( (int) (- agent.getCharge() * user.getCharge() * BASE_ATTRACTION_STRENGTH) );
  println(agent.getCharge() + " " + user.getCharge() + " " + magnetism.getStrength());
  //user.getParticle().position().set( mouseX, mouseY, 0 );
  handleBoundaryCollisions( agent.getParticle() );
  handleBoundaryCollisions( user.getParticle() );
  physics.tick();

  // Draw background.  
  float backgroundTint = 1-constrain(movingReward, 0, 1);
  background( backgroundTint, 0, 0 );
  
  // Draw score.
  noStroke();
  fill( 0.5, 0, 1 );
  rect( 10, 10, 30, (height-20) * constrain(score / 100, 0, 100) / 100.0 );

  // Re-draw agents.
  stroke( 1 );
  fill( (agent.getCharge() + 1) / 2.0 );
  ellipse( agent.getParticle().position().x(), agent.getParticle().position().y(), BUBBLE_DIAM, BUBBLE_DIAM );

  noStroke();
  fill( 0, 0, 1.0, 0.2 );
  ellipse( user.getParticle().position().x(), user.getParticle().position().y(), BUBBLE_DIAM*2, BUBBLE_DIAM*2 );
  stroke( 1 );
  fill( (user.getCharge() + 1) / 2.0 );
  ellipse( user.getParticle().position().x(), user.getParticle().position().y(), BUBBLE_DIAM, BUBBLE_DIAM );

  
//  agent.draw();
//  user.draw();
  
  // Send new observation to agent.
  float xa = agent.getParticle().position().x();
  float ya = agent.getParticle().position().y();
  float xu = user.getParticle().position().x();
  float yu = user.getParticle().position().y();
  float diffX = xa-xu;
  float diffY = ya-yu;
  float distance = sqrt(diffX*diffX + diffY*diffY);
  
  // Compute reward.
  float reward = 0;
  if (distance < BUBBLE_DIAM) // collision!
    reward -= 100;
  else
    reward += 1-distance/width; // try to get as close as possible
  
  score += reward;
  if (score < 0) score = 0;
  
//  if (agentChangedCharge)
//    reward -= 10; // discourage changing charge all the time
  
  // try to switch often between positive and negative
//  if (abs(chargeBalance) > 100) {
//    chargeBalance = constrain(chargeBalance, -100, 100);
//    reward--;
//  }

  println("reward = " + reward);
  movingReward -= REWARD_DECAY * (movingReward - reward);
  observation.update( new float[] { xa/width, ya/width, xu/width, yu/width, distance/width, agent.getCharge(), user.getCharge(),  reward } );
}

// really basic collision strategy:
// sides of the window are walls
// if it hits a wall pull it outside the wall and flip the direction of the velocity
// the collisions aren't perfect so we take them down a notch too
void handleBoundaryCollisions( Particle p )
{
  if ( p.position().x() < 0 || p.position().x() > width )
    p.velocity().set( -0.9*p.velocity().x(), p.velocity().y(), 0 );
  if ( p.position().y() < 0 || p.position().y() > height )
    p.velocity().set( p.velocity().x(), -0.9*p.velocity().y(), 0 );
  p.position().set( constrain( p.position().x(), 0, width ), constrain( p.position().y(), 0, height ), 0 ); 
}

void mousePressed() {
  user.setCharge( -1 );
}

void mouseReleased() {
  user.setCharge( +1 );
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


class Bubble {
  protected float charge; // value between [-1..1]
  protected Particle p;
  
  Bubble() {
    p = physics.makeParticle();
    charge = 1;
  }
  
  Bubble(float mass, float x, float y) {
    p = physics.makeParticle(mass, x, y, 0);
    charge = 1;
  }

  Particle getParticle() { return p; }
  
  float getCharge() { return charge; }
  boolean isPositive() { return (charge >= 0); }
  boolean isNegative() { return (charge < 0); }
  float getStrength() { return abs(charge); }
  
  void setCharge(float charge) {
    this.charge = charge;

//    for (int i=0; i<physics.numberOfAttractions(); i++) {
//      Attraction a = physics.getAttraction(i);
//      Bubble attractive = null;
//      if (a.getOneEnd() == p)
//        attractive = (Bubble)a.getTheOtherEnd().getParticle();
//      else if (a.getTheOtherEnd() == this)
//        attractive = (Bubble)a.getOneEnd().getParticle();
//      
//      if (attractive != null) {
//        // change attraction rule
//        a.setStrength( (int) (getCharge() * attractive.getCharge() * BASE_ATTRACTION_STRENGTH) );
//      } 
//    }
  }
  
  void draw() {
    stroke( 1 );
    fill( (charge + 1) / 2.0 );
    ellipse( p.position().x(), p.position().y(), BUBBLE_DIAM, BUBBLE_DIAM );
  }
  
}



