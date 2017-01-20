// Functions for UI rendering

final float trackerLineThickness = 5;
float trackerMousePos = -1;
float trackerBarX = 0;
float trackerBarY = 0;
float trackerBarWidth = 100;

Butt agendaButtL;
Butt agendaButtR;
Butt creditButtL;
Butt creditButtR;

// This draws the video tracker bar
// Not sure if this this the right name
// I mean the progress bar below the video
// Where you can see how far into the video you are

void drawTrackerBar() {
  float mousePos;
  
  noStroke();
  textSize(11);
  fill(color4);
  textFont(smallRobotoMono);
  textAlign(LEFT);
  text(formatTimeCode(headPos), trackerBarX + 10, trackerBarY + 28);
  textAlign(RIGHT);
  text("-" + formatTimeCode(myMovie.duration()-headPos), trackerBarWidth-10, trackerBarY + 28);
  fill(color4, 72);
  rect(trackerBarX + 10, trackerBarY + 8, trackerBarWidth-20, trackerLineThickness);
  fill(color4, 255);
  if (myMovie.duration() > 0) {
    rect(trackerBarX + 10, trackerBarY + 8, (trackerBarWidth-20) * (headPos/myMovie.duration()), trackerLineThickness);
  }
  
  if (trackerMousePos!=-1) {
    fill(color2, 255);
    mousePos = 10 + (trackerMousePos * (trackerBarWidth-20));
    ellipse(mousePos,  trackerBarY + 8 + (trackerLineThickness/2), trackerLineThickness, trackerLineThickness);
    
    fill(color1);
    stroke(color4);  
    strokeWeight(1.2);
    rect(mousePos - (64/2), trackerBarY - 18 , 64, 18, 2);
      
    fill(color4);
    noStroke();
    textFont(smallRobotoMono);
    textAlign(CENTER);
    text(formatTimeCode(trackerMousePos * myMovie.duration()),mousePos,trackerBarY-5);

  }
}

void switchToEdit() {
  UIMode="EDIT";
  purgeButts();
  
  agendaButtL = new Butt("1",5,5,40,48);
  agendaButtL.verb = "AGENDA";
  agendaButtL.noun = "L";
  agendaButtL.style = "AGENDA";
  butts.add(agendaButtL); 
  
  agendaButtR = new Butt("9",videoWidth-(40+5),5,40,48);
  agendaButtR.verb = "AGENDA";
  agendaButtR.noun = "R";
  agendaButtR.style = "AGENDA";
  butts.add(agendaButtR);
  
  creditButtL = new Butt("55",5,10+48,40,32);
  creditButtL.verb = "CREDIT";
  creditButtL.noun = "L";
  creditButtL.style = "CREDIT";
  butts.add(creditButtL);

  creditButtR = new Butt("49",videoWidth-(40+5),10+48,40,32);
  creditButtR.verb = "CREDIT";
  creditButtR.noun = "R";
  creditButtR.style = "CREDIT";
  butts.add(creditButtR);
}

void switchToLoad() {
  int j;
  
  Butt tButt;
  
  UIMode="LOAD";
  purgeButts();
  tButt = new Butt("LOAD VIDEO",24,24,94,24);
  tButt.verb = "LOAD";
  tButt.noun = "";
  butts.add(tButt);
  j = 0;
  for (int i = history.length-1; i >= 0; i--) {
    tButt = new Butt(history[i],24,64+25*j,512,24);
    tButt.style = "LIST";
    tButt.verb = "LOAD";
    tButt.noun = history[i];
    butts.add(tButt);
    j++;
  }
}

void purgeButts() {
  butts = new ArrayList<Butt>();
}

void drawButts() {
  for (int i = 0; i < butts.size(); i++) {
    butts.get(i).drawMe();
  }
}

