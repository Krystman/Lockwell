ArrayList <Footage> agendaLib;
ArrayList <Footage> creditLib;
ArrayList <Footage> otherLib;
Footage blankFootage;

int idCounter;
int idCounterSeq;

// Variables for export settings
String expCreditsPath;
String expCreditsLeft;
String expCreditsRight;
int expCreditsMax;
int expCreditsMin;
  
String expAgendasPath;
String expAgendasLeft;
String expAgendasRight;
int expAgendasMax;
int expAgendasMin;
ArrayList <AnimConfig> expAnims;

long premiereFrame = 8475667200L; // Weird-ass Premiere unit. This is how long a single frame is when specificing Workspace In/Out. FML. 

void export(String _path) {
  loadConfig();
    
  println("Exporting to " + _path);

  idCounter = 1;
  idCounterSeq = 1;
  
  buildAnimLib();  
  blankFootage = new Footage();
  blankFootage.path = "";
  blankFootage.name = "BLANK";
  blankFootage.value = 0;
  blankFootage.side = LEFTPLAYER;
  blankFootage.duration = 18000;
  blankFootage.clipitemid = "clipitem-" + idCounter;
  blankFootage.fileid = "file-" + idCounter;
  blankFootage.masterclipid = "masterclip-" + idCounter;
  idCounter++;
  otherLib.add(blankFootage);
  
  buildAgendaLib();
  buildCreditLib();

  XML _xml;
  _xml = new XML("xmeml");
  _xml.setString("version", "4");
  XML _xmlProject = _xml.addChild("project");
  _xmlProject.addChild("name").setContent("Test Export");
  XML _xmlChildren = _xmlProject.addChild("children");
  _xmlChildren.addChild(exportLib(agendaLib, "Lockwell - Agendas"));
  _xmlChildren.addChild(exportLib(creditLib, "Lockwell - Credits"));
  _xmlChildren.addChild(exportLib(otherLib, "Lockwell - Other"));

  // Actually export Timeline
  if (videoCon == null) {
    println("No videoCon!");
  } else {
    _xmlChildren.addChild(exportTimeline(videoCon, "Test Sequence"));
  }

  saveXML(_xml, _path);
  println("Export done");
}

XML exportTimeline(VideoContainer _vCon, String _name) {
  int aniCount = 1;
  ArrayList <Keyframe> _aniLeftOvers = null;
  XML _ret;
  _ret = new XML("sequence");
  _ret.setString("id", "sequence-" + idCounterSeq);
  idCounterSeq++;
  long frames = int(_vCon.duration * 29.97);
  _ret.setString("MZ.WorkOutPoint", String.format("%d",premiereFrame * frames));
  _ret.setString("MZ.WorkInPoint", "0");

  _ret.addChild("name").setContent(_name);
  _ret.addChild("duration").setContent("0");
  _ret.addChild(rateXML());

  XML _media = _ret.addChild("media");
  XML _video = _media.addChild("video");
  _video.addChild("format").addChild(sticsXML());

  XML _track;

  _track = _video.addChild("track");
  _track.setString("MZ.TrackName", "Video");
  _track.addChild("enabled").setContent("TRUE");
  _track.addChild("locked").setContent("FALSE");

  _track = _video.addChild("track");
  _track.setString("MZ.TrackName", "Credits R");
  _track.addChild("enabled").setContent("TRUE");
  _track.addChild("locked").setContent("FALSE");
  keyframesToClips(_track, _vCon, RIGHTPLAYER, KFCREDITS, null);

  _track = _video.addChild("track");
  _track.setString("MZ.TrackName", "Credits L");
  _track.addChild("enabled").setContent("TRUE");
  _track.addChild("locked").setContent("FALSE");
  keyframesToClips(_track, _vCon, LEFTPLAYER, KFCREDITS, null);

  _track = _video.addChild("track");
  _track.setString("MZ.TrackName", "Agendas R");
  _track.addChild("enabled").setContent("TRUE");
  _track.addChild("locked").setContent("FALSE");
  keyframesToClips(_track, _vCon, RIGHTPLAYER, KFAGENDAS, null);

  _track = _video.addChild("track");
  _track.setString("MZ.TrackName", "Agendas L");
  _track.addChild("enabled").setContent("TRUE");
  _track.addChild("locked").setContent("FALSE");
  keyframesToClips(_track, _vCon, LEFTPLAYER, KFAGENDAS, null);
  
  // Export animations
  do {
    _track = _video.addChild("track");
    _track.setString("MZ.TrackName", "Anims " + aniCount);
    _track.addChild("enabled").setContent("TRUE");
    _track.addChild("locked").setContent("FALSE");
    _aniLeftOvers = keyframesToClips(_track, _vCon, BOTHPLAYERS, KFANIMS, _aniLeftOvers);
    aniCount = aniCount + 1;
  } while (_aniLeftOvers.size() > 0);

  _track = _video.addChild("track");
  _track.setString("MZ.TrackName", "Notes");
  _track.addChild("enabled").setContent("TRUE");
  _track.addChild("locked").setContent("FALSE");
  keyframesToClips(_track, _vCon, LEFTPLAYER, KFCOMMENTS, null);

  XML _audio = _media.addChild("audio");
  XML _audioFormat = _audio.addChild("format");
  XML _audioFormatChar = _audioFormat.addChild("samplecharacteristics");
  _audioFormatChar.addChild("depth").setContent("16");
  _audioFormatChar.addChild("samplerate").setContent("48000");

  return _ret;
}

