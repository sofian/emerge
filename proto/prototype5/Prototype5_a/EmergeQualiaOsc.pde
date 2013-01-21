class EmergeQualiaOsc extends QualiaOsc {
  
  public EmergeQualiaOsc(int port, int remotePort, String ip, QualiaEnvironmentManager manager) {
    super(port, remotePort, ip, remotePort, ip, manager); // dummy
    println("Construct");
  }
    
  void emergeSendMunchkinInfo(int id, Munchkin m) {
    OscMessage msg = new OscMessage("/munchkin");
    msg.add(id);
    msg.add(m.x()/width);
    msg.add(m.y()/height);
    msg.add(m.size());
    msg.add(m.getHeat());
    sendOsc(msg);
  }


}
