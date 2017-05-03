// Functions to manipulate Video Data

// This creates a new Keyframe of a certain type
Keyframe addKeyframe(int _type, float _time, int _value, int _side, String _stingVal) {
  Keyframe _tempKeyframe;
  
  _tempKeyframe = new Keyframe();
  _tempKeyframe.type = _type;
  _tempKeyframe.time = _time;
  _tempKeyframe.value = _value;
  _tempKeyframe.side = _side;
  _tempKeyframe.stringValue = _stingVal;
  keyframes.add(_tempKeyframe);
  dirty = true;
  
  return _tempKeyframe;
}

void addThisKeyframe(Keyframe _kf) {
  keyframes.add(_kf);
  dirty = true;  
}

// This deletes a keyframe
void clearKeyframe(int _type, float _time, int _side) {
  Keyframe _tempFrame;
  
  _tempFrame = getKeyframeExact(_type, _time, _side);
  if (_tempFrame != null) {
    keyframes.remove(_tempFrame);
    dirty = true;
  }
}

// This gets a list of all animations playing at a certain timecode
ArrayList <Keyframe> getAnims(float _time, int _side) {
  Keyframe _tempFrame = null;
  ArrayList <Keyframe> ret = new ArrayList <Keyframe>();
  
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      _tempFrame = keyframes.get(i);
      if (_tempFrame.type == KFANIMS && (_tempFrame.side == _side || _side == BOTHPLAYERS) && _tempFrame.time <= _time && _tempFrame.time + _tempFrame.duration >= _time) {
        ret.add(_tempFrame);
      }
    }
  }
  return ret;
}

// Clears a Keyframe with the selAnimsLeft / selAnimsRight lists
void clearAnimKeyframe(int _side, int _index) {
  ArrayList <Keyframe> _myList;
  if (_side == LEFTPLAYER) {
    _myList = selAnimsLeft;
  } else if (_side == RIGHTPLAYER) {
    _myList = selAnimsRight;
  } else {
    return;
  }
  Keyframe _myKF = _myList.get(_index);
  if (_myKF != null) {
    keyframes.remove(_myKF);
  }
}

// Returns the length of an animation
// The data is taken from the configuration file
float getAnimLength(String _anim) {
  if (expAnims != null) {
    for (int i=0; i < expAnims.size(); i++) {
      AnimConfig _tAnim = expAnims.get(i);
      if (_tAnim.name.equals(_anim)) {
        return _tAnim.length / 29.97;
      }
    }
  }
  return 1.0;
}

// Returns the length of an animation
AnimConfig getAnimCfg(String _anim) {
  AnimConfig _found = null;
  if (expAnims != null) {
    for (int i=0; i < expAnims.size(); i++) {
      AnimConfig _tAnim = expAnims.get(i);
      if (_tAnim.name.equals(_anim)) {
        _found = _tAnim;
        break;
      }
    }
  }
  return _found;
}

// Returns the last remembered position for an animation
AnimPos getAnimPosMem(String _anim, int _side) {
  AnimPos _found = null;
  if (animPosMem != null) {
    for (int i=0; i < animPosMem.size(); i++) {
      AnimPos _tapos = animPosMem.get(i);
      if (_tapos.name.equals(_anim) && _tapos.side == _side) {
        _found = _tapos;
        break;
      }
    }
  }
  return _found;
}

// Remembers the posion of an animation keyframe
void rememberAnimPos(Keyframe _kf) {
  if (_kf.x != 0.0 || _kf.y != 0.0) {
    AnimPos _tapos = getAnimPosMem(_kf.stringValue, _kf.side);
    if (_tapos == null) {
      _tapos = new AnimPos();
      _tapos.name = _kf.stringValue;
      _tapos.side = _kf.side;
      animPosMem.add(_tapos);
    }
    if (_tapos.x != _kf.x || _tapos.y != _kf.y) { 
      dirty = true;
      _tapos.x = _kf.x;
      _tapos.y = _kf.y;
    }
  }
}

// This gets a value of the last keyframe of a certain stat at any given time
// Basically it gets the credit count at any given time for example
Keyframe getKeyframe(int _type, float _time, int _side) {
  Keyframe _foundFrame = null;
  Keyframe _tempFrame = null;
  
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      _tempFrame = keyframes.get(i);
      if (_tempFrame.type == _type && _tempFrame.side == _side && _tempFrame.time <= _time) {
        if (_foundFrame == null) {
          _foundFrame = _tempFrame;
        } else if (_tempFrame.time > _foundFrame.time) {
          _foundFrame = _tempFrame;
        }
      }
    }
  }
  return _foundFrame;
}

// This gets a specific keyframe at a specific time, if it exists
Keyframe getKeyframeExact(int _type, float _time, int _side) {
  Keyframe _tempFrame = null;
  
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      _tempFrame = keyframes.get(i);
      if (_tempFrame.type == _type && _tempFrame.side == _side && _tempFrame.time == _time) {
          return _tempFrame;
      }
    }
  }
  return null;
}

