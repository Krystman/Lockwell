// Functions for File Input / Output

void loadHistory() {
  if (fileExists(dataPath("history.txt"))) {
    history = loadStrings(dataPath("history.txt"));
  } else {
    history = new String[0];
    saveHistory();
  }
}

void saveHistory() {
  saveStrings(dataPath("history.txt"), history);
}

boolean fileExists(String path) {
  File file=new File(path);
  return file.exists();
}

void loadMovie(String _f) {
  // Load a Movie
  
  println("Loading movie " + _f);
  if (!fileExists(_f)) {
    println("File Not Found");
    return;
  }
  moviePath = _f;
  myMovie = new Movie(this, _f);
  moviePaused = true;
  myMovie.play();
  myMovie.pause();
  myMovie.read();
  myMovie.jump(0);
  switchToEdit();
  logHistory(_f);
  
  // Load XML of Video Data
  
  // Derive Video Data filename from Movie Path
  vDataPath = moviePath.substring(0, moviePath.lastIndexOf('.')) + ".xml";

  // Check if XML for Video Data already exists
  if (!fileExists(vDataPath)) {
    println("vData does not exist");
    resetVData();
    saveVData();
  } else {
    println("vData is there!");
    loadVData();
  }
}

void logHistory(String _f) {
  int found = -1;
  _f = trim(_f);
  String tmp;
  for (int i = 0; i < history.length; i++) {
    if (_f.equals(history[i])) {
      found = i;
    }
  }
  
  if (found == -1) {
    if (history.length >= 12) {
      for (int i = 1; i <= history.length-1; i++) {
        history[i-1] = history[i];
      }
      history[history.length-1] = _f; 
    } else {
      history = append(history, _f);
    }
  } else {
    for (int i = history.length-1; i > found; i--) {
      tmp = history[found];
      history[found] = history[i];
      history[i] = tmp;
    }
  }
  saveHistory();
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    loadMovie(selection.getAbsolutePath());
  }
}

void loadVData() { 
 // Load XML file with Video Data
  println("Loading " + vDataPath);
  
  XML _xml; 
  _xml = loadXML(vDataPath);
  keyframes = new ArrayList<Keyframe>();
  
  XML _settingsNode = _xml.getChild("settings");
  XML _creditsNode = _xml.getChild("credits");
  XML _agendasNode = _xml.getChild("agendas");

  // ------ Load Settings -------
  // Set last head position
  setHead(_settingsNode.getChild("lastheadpos").getFloatContent());

  // ------ Load Credit Keyframes -------
  // Get all credit keyframes
  XML[] _credits = _creditsNode.getChildren("credit");
  
  // Fill Keyframe array with credit keyframes
  for (int i = 0; i < _credits.length; i++) {
    addKeyframe(KFCREDITS, _credits[i].getFloat("t"), _credits[i].getIntContent(), _credits[i].getInt("side"));
  }
  
  // ------ Load Agenda Events -------
  // Get all agenda events
  XML[] _agendas = _agendasNode.getChildren("agenda");
  
  // Fill Keyframe array with agenda keyframes
  for (int i = 0; i < _agendas.length; i++) {
    addKeyframe(KFAGENDAS, _agendas[i].getFloat("t"), _agendas[i].getIntContent(), _agendas[i].getInt("side"));
  }
  
  println("Loaded " + keyframes.size() + " Keyframes");
}

void saveVData() {
  println("Saving " + vDataPath);
  XML _xml;
  XML _temp;
  _xml = new XML("vdata");
  
  Keyframe _tempKeyframe;

  XML _settingsNode = _xml.addChild("settings");
  XML _creditsNode = _xml.addChild("credits");
  XML _agendasNode = _xml.addChild("agendas");
  
  // ------ Save Settings -------
  // Save last head position
  _settingsNode.addChild("lastheadpos").setFloatContent(headPos);

  // ------ Save Keyframes -------
  // Loop through Keyframes
  for (int i = 0; i < keyframes.size(); i++) {
    _temp = null;
    _tempKeyframe = keyframes.get(i);
    if (_tempKeyframe.type == KFCREDITS) {
      _temp = _creditsNode.addChild("credit");
    } else if (_tempKeyframe.type == KFAGENDAS) {
      _temp = _agendasNode.addChild("agenda");
    } else {
      println("Unknown keyframe type " + _tempKeyframe.type + "!!");
    }  
    if (_temp != null) {
      _temp.setIntContent(_tempKeyframe.value);
      _temp.setFloat("t", _tempKeyframe.time);
      _temp.setInt("side", _tempKeyframe.side);
    }
  }
  
  // Save a new XML file
  saveXML(_xml, vDataPath);
  dirty = false;
}

void resetVData() {
  //Resets the Video Data to a blank Template  
  headPos = 0f;
  keyframes = new ArrayList<Keyframe>();
  
  // Add starting values
  addKeyframe(KFCREDITS, 0.0, 5, LEFTPLAYER);
  addKeyframe(KFCREDITS, 0.0, 5, RIGHTPLAYER);
  
  addKeyframe(KFAGENDAS, 0.0, 0, LEFTPLAYER);
  addKeyframe(KFAGENDAS, 0.0, 0, RIGHTPLAYER);
}