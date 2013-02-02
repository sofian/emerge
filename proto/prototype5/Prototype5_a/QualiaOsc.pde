// ******************************************************************
// This abstract class represent an environment, as observable by an agent.
// ******************************************************************
abstract class QualiaEnvironment
{  
  int id;
  int observationDim;
  int actionDim;

  boolean flag;

  // ============================================
  // Constructor
  // ============================================
  QualiaEnvironment(int id, int observationDim, int actionDim)
  {
    this.id = id;
    this.observationDim = observationDim;
    this.actionDim = actionDim;
    this.flag = false;
  }
    
  // ============================================
  // Setters & getters
  // ============================================  
  int getId() { return id; }
  int getObservationDim() { return observationDim; }
  int getActionDim() { return actionDim; }
  
  // ============================================
  // Member functions
  // ============================================ 
  boolean marked() { return flag; }
  void mark()   { flag = true;  }
  void unmark() { flag = false; }
  
  abstract void init();
  
  abstract void start();
  
  abstract void step(int[] action);
  
  abstract float[] getObservation();
}

// ******************************************************************
// This abstract class handles the creation of agents
// ******************************************************************
abstract class QualiaEnvironmentManager
{
  // each agent is represented by an integer within an environment
  HashMap<Integer, QualiaEnvironment> instances;

  // ============================================
  // Constructor
  // ============================================
  QualiaEnvironmentManager()
  {
    instances = new HashMap<Integer, QualiaEnvironment>();
  }
  
  // ============================================
  // Setters & getters
  // ============================================  
  QualiaEnvironment get(int id) { return instances.get(new Integer(id)); }
  int nInstances() { return instances.size(); }
  HashMap<Integer, QualiaEnvironment> getInstances() { return instances; }
  
  // ============================================
  // Member functions
  // ============================================ 
  QualiaEnvironment create(int id, int observationDim, int actionDim)
  {
    QualiaEnvironment env = _doCreate(id, observationDim, actionDim);
    instances.put(new Integer(id), env);
    return env;
  }
  
  QualiaEnvironment get(int id) {
    return instances.get(new Integer(id));
  }
  
  boolean allMarked() {
    for (QualiaEnvironment e : instances.values()) {
      if (!e.marked())
        return false;
    }
    return true;
  }
  
  void unmarkAll() {
    for (QualiaEnvironment e : instances.values())
      e.unmark();
  }
  
  void init(int id) {
    QualiaEnvironment e = get(id);
    e.mark();
    e.init();
  }
  
  void start(int id) {
    QualiaEnvironment e = get(id);
    e.mark();
    e.start();
  }
  
  void step(int id, int[] action) {
    QualiaEnvironment e = get(id);
    e.mark();
    e.step(action);
  }
  
  float[] getObservation(int id) {
    return get(id).getObservation();
  }
  
  int nInstances() { return instances.size(); }
  HashMap<Integer, QualiaEnvironment> getInstances() { return instances; }
  
  abstract QualiaEnvironment _doCreate(int id, int observationDim, int actionDim);
}

// ******************************************************************
// This class handles all OSC communication
// ******************************************************************
class QualiaOsc
{  
  OscP5 oscP5;
  NetAddress remoteLocation;  
  NetAddress brunoRemoteLocation;  
  QualiaEnvironmentManager manager;

