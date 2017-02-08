// Functions to manipulate Video Data

// This creates a new Credit Event
CreditEvent addCreditEvent(float _time, int _value, int _side) {
  CreditEvent _tempCEvent;
  
  _tempCEvent = new CreditEvent();
  _tempCEvent.time = _time;
  _tempCEvent.value = _value;
  _tempCEvent.side = _side;
  creditEvents.add(_tempCEvent);
  
  return _tempCEvent;
}

// This creates a new Agenda Event
AgendaEvent addAgendaEvent(float _time, int _value, int _side) {
  AgendaEvent _tempAEvent;
  
  _tempAEvent = new AgendaEvent();
  _tempAEvent.time = _time;
  _tempAEvent.value = _value;
  _tempAEvent.side = _side;
  agendaEvents.add(_tempAEvent);
  
  return _tempAEvent;
}

// This gets the agenda point count at any given time
AgendaEvent getAgenda(float _time, int _side) {
  AgendaEvent _foundAEvent = null;
  AgendaEvent _tempAEvent = null;
  
  if (agendaEvents != null) {
    for (int i = 0; i < agendaEvents.size(); i++) {
      _tempAEvent = agendaEvents.get(i);
      if (_tempAEvent.side == _side && _tempAEvent.time <= _time) {
        if (_foundAEvent == null) {
          _foundAEvent = _tempAEvent;
        } else if (_tempAEvent.time > _foundAEvent.time) {
          _foundAEvent = _tempAEvent;
        }
      }
    }
  }
  return _foundAEvent;
}

// This gets the credit count at any given time
CreditEvent getCredit(float _time, int _side) {
  CreditEvent _foundCEvent = null;
  CreditEvent _tempCEvent = null;
  
  if (creditEvents != null) {
    for (int i = 0; i < creditEvents.size(); i++) {
      _tempCEvent = creditEvents.get(i);
      if (_tempCEvent.side == _side && _tempCEvent.time <= _time) {
        if (_foundCEvent == null) {
          _foundCEvent = _tempCEvent;
        } else if (_tempCEvent.time > _foundCEvent.time) {
          _foundCEvent = _tempCEvent;
        }
      }
    }
  }
  return _foundCEvent;
}

// This is what gets executed when you press a button to change the agenda points
void agendaButt(int _side, int _d) {
  AgendaEvent _lastAEvent;
  AgendaEvent _newAEvent;
  
  // Check if there is a keyframe at current time
  // If no, create one
  if ((_side == LEFTPLAYER && selectedAEventLeft == null) || (_side == RIGHTPLAYER && selectedAEventRight == null)) {
    _lastAEvent = getAgenda(headPos, _side);
    if (_lastAEvent == null) {
      _newAEvent = addAgendaEvent(headPos, 0, _side);
    } else {
      _newAEvent = addAgendaEvent(headPos, _lastAEvent.value, _side);
    }
    if (_side == LEFTPLAYER) {
      selectedAEventLeft = _newAEvent;
    } else {
      selectedAEventRight = _newAEvent;
    }
  }
  
  // Increase Agenda value by one
  if (_side == LEFTPLAYER) {
    _newAEvent = selectedAEventLeft;
  } else {
    _newAEvent = selectedAEventRight;
  }
  _newAEvent.value+=_d;
}

// This is what gets executed when you press a button to change the credit points
void creditButt(int _side, int _d) {
  CreditEvent _lastCEvent;
  CreditEvent _newCEvent;
  
  // Check if there is a keyframe at current time
  // If no, create one
  if ((_side == LEFTPLAYER && selectedCEventLeft == null) || (_side == RIGHTPLAYER && selectedCEventRight == null)) {
    _lastCEvent = getCredit(headPos, _side);
    if (_lastCEvent == null) {
      _newCEvent = addCreditEvent(headPos, 0, _side);
    } else {
      _newCEvent = addCreditEvent(headPos, _lastCEvent.value, _side);
    }
    if (_side == LEFTPLAYER) {
      selectedCEventLeft = _newCEvent;
    } else {
      selectedCEventRight = _newCEvent;
    }
  }
  
  // Increase Agenda value by one
  if (_side == LEFTPLAYER) {
    _newCEvent = selectedCEventLeft;
  } else {
    _newCEvent = selectedCEventRight;
  }
  _newCEvent.value+=_d;
}

// This returns a keyframe before the current head position if possible
// Otherwise, it returns the head position
float getLastKeyframe() {
  AgendaEvent _tempAEvent = null;
  CreditEvent _tempCEvent = null;
  float ret;
  ret = -1f;
  for (int i = 0; i < agendaEvents.size(); i++) {
    _tempAEvent = agendaEvents.get(i);
    if (_tempAEvent.time > ret && _tempAEvent.time < headPos) {
      ret = _tempAEvent.time;
    }
  }
  for (int i = 0; i < creditEvents.size(); i++) {
    _tempCEvent = creditEvents.get(i);
    if (_tempCEvent.time > ret && _tempCEvent.time < headPos) {
      ret = _tempCEvent.time;
    }
  }
  if (ret == -1f) {
    return headPos;
  } else {
    return ret;
  }
}

// This returns a keyframe after the current head position if possible
// Otherwise, it returns the head position
float getNextKeyframe() {
  AgendaEvent _tempAEvent = null;
  CreditEvent _tempCEvent = null;
  float ret;
  ret = 999999f;
  for (int i = 0; i < agendaEvents.size(); i++) {
    _tempAEvent = agendaEvents.get(i);
    if (_tempAEvent.time < ret && _tempAEvent.time > headPos) {
      ret = _tempAEvent.time;
    }
  }
  for (int i = 0; i < creditEvents.size(); i++) {
    _tempCEvent = creditEvents.get(i);
    if (_tempCEvent.time < ret && _tempCEvent.time > headPos) {
      ret = _tempCEvent.time;
    }
  }
  if (ret == 999999) {
    return headPos;
  } else {
    return ret;
  }  
}