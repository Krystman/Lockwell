ArrayList <Footage> agendaLib;
ArrayList <Footage> creditLib;
void export() {
  buildAgendaLib();
  
  //XML _xml;
  //_xml = new XML("vdata");
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