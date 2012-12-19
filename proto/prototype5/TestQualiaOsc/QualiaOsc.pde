
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
  QualiaEnvironmentManager manager;

  QualiaOsc(int port, int remotePort, String ip, QualiaEnvironmentManager manager) {
    oscP5 = new OscP5(this, port);
    remoteLocation = new NetAddress(ip, remotePort);
    
    //oscP5.plug(this, "qualiaCreate", "/qualia/create");
    //oscP5.plug(this, "qualiaInit",   "/qualia/init");
    //oscP5.plug(this, "qualiaStart",  "/qualia/start");
    //oscP5.plug(this, "qualiaStep",   "/qualia/step");
    
    this.manager = manager;
  }
  
  QualiaEnvironmentManager getManager() { return manager; }

  public void qualiaCreate(int agentId, int observationDim, int actionDim) {
    manager.create(agentId, observationDim, actionDim);
    /*
    OscMessage message = new OscMessage("/qualia/response/create/" + agentId);
    message.add(id); // id
    sendOscMessage(message);*/
  }
  
  void qualiaInit(int id) {
    manager.get(id).init();
    OscMessage message = new OscMessage("/qualia/response/init/" + id);
    sendOscMessage(message);
  }

  void qualiaStart(int id) {
    println("Qualia start: " + id);
    float[] obs = manager.get(id).start();
    println("Observations to return: " + obs);
    OscMessage message = new OscMessage("/qualia/response/start/" + id);
//    message.add(agentId); // id
    message.add(obs);     // observation
    sendOscMessage(message);
  }

  void qualiaStep(int id, int[] action) {
    float[] obs = manager.get(id).step(action);
    OscMessage message = new OscMessage("/qualia/response/step/" + id);
 //   message.add(agentId); // id
    message.add(obs);     // observation
    sendOscMessage(message);
  }

  void sendOscMessage(OscMessage message) {
    oscP5.send(message, remoteLocation);
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
      qualiaInit(extractId(msg, "/qualia/init")); //<>//
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
