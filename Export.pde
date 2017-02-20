ArrayList <Footage> agendaLib;
ArrayList <Footage> creditLib;
void export() {
  buildAgendaLib();
  
  XML _xml;
  _xml = new XML("xmeml");
  _xml.setString("version", "4");
  XML _xmlProject = _xml.addChild("project");
  _xmlProject.addChild("name").setContent("Test Export");
  XML _xmlChildren = _xmlProject.addChild("children");
  _xmlChildren.addChild(exportLib(agendaLib,"Lockwell_Agendas"));
  
  saveXML(_xml, "text.xml");
}

XML exportLib(ArrayList <Footage> _lib, String _name) {
  XML _ret;
  _ret = new XML("bin");
  _ret.addChild("name").setContent(_name);
  XML _children = _ret.addChild("children");
  
  for (int i=0; i < _lib.size(); i++) {
    Footage _tempF = _lib.get(i);
    XML _tempX = _children.addChild("clip");
    // clip ID
    // frameblend
    // uuid
    _tempX.addChild("masterclipid").setContent(_tempF.masterclip);
    _tempX.addChild("ismasterclip").setContent("TRUE");
    _tempX.addChild("duration").setContent("144");
    _tempX.addChild("name").setContent(_tempF.name);
    _tempX.addChild(footageToMediaXML(_tempF));
    
  }
  return _ret;
}

XML footageToMediaXML(Footage _f) {
  XML _ret = new XML("media");
  XML _video = _ret.addChild("video");
  XML _track = _video.addChild("track");
  XML _clip = _track.addChild("clipitem");
  
  _clip.addChild("name").setContent(_f.name);
  
  XML _file = _clip.addChild("file");
  
  _file.addChild("name").setContent(_f.name);
  _file.addChild("pathurl").setContent(_f.path);
  
  return _ret;
}

void buildAgendaLib() {
  String agendaPath = "file://localhost/C%3a/netrunner/important%20stuff/overlays2/";
  String fileTemplateL = "left_#.png";
  String fileTemplateR = "right_#.png";
  int min = 0;
  int max = 9;
  
  agendaLib = new ArrayList<Footage>();
  
  for (int i=min; i <= max; i++) {
    String fleL = fillInNumbers(fileTemplateL, i);
    String fleR = fillInNumbers(fileTemplateR, i);
    
    Footage tempFL = new Footage();
    tempFL.path = agendaPath + fleL;
    tempFL.name = fleL;
    tempFL.value = i;
    tempFL.side = LEFTPLAYER;
    
    Footage tempFR = tempFL.clone();
    tempFR.path = agendaPath + fleR;
    tempFR.name = fleR;
    tempFR.side = RIGHTPLAYER;
    
    agendaLib.add(tempFL);
    agendaLib.add(tempFR);
    println(fleL);
  }
  
  println("Generated " + agendaLib.size() + " AgendaLib entries.");
}

String fillInNumbers(String _s, int _n) {
  String ret = _s;
  String dblN = String.format("%1$02d", _n);
  String snlN = "" + _n;
  
  ret = ret.replaceAll("##", dblN);
  ret = ret.replaceAll("#", snlN);
  
  return ret;
}