// ******************************************************************
// This class implements an environment, as observable by an agent.
// ******************************************************************
class EmergeEnvironment extends QualiaEnvironment
{
  QualiaOscMunchkin munchkin;

  // ============================================
  // Constructor
  // ============================================
  EmergeEnvironment(int id, int observationDim, int actionDim, QualiaOscMunchkin munchkin)
  {
    super(id, observationDim, actionDim);
    this.munchkin = munchkin;
  }
  
  // ============================================
  // Setters & getters
  // ============================================  
  QualiaOscMunchkin getMunchkin() { return munchkin; }
  
  float[] getObservation() { return munchkin.getObservation(); }

  // ============================================
  // Member functions
  // ============================================ 
  void init()
  {
  }
  
  void start() {
  }
  
  void step(int[] action)
  {
    if (id % 3 == 0) println(id + " -> (" + action[0] + "," + action[1] + ")");
    float fx = map((float)action[0], 0, N_ACTIONS_XY-1, -1., +1.);
    float fy = map((float)action[1], 0, N_ACTIONS_XY-1, -1., +1.);
    munchkin.addMoveForce(fx, fy);
    println( (munchkin.getNation() == Thing.RED ? "red" : "blue") + " := (" + fx + "," + fy + ") -> " +   munchkin.getReward());
  }
}

// ******************************************************************
// This class handles the creation of two types of agents: predator and prey
// ******************************************************************
class EmergeEnvironmentManager extends QualiaEnvironmentManager
{
  World world;

  // ============================================
  // Constructor
  // ============================================
  EmergeEnvironmentManager(World world) {
    this.world = world;
  }
  
  // ============================================
  // Member functions
  // ============================================
  QualiaEnvironment _doCreate(int id, int observationDim, int actionDim)
  {
    QualiaOscMunchkin munchkin;
    if (id % 2 == 0)
    {
      // Even munchkins have one behaviour
      munchkin = new QualiaOscMunchkin(Thing.RED, (int)random(50,width/2), (int)random(50,height-50), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT);
    }
    else
    {
      // Odd munchkins have another behaviour
      munchkin = new QualiaOscMunchkin(Thing.BLUE, (int)random(width/2,width-50), (int)random(50,height-50), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT);
    }
    world.addThing(munchkin);
    println("Created munchking with ID " + id + " in booth " + BOOTHID);
  
    return new EmergeEnvironment(id, observationDim, actionDim, munchkin);
  }
}
