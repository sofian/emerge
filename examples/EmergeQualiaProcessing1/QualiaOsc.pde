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
  
  boolean allMarked()
  {
    for (QualiaEnvironment e : instances.values())
	{
      if (!e.marked())
      {
        return false;
      }
    }
    return true;
  }
  
  void unmarkAll()
  {
    for (QualiaEnvironment e : instances.values())
      e.unmark();
  }
  
  void init(int id)
  {
    QualiaEnvironment e = get(id);
    e.mark();
    e.init();
  }
  
  void start(int id)
  {
    QualiaEnvironment e = get(id);
    e.mark();
    e.start();
  }
  
  void step(int id, int[] action)
  {
    QualiaEnvironment e = get(id);
    e.mark();
    e.step(action);
  }
  
  float[] getObservation(int id)
  {
    return get(id).getObservation();
  }
  
  abstract QualiaEnvironment _doCreate(int id, int observationDim, int actionDim);
}

// ******************************************************************
// This class handles all OSC communication to and from Qualia
// ******************************************************************
class QualiaOsc
{  
  OscP5 oscP5;
  Vector<NetAddress> qualiaOSCPipes; // communication channels with individual Qualia agents
  QualiaEnvironmentManager manager;

  // ============================================
  // Constructor
  // ============================================
  public QualiaOsc(int maxAgents, int port, int remotePort, String ip, QualiaEnvironmentManager manager)
  {
    println(port + " " + remotePort + " " + ip);
    oscP5 = new OscP5(this, port);
    qualiaOSCPipes = new Vector<NetAddress>();
    for (int i=0; i<maxAgents; i++)
    {
      qualiaOSCPipes.add(new NetAddress(ip, remotePort+i));
    }
    oscP5.plug(this, "emergeDonutAction", "/donut/1/action");
    
    this.manager = manager;
  }
  
  // ============================================
  // Setters & getters
  // ============================================
  QualiaEnvironmentManager getManager() { return manager; }

  // ============================================
  // Member functions
  // ============================================ 
  public void qualiaCreate(int agentId, int observationDim, int actionDim)
  {
    manager.create(agentId, observationDim, actionDim);
  }
  
  void sendResponseInit(int id)
  {
    OscMessage message = new OscMessage("/qualia/response/init/" + id);
    sendOsc(message);
  }
  
  void sendResponseStart(int id, float[] obs)
  {
    OscMessage message = new OscMessage("/qualia/response/start/" + id);
    message.add(obs);     // observation
    sendOsc(message);
  }

  void sendResponseStep(int id, float[] obs)
  {
    OscMessage message = new OscMessage("/qualia/response/step/" + id);
    message.add(obs);     // observation
    sendOsc(message);
  }
  
  void qualiaInit(int id)
  {
    println("Qualia init: " + id);
    manager.init(id);
  }

  void qualiaStart(int id)
  {
    println("Qualia start: " + id);
    manager.start(id);
  }

  void qualiaStep(int id, int[] action)
  {
    manager.step(id, action);
  }
  
  // Controlled agent
  void sendAgentResponseInit(int id)
  {
    OscMessage message = new OscMessage("/qualia/agent/response/init/" + id);
    sendOsc(message);
  }
  
  void sendAgentResponseStart(int id, int[] actions)
  {
    OscMessage message = new OscMessage("/qualia/agent/response/start/" + id);
    message.add(actions);     // observation
    sendOsc(message);
  }

  void sendAgentResponseStep(int id, int[] actions)
  {
    OscMessage message = new OscMessage("/qualia/agent/response/step/" + id);
    message.add(actions);     // observation
    sendOsc(message);
  }
  
  void qualiaAgentInit(int id)
  {
    println("Qualia init: " + id);
    if (id != 0)
	{
      println("Agent controls only work for id=0");
    }
    sendAgentResponseInit(id);
  }

  void qualiaAgentStart(int id, float[] observation)
  {
    println("Qualia start: " + id);
    if (id != 0)
	{
      println("Agent controls only work for id=0");
    }
    sendAgentResponseStart(id, humanControlledAction);
  }

  void qualiaAgentStep(int id, float[] observation)
  {
    if (id != 0)
	{
      println("Agent controls only work for id=0");
    }
    sendAgentResponseStep(id, humanControlledAction);
  }

  // Sends an OSC packet toall Qualia agents
  void sendOsc(OscPacket packet)
  {
    for (NetAddress loc: qualiaOSCPipes)
    {
      oscP5.send(packet, loc);
    }
  }
  
  int extractId(OscMessage msg, String startPath)
  {
    return Integer.parseInt(msg.addrPattern().substring(startPath.length()+1));
  }
  
  void oscEvent(OscMessage msg)
  {
    if (QUALIA_VERBOSE)
    {
      println("OSC: " + msg);
    }
    
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

    else if (pattern.startsWith("/qualia/agent/init"))
	{
      qualiaAgentInit(extractId(msg, "/qualia/agent/init"));
    }
    
    else if (pattern.startsWith("/qualia/agent/start"))
	{
//      println("qualia step");
      int id = extractId(msg, "/qualia/agent/start");
//      println(manager.get(id).getActionDim());
      float[] observation = new float[manager.get(id).getObservationDim()];
//      println(msg.arguments().length);
      for (int i=0; i<observation.length; i++)
	  {
        observation[i] = msg.get(i).floatValue();
      }
//      println("COCO");
      qualiaAgentStart(id, observation);
    }
    
    else if (pattern.startsWith("/qualia/agent/step"))
	{
//      println("qualia step");
      int id = extractId(msg, "/qualia/agent/step");
//      println(manager.get(id).getActionDim());
      float[] observation = new float[manager.get(id).getObservationDim()];
//      println(msg.arguments().length);
      for (int i=0; i<observation.length; i++)
	  {
        observation[i] = msg.get(i).floatValue();
      }
//      println("COCO");
      qualiaAgentStep(id, observation);
    }
  }
}