// This updates the overlay values
void updateValues() {
  String _s;
  CreditEvent _cTemp = null;
  AgendaEvent _aTemp = null;
  
  selectedAEventLeft = null;
  selectedAEventRight = null;
  selectedCEventLeft = null;
  selectedCEventRight = null;

  _cTemp = getCredit(headPos, LEFTPLAYER);
  _s = (_cTemp == null) ? "?" : "" + _cTemp.value;
  creditButtL.t = _s;
  if (_cTemp != null && _cTemp.time == headPos) {
    selectedCEventLeft = _cTemp;
  }
  
  _cTemp = getCredit(headPos, RIGHTPLAYER);
  _s = (_cTemp == null) ? "?" : "" + _cTemp.value;
  creditButtR.t = _s;
  if (_cTemp != null && _cTemp.time == headPos) {
    selectedCEventRight = _cTemp;
  }
  
  _aTemp = getAgenda(headPos, LEFTPLAYER);
  _s = (_aTemp == null) ? "?" : "" + _aTemp.value;
  agendaButtL.t = _s;
  if (_cTemp != null && _cTemp.time == headPos) {
    selectedAEventLeft = _aTemp;
  }
  
  _aTemp = getAgenda(headPos, RIGHTPLAYER);
  _s = (_aTemp == null) ? "?" : "" + _aTemp.value;
  agendaButtR.t = _s;
  if (_cTemp != null && _cTemp.time == headPos) {
    selectedAEventRight = _aTemp;
  }
}

// Draws markers next to overlay buttons to indicate
// if you are currently on a keyframe
void drawKeyframes() {
  fill(color5);
  noStroke();
  
  if (selectedAEventLeft != null) {
    ellipse(agendaButtL.x + agendaButtL.w + 10, agendaButtL.y+5, 10, 10); 
  }
  if (selectedAEventRight != null) {
    ellipse(agendaButtR.x - 10, agendaButtR.y+5, 10, 10); 
  }
  if (selectedCEventLeft != null) {
    ellipse(creditButtL.x + creditButtL.w + 10, creditButtL.y+5, 10, 10);
  }
  if (selectedCEventRight != null) {
    ellipse(creditButtR.x - 10, creditButtR.y+5, 10, 10); 
  }
}

void updateMouseOver() {
  Butt tButt;
  for (int i = 0; i < butts.size(); i++) {
    tButt = butts.get(i);
    if (mouseX >= tButt.x &&
        mouseX <= tButt.x+tButt.w &&
        mouseY >= tButt.y &&
        mouseY <= tButt.y+tButt.h) {
      
      tButt.state = "OVER";
    } else {
      tButt.state = "";
    }
  }
  trackerMousePos = getTrackerMousePos();

}

float getTrackerMousePos() {
  float ret;
  if (mouseY > trackerBarY && mouseY < trackerBarY + 8 + trackerLineThickness + 8) {
    ret = (mouseX - (trackerBarX + 10)) / (trackerBarWidth -20);
    ret = constrain(ret, 0, 1);
  } else {
    ret = -1;
  }
  return ret;
}

void updateMouseClick() {
  Butt tButt;
  for (int i = 0; i < butts.size(); i++) {
    tButt = butts.get(i);
    if (mouseX >= tButt.x &&
        mouseX <= tButt.x+tButt.w &&
        mouseY >= tButt.y &&
        mouseY <= tButt.y+tButt.h) {
      tButt.state = "CLICK";
      buttonCommand(tButt.verb, tButt.noun);
    } else {
      tButt.state = "";
    }
  }
}

void updateMousePressed() {
  trackerMousePos = getTrackerMousePos();
  if (trackerMousePos != -1) {
    setHeadPercent(trackerMousePos);
  }
}

void buttonCommand(String _verb, String _noun) {
  if (_verb == "LOAD") {
    if (_noun == "") {
      selectInput("Select a video to load:", "fileSelected");
    } else {
      loadMovie(_noun);
    }
  }
}

String formatTimeCode(float _t) {
  String ret;
  int mins;
  int secs;
  int frames;
  
  mins = int(_t / 60);
  secs = int(_t-(mins*60));
  frames = int(30*(_t-((mins*60)+secs)));
  
  ret = formatDoubleDigits(mins) + ":" + formatDoubleDigits(secs) + ":" + formatDoubleDigits(frames);
  return ret;
}

String formatDoubleDigits(int _n) {
  if (_n < 10) {
    return "0" + _n;
  } else {
    return "" + _n;
  }
}