ArrayList <Keyframe> keyframesToClips(XML _track, VideoContainer _vCon, int _sideFilter, int _typeFilter, ArrayList <Keyframe> _lastLeftOvers) {
  // Outputs keyframes of a specific type to an XML parent
  // Returns leftover keyframes if one track wasn't enough
  // The latter is used for animations
  
  // Warning. This has grown to be a bit of Spaghetti Code.
  Keyframe _tempF1 = null;
  Keyframe _tempF2 = null;
  Keyframe _tempF3 = null;
  
  int frameIn;
  int frameOut;
  int frameIn2;
  int frameOut2;
  int frameLength;
  
  Boolean overlap = false;
  
  Footage _footage;
  ArrayList <Keyframe> _kf ;
  ArrayList <Footage> _lib;
  ArrayList <Keyframe> _filtered;
  ArrayList <Keyframe> _leftOvers = new ArrayList <Keyframe>();
  
  if (_lastLeftOvers != null) {
    _kf = _lastLeftOvers;
    _filtered = _lastLeftOvers;
  } else {
    _kf = _vCon.keyframes;
    
    // Get a filtered Arraylist
    _filtered = filterKeyframes(_kf, _sideFilter, _typeFilter);
  
    // Sort by time
    sortByTime(_filtered);
  }
  
  if (_typeFilter == KFAGENDAS) {
    _lib = agendaLib;
  } else if (_typeFilter == KFCREDITS) {
    _lib = creditLib;
  } else if (_typeFilter == KFCOMMENTS) {
    _lib = null;
  } else if (_typeFilter == KFANIMS) {
    _lib = otherLib;
  } else {
    println("Can't keyframesToClips. Unknown type Filter " + _typeFilter);
    return null;
  }

  if (_filtered != null) {

    // Add an empty terminator keyframe to calulate length of the last segment
    Keyframe _tkf = new Keyframe();
    _tkf.time = _vCon.duration;
    _tkf.type = _typeFilter;
    _tkf.side = _sideFilter;
    _tkf.value = 0;
    _filtered.add(_tkf);

    for (int i = 0; i < _filtered.size()-1; i++) {
      overlap = false;
      _tempF1 = _filtered.get(i);
      _tempF2 = _filtered.get(i+1);
      frameIn = int(_tempF1.time * 29.97);
      frameOut = int(_tempF2.time * 29.97);
      
      if (_typeFilter == KFCOMMENTS) {
        frameOut = int((_tempF1.time+1.0f) * 29.97);
      } else if (_typeFilter == KFANIMS) {
        frameOut = frameIn + round(_tempF1.duration * 29.97);
      }

      if (frameIn != frameOut) {
        frameLength = frameOut - frameIn;
        _footage = null;
        if (_typeFilter == KFCOMMENTS) {
          _footage = blankFootage;
        } else if (_typeFilter == KFANIMS) {     
          // If Animation, check if it overlaps with a previous animation
          if (i > 0) { //<>// //<>// //<>//
            for (int j = 0; j < i; j++) {
              _tempF3 = _filtered.get(j);
              frameIn2 = int(_tempF3.time * 29.97);
              frameOut2 = frameIn2 + int(_tempF3.duration * 29.97);
              if ((frameIn2 < frameIn && frameOut2 > frameIn) || (frameIn2 >= frameIn && frameIn2 < frameOut)) {
                // Current animation is overlapping with a previous one.
                // Put this into the leftover ArrayList
                _leftOvers.add(_tempF1);
                overlap = true;
                break;
              }
            }
          }
          
          // Now find the clip associated with the keyframe
          if (!overlap) {
            for (int j = 0; j < _lib.size() && _footage == null; j++) {
              _footage = _lib.get(j);
              if (_footage.stringValue.equals(_tempF1.stringValue) == false) {
                _footage = null;
              }
            }
            if (_footage != null) {
              frameOut = frameIn + _footage.duration;
              frameLength = _footage.duration;
            }
          }
        } else {
          for (int j = 0; j < _lib.size() && _footage == null; j++) {
            _footage = _lib.get(j);
            if (_footage.value != _tempF1.value || _footage.side != _tempF1.side) {
              _footage = null;
            }
          }
        }
        if (_footage == null && !overlap) {
          println("Problems in keyframesToClips. Can't find value " + _tempF1.value + " for type " + _typeFilter + " for side " + _tempF1.side);
        } else if (!overlap) {
          XML _clipItem = _track.addChild("clipitem");
          _clipItem.addChild("masterclipid").setContent(_footage.masterclipid);
          if (_typeFilter == KFCOMMENTS) {
            _clipItem.addChild("name").setContent(_tempF1.stringValue);
            _clipItem.addChild("enabled").setContent("TRUE");
          } else {
            _clipItem.addChild("name").setContent(_footage.name);
            _clipItem.addChild("enabled").setContent("TRUE");
          }
          _clipItem.addChild("start").setContent("" + frameIn);
          _clipItem.addChild("end").setContent("" + frameOut);
          if (_typeFilter != KFCOMMENTS && _typeFilter != KFANIMS) {
            _clipItem.addChild("in").setContent("120");
            _clipItem.addChild("out").setContent("" + (120 + frameLength));
          } else {
            _clipItem.addChild("in").setContent("0");
            _clipItem.addChild("out").setContent("" + frameLength);
            _clipItem.addChild("duration").setContent("" + frameLength);
          }
          _clipItem.addChild("alphatype").setContent("straight");
          _clipItem.addChild("file").setString("id", _footage.fileid);
          
          // Add transform filter if clip is supposed to appear at a certain postion
          if (_tempF1.x != 0.0 || _tempF1.y != 0.0) {
            _clipItem.addChild(filterXML(_tempF1.x, _tempF1.y));
          }
        }
      }
    }
  }
  return _leftOvers;
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
    _tempX.addChild("duration").setIntContent(_tempF.duration);
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
    if (_tempF.path != "") {
      _file.addChild("pathurl").setContent(_tempF.path);
    } else {
      _file.addChild("mediaSource").setContent("Slug");
    }
    _file.addChild(rateXML());

    XML _media2 = _file.addChild("media");
    XML _video2 = _media2.addChild("video");
    _video2.addChild("duration").setIntContent(_tempF.duration);
    _video2.addChild(sticsXML());
  }
  return _ret;
}

