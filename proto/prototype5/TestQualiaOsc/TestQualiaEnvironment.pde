class TestQualiaEnvironment extends QualiaEnvironment {
  int state;
  
  int currentState() { return state; }
  
  TestQualiaEnvironment(int id, int observationDim, int actionDim) {
    super(id, observationDim, actionDim);
  }
  
  void init() {
    state = id;
  }
  
  float[] start() {
    float[] obs = new float[observationDim+1];
    for (int i=0; i<observationDim; i++)
      obs[i] = (float) state;
    return obs;
  }
  
  float[] step(int[] action) {
    for (int i=0; i<actionDim; i++)
      state += action[i];
    state %= 10;
    float[] obs = new float[observationDim+1];
    for (int i=0; i<observationDim; i++)
      obs[i] = (float) state;
    obs[observationDim] = action[0];
    return obs;
  }
  
}

class TestQualiaEnvironmentManager extends QualiaEnvironmentManager {
  QualiaEnvironment _doCreate(int id, int observationDim, int actionDim) {
    return new TestQualiaEnvironment(id, observationDim, actionDim);
  }
}
