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

// ******************************************************************
// This class listens (server) to OSC commands about donut logins at other booths
// and sends (client) the position of things to the logic server (Max/MSP)
// ******************************************************************
class LogicOscClientServer
{  
  OscP5 oscP5;
  NetAddress serverLocation;  

  // ============================================
  // Constructor
  // ============================================
  public LogicOscClientServer(String ip, int portIn, int portOut)
  {
    oscP5 = new OscP5(this, portIn); // listen to instructions telling us that a donut has logged in somewhere else
    // Sample incoming message: /booth1/donutLogin 2 3
    oscP5.plug(this, "parseDonutLogin", "/booth" + BOOTHID + "/donutLogin");
    serverLocation = new NetAddress(ip, portOut);
  }
  
  // ============================================
  // Member functions
  // ============================================ 
  void parseDonutLogin(int donutID, int boothID)
  {
    if (boothID == BOOTHID)
    {
      // Ignore because donut login at the current booth should be handled by the fiducial server, not by information coming from the logic
      return;
    }
    Donut d = world.donuts.get(donutID);
    if (d != null)
    {
      world.donutsToRemove.add(d);
      println("The donut with ID " + d.ID + " has been scheduled for deletion");
    }
  }
  
  // NOTE: This should have been in EmergeQualiaOsc but the super() call doesn't work and I don't know why.
  void emergeSendMunchkinInfo(int id, Munchkin m)
  {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/munchkin");
    msg.add(id);
    msg.add(m.x()/width);
    msg.add(m.y()/height);
    msg.add(m.size());
    msg.add(m.getHeat());
    oscP5.send(msg, serverLocation);
  }

  // Send the physics-based donut coordinates
  void sendDonutPhysics(Donut d)
  {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/donut/xyphysics");
    msg.add(d.ID);
    msg.add(d.getX()/width);
    msg.add(d.getY()/height);
    oscP5.send(msg, serverLocation);
  }
  
  void sendBoothLogin(Donut d, boolean b)
  {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/login");
    msg.add(d.ID);
    if (b)
    {
      msg.add(1);
    }
    else
    {
      msg.add(0);
    }
    oscP5.send(msg, serverLocation);
  }
}

// ******************************************************************
// This class listens (server) to TUIO data from the fiducial tracker
// and sends (client) donut login information to the other booths ******************************************************************
class FiducialOscClientServer
{  
  OscP5 oscP5;

  // ============================================
  // Constructor: client port is DONUT_LOGIN_PORT
  // ============================================
  public FiducialOscClientServer(String ip, int portIn)
  {
    oscP5 = new OscP5(this, portIn);
    // Sample incoming message: /tuio/3Dobj set 0 3 0.408413 0.615067 0.106812 2.649051 0.823067 5.236993 0. 0. 0. 0. 0. 0. 0. 0.
    oscP5.plug(this, "parseFiducialInput", "/tuio/3Dobj");
  }
  
  // ============================================
  // Member functions
  // ============================================
  void parseFiducialInput(String instruction, int sessionID, int markerID, float posX, float posY, float posZ, float xyAngle, float zxAngle, float yzAngle, float velX, float velY, float velZ, float rotVelX, float rotVelY, float rotVelZ, float mAccel, float rAccel)
  {
    // only listen to 'set' commands
    if (instruction.equals("set"))
    {
      // Flip X axis to implement mirror when compared to user
      posX = 1 - posX;
      int newX = (int)constrain(map(posX, 0., 1., 0, width), 0, width-1);
      int newY = (int)constrain(map(posY, 0., 1., 0, height), 0, height-1);
      
      // See if the donut already exists
      Donut thisDonut = world.donuts.get(markerID);
      if (thisDonut == null)
      {
        thisDonut = new Donut(markerID);
        float initialX = -10;
        float initialY = random(1.0) * height;
        thisDonut.setPosition(initialX, initialY);
        thisDonut.setTargetPosition(newX, newY);
        world.addDonut(thisDonut);
        println("Donut " + thisDonut.ID + " has just logged in to booth " + BOOTHID);
        
        // Inform the other booths of a login here, so they can log out the related donuts if they are at said booths
        String prefix = "192.168.168.";
        for (int i=1; i <= TOTAL_BOOTHS; i++)
        {
          if (i != BOOTHID)
          {
            String suffix = Integer.toString(200 + i);
            String address = prefix + suffix;  
            NetAddress toBooth = new NetAddress(address, DONUT_LOGIN_PORT); 
            OscMessage msg = new OscMessage("/booth" + i + "/donutLogin");
            msg.add(thisDonut.ID);
            msg.add(BOOTHID);
            oscP5.send(msg, toBooth);   
            println("Sent login info to address: " + address + " as " + msg.addrPattern());
          }
        }       
      }
      else
      {
        thisDonut.setTargetPosition(newX, newY);
        if (thisDonut.soundLoggedOut)
        {
          thisDonut.soundLoggedOut = false;
          println("Donut " + thisDonut.ID + " has reappeared at booth " + BOOTHID + " after logging out from the sound system");
        }
      }
    }
  }
}

// ******************************************************************
// This class handles all OSC communication to the sound system
// ******************************************************************
class SoundOscClient extends LogicOscClientServer
{
  // ============================================
  // Constructor
  // ============================================
  public SoundOscClient(String ip, int portOut)
  {
    super(ip, 0, portOut);
  }
  
  // ============================================
  // Member functions
  // ============================================ 
  void sendBoothLogin(Donut d, boolean b)
  {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/donut/logon");
    msg.add(d.ID);
    if (b)
    {
      msg.add(1);
    }
    else
    {
      msg.add(0);
    }
    oscP5.send(msg, serverLocation);
  }
  
  void sendDonutContact(Donut d1, Donut d2, float x, float y)
  {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/donutContact");
    msg.add(d1.ID);
    msg.add(d2.ID);
    msg.add(x/width);
    msg.add(y/height);
    oscP5.send(msg, serverLocation);
    //println("Contact between donuts " + d1.ID + " and " + d2.ID + " at " + x + ", " + y);
  }
  
  void sendDonutThresholdLogout(Donut d)
  {
    OscMessage msg = new OscMessage("/booth" + String.valueOf(BOOTHID) + "/donutLogout");
    msg.add(d.ID);
    oscP5.send(msg, serverLocation);
    println("Donuts " + d.ID + " is being logged out from the sound system");
  }
}
