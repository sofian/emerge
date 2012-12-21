class EmergeQualiaOsc extends QualiaOsc {
  
  public EmergeQualiaOsc(int port, int remotePort, String ip, QualiaEnvironmentManager manager) {
    super(port, remotePort, ip, remotePort, ip, manager); // dummy
    println("Construct");
  }
    
  void emergeSendMunchkinInfo(int id, Munchkin m) {
    OscBundle bundle = new OscBundle();

    OscMessage msgXY = new OscMessage("/munchkin/" + id + "/xy");
    msgXY.add(m.x()/width);
    msgXY.add(m.y()/height);
    bundle.add(msgXY);
    
    OscMessage msgSize = new OscMessage("/munchkin/" + id + "/size");
    msgSize.add(m.size());
    bundle.add(msgSize);

    OscMessage msgHeat = new OscMessage("/munchkin/" + id + "/heat");
    msgHeat.add(m.getHeat());
    bundle.add(msgHeat);
    
    sendOsc(bundle);
  }


}
