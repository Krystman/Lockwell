// Functions to manipulate Video Data

void addCreditEvent(float _time, int _value, int _side) {
  CreditEvent _tempCEvent;
  
  _tempCEvent = new CreditEvent();
  _tempCEvent.time = _time;
  _tempCEvent.value = _value;
  _tempCEvent.side = _side;
  creditEvents.add(_tempCEvent);
}

void addAgendaEvent(float _time, int _value, int _side) {
  AgendaEvent _tempAEvent;
  
  _tempAEvent = new AgendaEvent();
  _tempAEvent.time = _time;
  _tempAEvent.value = _value;
  _tempAEvent.side = _side;
  agendaEvents.add(_tempAEvent);
}

AgendaEvent getAgenda(float _time, int _side) {
  AgendaEvent _foundAEvent = null;
  AgendaEvent _tempAEvent = null;
  
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
  return _foundAEvent;
}

CreditEvent getCredit(float _time, int _side) {
  CreditEvent _foundCEvent = null;
  CreditEvent _tempCEvent = null;
  
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
  return _foundCEvent;
}