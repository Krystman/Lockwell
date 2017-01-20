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
  myMovie.play();
  pauseOnRead = true;
  moviePaused = true;
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
    resetVData();
    loadVData();
    saveVData();
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
  XML _temp;
  CreditEvent _tempCEvent;
  AgendaEvent _tempAEvent;
  
  
  _xml = loadXML(vDataPath);
  
  XML _settingsNode = _xml.getChild("settings");
  XML _creditsNode = _xml.getChild("credits");
  XML _agendasNode = _xml.getChild("agendas");

  // ------ Load Settings -------
  // Set last head position
  setHead(_settingsNode.getChild("lastheadpos").getFloatContent());

  // ------ Load Credit Events -------
  // Get all credit events
  XML[] _credits = _creditsNode.getChildren("credit");
  
  // Recreate the Array for Credit Events
  for (int i = 0; i < _credits.length; i++) {
    _tempCEvent = new CreditEvent();
    _tempCEvent.time = _credits[i].getFloat("t");
    _tempCEvent.value = _credits[i].getIntContent();
    creditEvents.add(_tempCEvent);
  }
  
  // ------ Load Agenda Events -------
  // Get all agenda events
  XML[] _agendas = _agendasNode.getChildren("agenda");
  
  // Recreate the Array for Agenda Events
  for (int i = 0; i < _agendas.length; i++) {
    _tempAEvent = new AgendaEvent();
    _tempAEvent.time = _agendas[i].getFloat("t");
    _tempAEvent.value = _agendas[i].getIntContent();
    agendaEvents.add(_tempAEvent);
  }
  
  println("Loaded " + creditEvents.size() + " Credit Events");
  println("Loaded " + agendaEvents.size() + " Agenda Events");

  // Make a Bubble object out of the data read
  // bubbles[i] = new Bubble(x, y, diameter, label);

}

void saveVData() {
  println("Saving " + vDataPath);
  XML _xml;
  XML _temp;
  _xml = new XML("vdata");
  
  CreditEvent _tempCEvent;
  AgendaEvent _tempAEvent;

  XML _settingsNode = _xml.addChild("settings");
  XML _creditsNode = _xml.addChild("credits");
  XML _agendasNode = _xml.addChild("agendas");
  
  // ------ Save Settings -------
  // Save last head position
  _settingsNode.addChild("lastheadpos").setFloatContent(headPos);
  
  // ------ Save Credit Events -------
  // Loop through Credit Event array
  for (int i = 0; i < creditEvents.size(); i++) {
    _tempCEvent = creditEvents.get(i);
    _temp = _creditsNode.addChild("credit");
    _temp.setIntContent(_tempCEvent.value);
    _temp.setFloat("t", _tempCEvent.time);
  }
  
  // ------ Save Agenda Events -------
  // Loop through Agenda Event array
  for (int i = 0; i < agendaEvents.size(); i++) {
    _tempAEvent = agendaEvents.get(i);
    _temp = _agendasNode.addChild("agenda");
    _temp.setIntContent(_tempAEvent.value);
    _temp.setFloat("t", _tempAEvent.time);
  }
  
  // Save a new XML file
  saveXML(_xml, vDataPath);
}

void resetVData() {
  headPos = 0f;
  agendaEvents = new ArrayList<AgendaEvent>();
  creditEvents = new ArrayList<CreditEvent>();
}