  // ============================================
  // Constructor
  // ============================================
  public QualiaOsc(int maxAgents, int port, int remotePort, String ip, int brunoRemotePort, String brunoIp, QualiaEnvironmentManager manager) {
  {
    println(port + " " + remotePort + " " + ip);
    oscP5 = new OscP5(this, port);
    remoteLocation = new Vector<NetAddress>();
    for (int i=0; i<maxAgents; i++)
      remoteLocation.add(new NetAddress(ip, remotePort+i));
    brunoRemoteLocation = new NetAddress(brunoIp, brunoRemotePort);
    
    oscP5.plug(this, "emergeDonutXY", "/booth" + BOOTHID + "/donut/xy");
    oscP5.plug(this, "emergeDonutAction", "/donut/1/action");
    //oscP5.plug(this, "qualiaInit",   "/qualia/init");
    //oscP5.plug(this, "qualiaStart",  "/qualia/start");
    //oscP5.plug(this, "qualiaStep",   "/qualia/step");
    
    this.manager = manager;
  }  
  
  // ============================================
  // Setters & getters
  // ============================================
  QualiaEnvironmentManager getManager() { return manager; }

  // ============================================
  // Member functions
  // ============================================ 
  // NOTE: This should have been in EmergeQualiaOsc but the super() call doesn't work and I don't know why.
  void emergeSendMunchkinInfo(int id, Munchkin m) {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/munchkin");
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
    Donut thisDonut = world.donuts.get(ID);
    thisDonut.setPosition(newX, newY);
  }
  
  public void qualiaCreate(int agentId, int observationDim, int actionDim)
  {
    manager.create(agentId, observationDim, actionDim);
    /*
    OscMessage message = new OscMessage("/qualia/response/create/" + agentId);
    message.add(id); // id
    sendOsc(message);*/
  }
  
  void sendResponseInit(int id) {
    OscMessage message = new OscMessage("/qualia/response/init/" + id);
    sendOsc(message);
  }
  
  void sendResponseStart(int id, float[] obs) {
    OscMessage message = new OscMessage("/qualia/response/start/" + id);
//    message.add(agentId); // id
    message.add(obs);     // observation
    sendOsc(message);
  }

  void sendResponseStep(int id, float[] obs) {
    OscMessage message = new OscMessage("/qualia/response/step/" + id);
 //   message.add(agentId); // id
    message.add(obs);     // observation
    sendOsc(message);
  }
  
  void qualiaInit(int id) {
    println("Qualia init: " + id);
    manager.init(id);
  }

  void qualiaStart(int id) {
    println("Qualia start: " + id);
    manager.start(id);
  }

  void qualiaStep(int id, int[] action) {
    manager.step(id, action);
  }
  
  // Controlled agent
  void sendAgentResponseInit(int id) {
    OscMessage message = new OscMessage("/qualia/agent/response/init/" + id);
    sendOsc(message);
  }
  
  void sendAgentResponseStart(int id, int[] actions) {
    OscMessage message = new OscMessage("/qualia/agent/response/start/" + id);
    message.add(actions);     // observation
    sendOsc(message);
  }

  void sendAgentResponseStep(int id, int[] actions) {
    OscMessage message = new OscMessage("/qualia/agent/response/step/" + id);
    message.add(actions);     // observation
    sendOsc(message);
  }
  
  void qualiaAgentInit(int id) {
    println("Qualia init: " + id);
    if (id != 0) {
      println("Agent controls only work for id=0");
    }
    sendAgentResponseInit(id);
//    manager.init(id);
  }

  void qualiaAgentStart(int id, float[] observation) {
    println("Qualia start: " + id);
    if (id != 0) {
      println("Agent controls only work for id=0");
    }
    sendAgentResponseStart(id, humanControlledAction);
  }

  void qualiaAgentStep(int id, float[] observation) {
    if (id != 0) {
      println("Agent controls only work for id=0");
    }
    sendAgentResponseStep(id, humanControlledAction);
  }


  void sendOsc(OscPacket packet) {
    for (NetAddress loc: remoteLocation)
      oscP5.send(packet, loc);
  }
  
  int extractId(OscMessage msg, String startPath) {
    return Integer.parseInt(msg.addrPattern().substring(startPath.length()+1));
  }
  
  void oscEvent(OscMessage msg)
  {
    println("OSC: " + msg);
    
    String pattern = msg.addrPattern();
    if (pattern.equals("/qualia/create"))
    {
      qualiaCreate(msg.get(0).intValue(), msg.get(1).intValue(), msg.get(2).intValue());
    }    
    else if (pattern.startsWith("/qualia/init"))
    {
      qualiaInit(extractId(msg, "/qualia/init"));
    }    
    else if (pattern.startsWith("/qualia/start"))
    {
      qualiaStart(extractId(msg, "/qualia/start"));
    }    
    else if (pattern.startsWith("/qualia/step"))
    {
      int id = extractId(msg, "/qualia/step");
//      println(manager.get(id).getActionDim());
      int[] action = new int[manager.get(id).getActionDim()];
      for (int i=0; i<action.length; i++)
        action[i] = msg.get(i).intValue();
      qualiaStep(id, action);
    }

    else if (pattern.startsWith("/qualia/agent/init")) {
      qualiaAgentInit(extractId(msg, "/qualia/agent/init"));
    }
    
    else if (pattern.startsWith("/qualia/agent/start")) {
//      println("qualia step");
      int id = extractId(msg, "/qualia/agent/start");
//      println(manager.get(id).getActionDim());
      float[] observation = new float[manager.get(id).getObservationDim()];
//      println(msg.arguments().length);
      for (int i=0; i<observation.length; i++) {
        observation[i] = msg.get(i).floatValue();
      }
//      println("COCO");
      qualiaAgentStart(id, observation);
    }
    
    else if (pattern.startsWith("/qualia/agent/step")) {
//      println("qualia step");
      int id = extractId(msg, "/qualia/agent/step");
//      println(manager.get(id).getActionDim());
      float[] observation = new float[manager.get(id).getObservationDim()];
//      println(msg.arguments().length);
      for (int i=0; i<observation.length; i++) {
        observation[i] = msg.get(i).floatValue();
      }
//      println("COCO");
      qualiaAgentStep(id, observation);
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
