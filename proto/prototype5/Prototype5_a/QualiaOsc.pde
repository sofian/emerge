
abstract class QualiaEnvironment {
  
  int id;
  int observationDim;
  int actionDim;
  
  QualiaEnvironment(int id, int observationDim, int actionDim) {
    this.id = id;
    this.observationDim = observationDim;
    this.actionDim = actionDim;
  }
  
  int getId() { return id; }
  int getObservationDim() { return observationDim; }
  int getActionDim() { return actionDim; }
  
  abstract void init();
  abstract float[] start();
  abstract float[] step(int[] action);
}

abstract class QualiaEnvironmentManager {

  HashMap<Integer, QualiaEnvironment> instances;

  QualiaEnvironmentManager() {
    instances = new HashMap<Integer, QualiaEnvironment>();
  }

  QualiaEnvironment create(int id, int observationDim, int actionDim) {
    QualiaEnvironment env = _doCreate(id, observationDim, actionDim);
    instances.put(new Integer(id), env);
    return env;
  }
  
  QualiaEnvironment get(int id) {
    return instances.get(new Integer(id));
  }
  
  int nInstances() { return instances.size(); }
  HashMap<Integer, QualiaEnvironment> getInstances() { return instances; }
  
  abstract QualiaEnvironment _doCreate(int id, int observationDim, int actionDim);
}

class QualiaOsc {
  
  OscP5 oscP5;
  NetAddress remoteLocation;
  
  NetAddress brunoRemoteLocation;
  
  QualiaEnvironmentManager manager;

  public QualiaOsc(int port, int remotePort, String ip, int brunoRemotePort, String brunoIp, QualiaEnvironmentManager manager) {
    println(port + " " + remotePort + " " + ip);
    oscP5 = new OscP5(this, port);
    remoteLocation = new NetAddress(ip, remotePort);
    brunoRemoteLocation = new NetAddress(brunoIp, brunoRemotePort);
    
    oscP5.plug(this, "emergeDonutXY",     "/donut/xy");
    oscP5.plug(this, "emergeDonutAction", "/donut/1/action");
    //oscP5.plug(this, "qualiaInit",   "/qualia/init");
    //oscP5.plug(this, "qualiaStart",  "/qualia/start");
    //oscP5.plug(this, "qualiaStep",   "/qualia/step");
    
    this.manager = manager;
  }
  
  QualiaEnvironmentManager getManager() { return manager; }

  // NOTE: This should have been in EmergeQualiaOsc but the super() call doesn't work and I don't know why.
  void emergeSendMunchkinInfo(int id, Munchkin m) {
    OscMessage msg = new OscMessage("/munchkin");
    msg.add(id);
    msg.add(m.x()/width);
    msg.add(m.y()/height);
    msg.add(m.size());
    msg.add(m.getHeat());
    oscP5.send(msg, brunoRemoteLocation);
  }

  public void emergeDonutXY(int ID, float x, float y) {
    int newX = (int)constrain(map(x, 0., 1., 0, width), 0, width-1);
    int newY = (int)constrain(map(y, 0., 1., 0, height), 0, height-1);
    Donut thisDonut = (Donut)world.donuts.get(ID);
    thisDonut.setPosition(newX, newY);
    //println("New position for donut " + ID + ": X=" + newX + " Y=" + newY + " (" + x + " " + y + ")");
  }
  
  public void qualiaCreate(int agentId, int observationDim, int actionDim) {
    manager.create(agentId, observationDim, actionDim);
    /*
    OscMessage message = new OscMessage("/qualia/response/create/" + agentId);
    message.add(id); // id
    sendOsc(message);*/
  }
  
  void qualiaInit(int id) {
    println("Qualia init: " + id);
    manager.get(id).init();
    OscMessage message = new OscMessage("/qualia/response/init/" + id);
    sendOsc(message);
  }

  void qualiaStart(int id) {
    println("Qualia start: " + id);
    float[] obs = manager.get(id).start();
    println("Observations to return: " + obs);
    OscMessage message = new OscMessage("/qualia/response/start/" + id);
//    message.add(agentId); // id
    message.add(obs);     // observation
    sendOsc(message);
  }

  void qualiaStep(int id, int[] action) {
    float[] obs = manager.get(id).step(action);
    OscMessage message = new OscMessage("/qualia/response/step/" + id);
 //   message.add(agentId); // id
    message.add(obs);     // observation
    sendOsc(message);
  }

  void sendOsc(OscPacket packet) {
    oscP5.send(packet, remoteLocation);
  }
  
  int extractId(OscMessage msg, String startPath) {
    return Integer.parseInt(msg.addrPattern().substring(startPath.length()+1));
  }
  
  void oscEvent(OscMessage msg) {
    String pattern = msg.addrPattern();
    if (pattern.equals("/qualia/create")) {
      qualiaCreate(msg.get(0).intValue(), msg.get(1).intValue(), msg.get(2).intValue());
    }
    
    else if (pattern.startsWith("/qualia/init")) {
      qualiaInit(extractId(msg, "/qualia/init"));
    }
    
    else if (pattern.startsWith("/qualia/start")) {
      qualiaStart(extractId(msg, "/qualia/start"));
    }
    
    else if (pattern.startsWith("/qualia/step")) {
      int id = extractId(msg, "/qualia/step");
      int[] action = new int[manager.get(id).getActionDim()];
      for (int i=0; i<action.length; i++)
        action[i] = msg.get(i).intValue();
      qualiaStep(id, action);
    }
    /* with theOscMessage.isPlugged() you check if the osc message has already been
     * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
     * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
     * be used for double posting but is not required.
     */
    /*if (msg.isPlugged()==false) {
      /* print the address pattern and the typetag of the received OscMessage */
    /*  println("### received an osc message.");
      println("### addrpattern\t"+msg.addrPattern());
      println("### typetag\t"+msg.typetag());
    }*/
  }
}
