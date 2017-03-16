// Functions for File Input / Output

void loadHistory() {
  if (fileExists(dataPath("history.txt"))) {
    history = loadStrings(dataPath("history.txt"));
  } else {
    history = new String[0];
    saveHistory();
  }
}

void loadConfig() {
  println("Loading config");
  if (!fileExists(dataPath("config.xml"))) {
    println("Config not found. :( Will use Krystian's default values but export is likely to be all wrong.");
    
    expCreditsPath = "file://localhost/C%3a/netrunner/important%20stuff/credits/creditoverlays/";
    expCreditsLeft = "credL_##.png";
    expCreditsRight = "credR_##.png";
    expCreditsMax = 0;
    expCreditsMin = 42;
    
    expAgendasPath = "file://localhost/C%3a/netrunner/important%20stuff/overlays2/";
    expAgendasLeft = "left_#.png";
    expAgendasRight = "right_#.png";
    expAgendasMax = 0;
    expAgendasMin = 9;
    
  } else {   
    XML _xml; 
    _xml = loadXML(dataPath("config.xml"));
    
    XML _creditsNode = _xml.getChild("credits");
    XML _agendasNode = _xml.getChild("agendas");
  
    expCreditsPath = _creditsNode.getChild("path").getContent();
    expCreditsLeft = _creditsNode.getChild("left").getContent();
    expCreditsRight = _creditsNode.getChild("right").getContent();
    expCreditsMax = _creditsNode.getChild("max").getIntContent();
    expCreditsMin = _creditsNode.getChild("min").getIntContent();
    
    expAgendasPath = _agendasNode.getChild("path").getContent();
    expAgendasLeft = _agendasNode.getChild("left").getContent();
    expAgendasRight = _agendasNode.getChild("right").getContent();
    expAgendasMax = _agendasNode.getChild("max").getIntContent();
    expAgendasMin = _agendasNode.getChild("min").getIntContent();
    
    XML _animsNode = _xml.getChild("anims");
    XML[] _animNodes = _animsNode.getChildren("anim");
    
    expAnims = new ArrayList <AnimConfig>();
    
    if (_animNodes != null) {
      for (int i = 0; i < _animNodes.length; i++) {
        AnimConfig _tCfg = new AnimConfig();
        _tCfg.name = _animNodes[i].getChild("name").getContent();
        _tCfg.path = _animNodes[i].getChild("path").getContent();
        _tCfg.file = _animNodes[i].getChild("file").getContent();
        _tCfg.length = _animNodes[i].getChild("length").getIntContent();
        expAnims.add(_tCfg);
      }
    }
    //println(expAnims.size() + " anim configs");
  }
}

void saveHistory() {
  saveStrings(dataPath("history.txt"), history);
}

boolean fileExists(String path) {
  File file=new File(path);
  return file.exists();
}

