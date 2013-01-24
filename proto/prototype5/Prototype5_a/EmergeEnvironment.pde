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
  
  // ============================================
  // Member functions
  // ============================================ 
  void init()
  {
  }
  
  float[] start()
  {
    return munchkin.getObservation();
  }
  
  float[] step(int[] action)
  {
//    if (id % 3 == 0) println(id + " -> (" + action[0] + "," + action[1] + ")");
    munchkin.addMoveForce(map((float)action[0], 0, N_ACTIONS_XY-1, -1., +1.),
                          map((float)action[1], 0, N_ACTIONS_XY-1, -1., +1.));
//    println("----");
//    println(munchkin.getObservation());

    //println(munchkin.getObservation());
    return munchkin.getObservation();
  }  
}

// ******************************************************************
// This class handles the creation of two types of agents: predator and prey
// ******************************************************************
class EmergeEnvironmentManager extends QualiaEnvironmentManager
{
  HashMap<Integer, Booth> booths;
  
  // ============================================
  // Constructor
  // ============================================
  EmergeEnvironmentManager(HashMap<Integer, Booth> booths)
  {
    this.booths = booths;
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
    /*
    // Create in every booth?
    Iterator it = booths.entrySet().iterator();    
    while (it.hasNext())
    {
      Map.Entry me = (Map.Entry)it.next();
      Booth booth = (Booth)me.getValue();
      booth.addThing(munchkin);
    }
    */
    booths.get(activeBooth).addThing(munchkin);
    println("Created munchking with ID " + id + " in booth " + activeBooth);
    
    return new EmergeEnvironment(id, observationDim, actionDim, munchkin);
  }
}