XML filterXML(float _x, float _y) {
  XML _ret = new XML("filter");
  XML _effect = _ret.addChild("effect");
  
  _effect.addChild("name").setContent("Basic Motion");
  _effect.addChild("effectid").setContent("basic");
  _effect.addChild("effectcategory").setContent("motion");
  _effect.addChild("effecttype").setContent("motion");
  _effect.addChild("mediatype").setContent("video");
  
  XML _param = _effect.addChild("parameter");
  _param.setString("authoringApp", "PremierePro");
  _param.addChild("parameterid").setContent("center");
  _param.addChild("name").setContent("Center");
  
  XML _val = _param.addChild("value");
  _val.addChild("horiz").setFloatContent(_x);
  _val.addChild("vert").setFloatContent(_y);
  return _ret;
}

XML rateXML() {
  XML _ret = new XML("rate");
  _ret.addChild("timebase").setContent("30");
  _ret.addChild("ntsc").setContent("TRUE"); 
  return _ret;
}

XML sticsXML() {
  XML _stics = new XML("samplecharacteristics");
  _stics.addChild(rateXML());
  _stics.addChild("width").setContent("1920");
  _stics.addChild("height").setContent("1080");
  _stics.addChild("anamorphic").setContent("FALSE");
  _stics.addChild("pixelaspectratio").setContent("square");
  _stics.addChild("fielddominance").setContent("none");
  _stics.addChild("colordepth").setContent("24");
  return _stics;
}