void loadMovie(String _f, VideoContainer _vCon) {
  // Load a Movie

  File _thisFile = new File(_f);
  
  
  println("Loading movie " + _f);
  /*if (!fileExists(_f)) {
    println("File Not Found");
    return;
  }*/
  if (!_thisFile.exists()) {
    println(_f + " file not found");
    return;
  }
  if (!_thisFile.canRead()) {
    println("Cannot read " +_f);
    return;
  }
  if (!_thisFile.isFile()) {
    println(_f + " is not a file");
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

  _vCon.keyframes = null;
  _vCon.duration = myMovie.duration();
  _vCon.file = _thisFile.getName();
  _vCon.path = pathComponent(_thisFile.getAbsolutePath()) + File.separator;

  // Load XML of Video Data
  
  // Derive Video Data filename from Movie Path
  vDataPath = moviePath.substring(0, moviePath.lastIndexOf('.')) + ".lockwell";

  // Check if XML for Video Data already exists
  if (!fileExists(vDataPath)) {
    println("vData does not exist");
    resetVData();
    saveVData();
  } else {
    println("vData is there!");
    loadVData();
  }
  _vCon.keyframes = keyframes;
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
    videoCon = new VideoContainer();
    loadMovie(selection.getAbsolutePath(), videoCon);
  }
  frame.requestFocus();
  lastNoClick = true;
  mousePressed = false;
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
  XML _commentsNode = _xml.getChild("comments");
  XML _animNode = _xml.getChild("anims");
  
  // ------ Load Settings -------
  // Set last head position
  setHead(_settingsNode.getChild("lastheadpos").getFloatContent());

  // ------ Load Credit Keyframes -------
  // Get all credit keyframes
  if (_creditsNode != null) {
    XML[] _credits = _creditsNode.getChildren("credit");
    
    // Fill Keyframe array with credit keyframes
    for (int i = 0; i < _credits.length; i++) {
      addKeyframe(KFCREDITS, _credits[i].getFloat("t"), _credits[i].getIntContent(), _credits[i].getInt("side"), "");
    }
  }
  
  // ------ Load Agenda Events -------
  // Get all agenda events
  if (_agendasNode != null) {
    XML[] _agendas = _agendasNode.getChildren("agenda");
    
    // Fill Keyframe array with agenda keyframes
    for (int i = 0; i < _agendas.length; i++) {
      addKeyframe(KFAGENDAS, _agendas[i].getFloat("t"), _agendas[i].getIntContent(), _agendas[i].getInt("side"), "");
    }
  }
  
  // ------ Load Comment Events -------
  // Get all agenda events
  if (_commentsNode != null) {
    XML[] _comments = _commentsNode.getChildren("comment");
    
    // Fill Keyframe array with comment keyframes
    for (int i = 0; i < _comments.length; i++) {
      addKeyframe(KFCOMMENTS, _comments[i].getFloat("t"), 0, LEFTPLAYER, _comments[i].getContent());
    }
  }
  
  // ------ Load Anim Events -------
  // Get all agenda events
  if (_animNode != null) {
    XML[] _anims = _animNode.getChildren("anim");
    
    // Fill Keyframe array with comment keyframes
    for (int i = 0; i < _anims.length; i++) {
      Keyframe tKf = addKeyframe(KFANIMS, _anims[i].getFloat("t"), 0, _anims[i].getInt("side"), _anims[i].getContent());
      tKf.duration = getAnimLength(tKf.stringValue);
    }
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
  XML _commentsNode = _xml.addChild("comments");
  XML _animNode = _xml.addChild("anims");
  
  // ------ Save Settings -------
  // Save last head position
  if (videoCon != null) {
    _settingsNode.addChild("duration").setFloatContent(videoCon.duration);
    _settingsNode.addChild("file").setContent(videoCon.file);
    _settingsNode.addChild("path").setContent(videoCon.path);
  } else if (myMovie != null) {
    _settingsNode.addChild("duration").setFloatContent(myMovie.duration());
  }
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
    } else if (_tempKeyframe.type == KFCOMMENTS) {
      _temp = _commentsNode.addChild("comment");
    } else if (_tempKeyframe.type == KFANIMS) {
      _temp = _animNode.addChild("anim");
    } else {
      println("Unknown keyframe type " + _tempKeyframe.type + "!!");
    }  
    if (_temp != null) {
      _temp.setFloat("t", _tempKeyframe.time);
      if (_tempKeyframe.type == KFCOMMENTS) {
        _temp.setContent(_tempKeyframe.stringValue);
      } else if (_tempKeyframe.type == KFANIMS) {
        _temp.setContent(_tempKeyframe.stringValue);
        _temp.setInt("side", _tempKeyframe.side);
      } else {
        _temp.setIntContent(_tempKeyframe.value);
        _temp.setInt("side", _tempKeyframe.side);
      }
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
  addKeyframe(KFCREDITS, 0.0, 5, LEFTPLAYER, "");
  addKeyframe(KFCREDITS, 0.0, 5, RIGHTPLAYER, "");
  
  addKeyframe(KFAGENDAS, 0.0, 0, LEFTPLAYER, "");
  addKeyframe(KFAGENDAS, 0.0, 0, RIGHTPLAYER, "");
}

public String pathComponent(String filename) {
  int i = filename.lastIndexOf(File.separator);
  return (i > -1) ? filename.substring(0, i) : filename;
}