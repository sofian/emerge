class EmergeEnvironment extends QualiaEnvironment {
  QualiaOscMunchkin munchkin;

  EmergeEnvironment(int id, int observationDim, int actionDim, QualiaOscMunchkin munchkin) {
    super(id, observationDim, actionDim);
    this.munchkin = munchkin;
  }
  
  void init() {
  }
  
  float[] start() {
    return munchkin.getObservation();
  }
  
  float[] step(int[] action) {
//    println(id + " -> (" + action[0] + "," + action[1] + ")");
    munchkin.addMoveForce(map((float)action[0], 0, N_ACTIONS_XY-1, -1., +1.),
                          map((float)action[1], 0, N_ACTIONS_XY-1, -1., +1.));
//    println("----");
//    println(munchkin.getObservation());
    return munchkin.getObservation();
  }
  
}

class EmergeEnvironmentManager extends QualiaEnvironmentManager {
  World world;
  EmergeEnvironmentManager(World world) {
    this.world = world;
  }
  QualiaEnvironment _doCreate(int id, int observationDim, int actionDim) {
    QualiaOscMunchkin munchkin = new QualiaOscMunchkin(Munchkin.BLUE,   (int)random(0,width), (int)random(0,height), MUNCHKIN_INITIAL_SIZE, MUNCHKIN_INITIAL_HEAT);
    world.addThing(munchkin);
    return new EmergeEnvironment(id, observationDim, actionDim, munchkin);
  }
}