void buildAgendaLib() {
  String agendaPath = expAgendasPath;
  String fileTemplateL = expAgendasLeft;
  String fileTemplateR = expAgendasRight;
  int min = expAgendasMin;
  int max = expAgendasMax;

  agendaLib = new ArrayList<Footage>();

  for (int i=min; i <= max; i++) {
    String fleL = fillInNumbers(fileTemplateL, i);
    String fleR = fillInNumbers(fileTemplateR, i);

    Footage tempFL = new Footage();
    tempFL.path = agendaPath + fleL;
    tempFL.name = fleL;
    tempFL.value = i;
    tempFL.side = LEFTPLAYER;
    tempFL.duration = 18000;
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
  String creditPath = expCreditsPath;
  String fileTemplateL = expCreditsLeft;
  String fileTemplateR = expCreditsRight;
  int min = expCreditsMin;
  int max = expCreditsMax;
  
  creditLib = new ArrayList<Footage>();

  for (int i=min; i <= max; i++) {
    String fleL = fillInNumbers(fileTemplateL, i);
    String fleR = fillInNumbers(fileTemplateR, i);

    Footage tempFL = new Footage();
    tempFL.path = creditPath + fleL;
    tempFL.name = fleL;
    tempFL.value = i;
    tempFL.side = LEFTPLAYER;
    tempFL.duration = 18000;
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
  //println("Generated " + creditLib.size() + " CreditLib entries.");
}

void buildAnimLib() {
  
  otherLib = new ArrayList <Footage>();
  if (expAnims != null) {
    for (int i=0; i < expAnims.size(); i++) {
      AnimConfig _tAnimCfg = expAnims.get(i);
      Footage tempFL = new Footage();
      
      tempFL.path = _tAnimCfg.path + _tAnimCfg.file;
      tempFL.name = _tAnimCfg.file;
      tempFL.stringValue = _tAnimCfg.name;
      tempFL.duration = _tAnimCfg.length;
      tempFL.side = LEFTPLAYER;
      tempFL.clipitemid = "clipitem-" + idCounter;
      tempFL.fileid = "file-" + idCounter;
      tempFL.masterclipid = "masterclip-" + idCounter;
      idCounter++;
  
      otherLib.add(tempFL);
    }
  }
  println("Generated " + otherLib.size() + " OtherLib entries.");
}

String fillInNumbers(String _s, int _n) {
  String ret = _s;
  String dblN = String.format("%1$02d", _n);
  String snlN = "" + _n;

  ret = ret.replaceAll("##", dblN);
  ret = ret.replaceAll("#", snlN);

  return ret;
}

void fileSelectedExport(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    export(selection.getAbsolutePath());
  }
  frame.requestFocus();
}