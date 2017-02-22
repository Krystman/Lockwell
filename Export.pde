ArrayList <Footage> agendaLib;
ArrayList <Footage> creditLib;

int idCounter;

void export() {
  idCounter = 1;
  
  buildAgendaLib();
  buildCreditLib();
  
  XML _xml;
  _xml = new XML("xmeml");
  _xml.setString("version", "4");
  XML _xmlProject = _xml.addChild("project");
  _xmlProject.addChild("name").setContent("Test Export");
  XML _xmlChildren = _xmlProject.addChild("children");
  _xmlChildren.addChild(exportLib(agendaLib,"Lockwell - Agendas"));
  _xmlChildren.addChild(exportLib(creditLib,"Lockwell - Credits"));
  
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
    _tempX.setString("id", _tempF.masterclipid);
    _tempX.setString("frameBlend", "FALSE");
    _tempX.addChild("masterclipid").setContent(_tempF.masterclipid);
    _tempX.addChild("ismasterclip").setContent("TRUE");
    _tempX.addChild("duration").setContent("150");
    _tempX.addChild(rateXML());
    _tempX.addChild("name").setContent(_tempF.name);
    
    XML _tempM = _tempX.addChild("media");
    XML _video = _tempM.addChild("video");
    XML _track = _video.addChild("track");
    
    XML _clip = _track.addChild("clipitem");
    _clip.setString("id", _tempF.clipitemid);
    _clip.setString("frameBlend", "FALSE");
    _clip.addChild("masterclipid").setContent(_tempF.masterclipid);
    _clip.addChild("name").setContent(_tempF.name);
    
    XML _file = _clip.addChild("file"); 
    _file.setString("id", _tempF.fileid);
    _file.addChild("name").setContent(_tempF.name);
    _file.addChild("pathurl").setContent(_tempF.path);
    _file.addChild(rateXML());
    _file.addChild(mediaXML());
  }
  return _ret;
}

XML rateXML() {
  XML _ret = new XML("rate");
  _ret.addChild("timebase").setContent("30");
  _ret.addChild("ntsc").setContent("TRUE"); 
  return _ret;
}

XML mediaXML() {
  XML _ret = new XML("media");
  XML _video = _ret.addChild("video");
  
  _video.addChild("duration").setContent("18000");
  XML _stics = _video.addChild("samplecharacteristics");
  _stics.addChild(rateXML());
  _stics.addChild("width").setContent("1920");
  _stics.addChild("height").setContent("1080");
  _stics.addChild("anamorphic").setContent("FALSE");
  _stics.addChild("pixelaspectratio").setContent("square");
  _stics.addChild("fielddominance").setContent("none");
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
    tempFL.clipitemid = "clipitem-" + idCounter;
    tempFL.fileid = "file-" + idCounter;
    tempFL.masterclipid = "masterclip-" + idCounter;
    idCounter++;
    
    Footage tempFR = tempFL.clone();
    tempFR.path = agendaPath + fleR;
    tempFR.name = fleR;
    tempFR.side = RIGHTPLAYER;
    tempFR.clipitemid = "clipitem-" + idCounter;
    tempFR.fileid = "file-" + idCounter;
    tempFR.masterclipid = "masterclip-" + idCounter;
    idCounter++;
    
    agendaLib.add(tempFL);
    agendaLib.add(tempFR);
  }
  
  //println("Generated " + agendaLib.size() + " AgendaLib entries.");
}

void buildCreditLib() {
  String creditPath = "file://localhost/C%3a/netrunner/important%20stuff/credits/creditoverlays/";
  String fileTemplateL = "credL_##.png";
  String fileTemplateR = "credR_##.png";
  int min = 0;
  int max = 42;
  
  creditLib = new ArrayList<Footage>();
  
  for (int i=min; i <= max; i++) {
    String fleL = fillInNumbers(fileTemplateL, i);
    String fleR = fillInNumbers(fileTemplateR, i);
    
    Footage tempFL = new Footage();
    tempFL.path = creditPath + fleL;
    tempFL.name = fleL;
    tempFL.value = i;
    tempFL.side = LEFTPLAYER;
    tempFL.clipitemid = "clipitem-" + idCounter;
    tempFL.fileid = "file-" + idCounter;
    tempFL.masterclipid = "masterclip-" + idCounter;
    idCounter++;
    
    Footage tempFR = tempFL.clone();
    tempFR.path = creditPath + fleR;
    tempFR.name = fleR;
    tempFR.side = RIGHTPLAYER;
    tempFR.clipitemid = "clipitem-" + idCounter;
    tempFR.fileid = "file-" + idCounter;
    tempFR.masterclipid = "masterclip-" + idCounter;
    idCounter++;
    
    creditLib.add(tempFL);
    creditLib.add(tempFR);
  }
  
  println("Generated " + agendaLib.size() + " CreditLib entries.");
}

String fillInNumbers(String _s, int _n) {
  String ret = _s;
  String dblN = String.format("%1$02d", _n);
  String snlN = "" + _n;
  
  ret = ret.replaceAll("##", dblN);
  ret = ret.replaceAll("#", snlN);
  
  return ret;
}