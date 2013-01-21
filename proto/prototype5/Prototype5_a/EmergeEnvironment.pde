class EmergeEnvironment extends QualiaEnvironment {
  QualiaOscMunchkin munchkin;

  EmergeEnvironment(int id, int observationDim, int actionDim, QualiaOscMunchkin munchkin) {
    super(id, observationDim, actionDim);
    this.munchkin = munchkin;
  }
  
  QualiaOscMunchkin getMunchkin() { return munchkin; }
  
  void init() {
  }
  
  float[] start() {
    return munchkin.getObservation();
  }
  
  float[] step(int[] action) {
//    if (id % 3 == 0) println(id + " -> (" + action[0] + "," + action[1] + ")");
    munchkin.addMoveForce(map((float)action[0], 0, N_ACTIONS_XY-1, -1., +1.),
                          map((float)action[1], 0, N_ACTIONS_XY-1, -1., +1.));
//    println("----");
//    println(munchkin.getObservation());

    //println(munchkin.getObservation());
    return munchkin.getObservation();
  }
  
}

class EmergeEnvironmentManager extends QualiaEnvironmentManager {
  World world;
  EmergeEnvironmentManager(World world) {
    this.world = world;
  }
  QualiaEnvironment _doCreate(int id, int observationDim, int actionDim) {
    QualiaOscMunchkin munchkin;
    if (id % 2 == 0) {
      // Even munchkins have one behaviour
      munchkin = new QualiaOscMunchkin(Thing.RED, (int)random(50,width/2), (int)random(50,height-50), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT);
    }
    else {
      // Odd munchkins have another behaviour
      munchkin = new QualiaOscMunchkin(Thing.BLUE, (int)random(width/2,width-50), (int)random(50,height-50), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT);
    }
    world.addThing(munchkin);
    return new EmergeEnvironment(id, observationDim, actionDim, munchkin);
  }
}