// This is what gets executed when you press a button to change the agenda points
void agendaButt(int _side, int _d) {
  Keyframe _lastKeyframe = null;
  Keyframe _newKeyframe = null;
  
  // Check if there is a keyframe at current time
  // If no, create one
  if ((_side == LEFTPLAYER && selFrameAgendaLeft == null) || (_side == RIGHTPLAYER && selFrameAgendaRight == null)) {
    _lastKeyframe = getKeyframe(KFAGENDAS, headPos, _side);
    if (_lastKeyframe == null) {
      _newKeyframe = addKeyframe(KFAGENDAS, headPos, 0, _side, "");
    } else {
      _newKeyframe = addKeyframe(KFAGENDAS, headPos, _lastKeyframe.value, _side, "");
    }
    if (_side == LEFTPLAYER) {
      selFrameAgendaLeft = _newKeyframe;
    } else {
      selFrameAgendaRight = _newKeyframe;
    }
  }
  
  // Increase Agenda value by one
  if (_side == LEFTPLAYER) {
    _newKeyframe = selFrameAgendaLeft;
  } else {
    _newKeyframe = selFrameAgendaRight;
  }
  _newKeyframe.value+=_d;
}

// This is what gets executed when you press a button to change the credit points
void creditButt(int _side, int _d) {
  Keyframe _lastKeyframe = null;
  Keyframe _newKeyframe = null;
  
  // Check if there is a keyframe at current time
  // If no, create one
  if ((_side == LEFTPLAYER && selFrameCreditLeft == null) || (_side == RIGHTPLAYER && selFrameCreditRight == null)) {
    _lastKeyframe = getKeyframe(KFCREDITS, headPos, _side);
    if (_lastKeyframe == null) {
      _newKeyframe = addKeyframe(KFCREDITS, headPos, 0, _side, "");
    } else {
      _newKeyframe = addKeyframe(KFCREDITS, headPos, _lastKeyframe.value, _side, "");
    }
    if (_side == LEFTPLAYER) {
      selFrameCreditLeft = _newKeyframe;
    } else {
      selFrameCreditRight = _newKeyframe;
    }
  }
  
  // Increase Agenda value by one
  if (_side == LEFTPLAYER) {
    _newKeyframe = selFrameCreditLeft;
  } else {
    _newKeyframe = selFrameCreditRight;
  }
  _newKeyframe.value+=_d;
  dirty = true;
}

// This is what gets executed after you typed in a comment
void commentConfirm(String _str) { 
  // Check if there is a keyframe at current time
  // If no, create one
 
  _str = trim(_str);
  if (_str.length() == 0) {
    if (selFrameComment != null) {
      keyframes.remove(selFrameComment);
      selFrameComment = null;
    }
  } else {
    if (selFrameComment == null) {
      selFrameComment = addKeyframe(KFCOMMENTS, headPos, 0, LEFTPLAYER, _str);
    } else {
      selFrameComment.stringValue = _str;
    }
  }
  dirty = true;  
}

// This returns ANY keyframe time before the current head position if possible
// Otherwise, it returns the head position
float getLastKeyframe() {
  Keyframe _foundFrame = null;
  Keyframe _tempFrame = null;
  
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      _tempFrame = keyframes.get(i);
      if (_tempFrame.time < headPos) {
        if (_foundFrame == null) {
          _foundFrame = _tempFrame;
        } else if (_tempFrame.time > _foundFrame.time) {
          _foundFrame = _tempFrame;
        }
      }
    }
  }
  if (_foundFrame == null) {
    return headPos;
  }
  return _foundFrame.time;
}

// This returns ANY keyframe time before the current head position if possible
// Otherwise, it returns the head position
float getNextKeyframe() {
  Keyframe _foundFrame = null;
  Keyframe _tempFrame = null;
  
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      _tempFrame = keyframes.get(i);
      if (_tempFrame.time > headPos) {
        if (_foundFrame == null) {
          _foundFrame = _tempFrame;
        } else if (_tempFrame.time < _foundFrame.time) {
          _foundFrame = _tempFrame;
        }
      }
    }
  }
  if (_foundFrame == null) {
    return headPos;
  }
  return _foundFrame.time; 
}

ArrayList <Keyframe> filterKeyframes(ArrayList <Keyframe> _kf, int _sideFilter, int _typeFilter) {
  ArrayList <Keyframe> filtered = new ArrayList <Keyframe>();
  Keyframe _tempFrame = null;
  
  if (_kf != null) {
    for (int i = 0; i < _kf.size(); i++) {
      _tempFrame = _kf.get(i);
      if ((_tempFrame.side == _sideFilter || _sideFilter == BOTHPLAYERS) && _tempFrame.type == _typeFilter) {
        filtered.add(_tempFrame);
      }
    }
  }
  return filtered;
}

void sortByTime(ArrayList <Keyframe> _kf) {
  Keyframe _tempF1 = null;
  Keyframe _tempF2 = null;
  Boolean sorted;
 
  // Lame-ass bubble sort.
  if (_kf != null) {
    for (int i = 0; i < _kf.size() - 1; i++) {
      sorted = true;
      for (int j = 1; j < _kf.size() - i; j++) {
        _tempF1 = _kf.get(j-1);
        _tempF2 = _kf.get(j);
        if (_tempF1.time > _tempF2.time) {
          sorted = false;
          _kf.set(j-1, _tempF2);
          _kf.set(j, _tempF1);
        }
      }
      if (sorted) {
        return;
      }
    }
    
    // Debug test. Pls ignore.
    /*for (int i = 0; i < _kf.size(); i++) {
      println(_kf.get(i).time); 
    }*/
  }
}