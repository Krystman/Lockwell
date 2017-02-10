// Functions for UI rendering

Butt agendaButtL;
Butt agendaButtR;
Butt creditButtL;
Butt creditButtR;

Butt menuSave;
Butt menuSaveClose;
Butt menuExport;

// This draws the video tracker bar
// Not sure if this this the right name
// I mean the progress bar below the video
// Where you can see how far into the video you are

void drawTrackerBar() {
  float mousePos;
  
  // this is the y position of the actual progress bar line
  float _lineY = trackerBarY + 18;
  
  // draw background
  noStroke();
  fill(color1c);
  rect(trackerBarX, trackerBarY, trackerBarWidth, trackerBarHeight);
  
  // Draw timecode / time remaining
  noStroke();
  textSize(11);
  fill(color1b);
  textFont(smallRobotoMono);
  textAlign(LEFT);
  text(formatTimeCode(headPos), trackerBarX + 10, _lineY + 20);
  textAlign(RIGHT);
  text("-" + formatTimeCode(myMovie.duration()-headPos), trackerBarWidth-10, _lineY + 20);
  
  // Draw bar
  fill(color1d);
  rect(trackerBarX + 10, _lineY, trackerBarWidth-20, trackerLineThickness);
  
  // Draw progress
  fill(color1b);
  if (myMovie.duration() > 0) {
    rect(trackerBarX + 10, _lineY, (trackerBarWidth-20) * (headPos/myMovie.duration()), trackerLineThickness);
  }
  
  // Draw keyframe ticks
  fill(color3);
  noStroke();
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      float _tickPos = keyframes.get(i).time;
      rect(int(trackerBarX + 10 + ((trackerBarWidth-20) * (_tickPos/myMovie.duration()))), _lineY - 10, 1, 5);
    }
  }
  
  // Draw mouse over info
  if (trackerMousePos!=-1) {
    fill(color2, 255);
    mousePos = 10 + (trackerMousePos * (trackerBarWidth-20));
    
    triangle(mousePos, _lineY+trackerLineThickness+1, mousePos-4, _lineY+trackerLineThickness+5, mousePos+4, _lineY+trackerLineThickness+5);
    rect(mousePos, _lineY, 1, trackerLineThickness);
    //ellipse(mousePos,  _lineY + (trackerLineThickness/2), trackerLineThickness, trackerLineThickness);
    
    fill(color1);
    stroke(color1b);  
    strokeWeight(1.2);
    rect(mousePos - (64/2), trackerBarY - 8 , 64, 18, 2);
      
    fill(color1b);
    noStroke();
    textFont(smallRobotoMono);
    textAlign(CENTER);
    text(formatTimeCode(trackerMousePos * myMovie.duration()),mousePos,trackerBarY+5);
  }
}

void drawDetailBar() {
  int _thisx; 
  
  float _ticksY = detailBarY + 20; // this is the y position of ticks of the timeline
  float _keysY = _ticksY - 14; // this is the y position of the top corner of the keyframe diamonds
  float _realdWidth = detailBarWidth - 20; // adding padding to the edges;
  
  // draw background
  noStroke();
  fill(color1);
  rect(detailBarX, detailBarY, detailBarWidth, detailBarHeight);
  
  // draw second ticks
  noStroke();
  fill(color1d);
  for (float i = int(detailBarScroll-1); i < detailBarScroll + detailBarZoom + 1; i=i+0.5) {
    if (i >= 0 && i <= myMovie.duration()) {
      int _tickH = 6;
      if (i != int(i)) {
        _tickH = 1;
      }
      _thisx = 10 + int(((i-detailBarScroll) / detailBarZoom) * _realdWidth);
      rect(_thisx, _ticksY, 1, _tickH);
    }
  }
  
  // draw keyframe diamonds
  fill(color3);
  noStroke();
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      float _keyPos = keyframes.get(i).time;
      if (_keyPos == headPos) {
        fill(color4);
      } else {
        fill(color3);
      }
      if (_keyPos > detailBarScroll-1 && _keyPos < detailBarScroll + detailBarZoom) {
        _thisx = 10 + int(((_keyPos-detailBarScroll) / detailBarZoom) * _realdWidth);
        quad(_thisx, _keysY, _thisx-4, _keysY+4, _thisx, _keysY+8, _thisx+4, _keysY+4);
        
        //rect(int(trackerBarX + 10 + ((trackerBarWidth-20) * (_tickPos/myMovie.duration()))), _lineY - 10, 1, 5);
      }
    }
  }
  
  // draw cursor
  noStroke();
  fill(color2);
  if (headPos > detailBarScroll-1 && headPos < detailBarScroll + detailBarZoom) {
    _thisx = 10 + int(((headPos-detailBarScroll) / detailBarZoom) * _realdWidth);
    triangle(_thisx, _ticksY, _thisx-4, _ticksY+4, _thisx+4, _ticksY+4);
    rect(_thisx-4, _ticksY+4, 7.8, 5);
  }

}

void switchToEdit() {
  UIMode="EDIT";
  
  videoY = menuHeight;
  
  detailBarX = 0;
  detailBarY = videoHeight + videoY;
  detailBarWidth = width;
  
  trackerBarX = 0;
  trackerBarY = videoHeight + videoY + detailBarHeight;
  trackerBarWidth = width;
  
  purgeButts();
  
  agendaButtL = new Butt("1",5,5 + videoY,40,48);
  agendaButtL.verb = "AGENDA";
  agendaButtL.noun = "L";
  agendaButtL.style = "AGENDA";
  butts.add(agendaButtL); 
  
  agendaButtR = new Butt("9",videoWidth-(40+5),5 + videoY,40,48);
  agendaButtR.verb = "AGENDA";
  agendaButtR.noun = "R";
  agendaButtR.style = "AGENDA";
  butts.add(agendaButtR);
  
  creditButtL = new Butt("55",5,agendaButtL.y + agendaButtL.h + 5,40,32);
  creditButtL.verb = "CREDIT";
  creditButtL.noun = "L";
  creditButtL.style = "CREDIT";
  butts.add(creditButtL);

  creditButtR = new Butt("49",videoWidth-(40+5),agendaButtR.y + agendaButtR.h + 5,40,32);
  creditButtR.verb = "CREDIT";
  creditButtR.noun = "R";
  creditButtR.style = "CREDIT";
  butts.add(creditButtR);
  
  menuSave = new Butt("SAVE",24, menuY + 5 ,94,24);
  menuSave.verb = "SAVE";
  menuSave.noun = "";
  butts.add(menuSave);

  menuSaveClose = new Butt("SAVE & CLOSE", menuSave.x + menuSave.w + 5, menuSave.y,94,24);
  menuSaveClose.verb = "SAVECLOSE";
  menuSaveClose.noun = "";
  butts.add(menuSaveClose);

  menuExport = new Butt("EXPORT", menuSaveClose.x + menuSaveClose.w + 5, menuSave.y,94,24);
  menuExport.verb = "EXPORT";
  menuExport.noun = "";
  butts.add(menuExport);
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
  Keyframe tempFrame = null;
  
  selFrameAgendaLeft = null;
  selFrameAgendaRight = null;
  selFrameCreditLeft = null;
  selFrameCreditRight = null;

  tempFrame = getKeyframe(KFCREDITS, headPos, LEFTPLAYER);
  _s = (tempFrame == null) ? "?" : "" + tempFrame.value;
  creditButtL.t = _s;
  if (tempFrame != null && tempFrame.time == headPos) {
    selFrameCreditLeft = tempFrame;
  }
  
  tempFrame = getKeyframe(KFCREDITS, headPos, RIGHTPLAYER);
  _s = (tempFrame == null) ? "?" : "" + tempFrame.value;
  creditButtR.t = _s;
  if (tempFrame != null && tempFrame.time == headPos) {
    selFrameCreditRight = tempFrame;
  }
  
  tempFrame = getKeyframe(KFAGENDAS, headPos, LEFTPLAYER);
  _s = (tempFrame == null) ? "?" : "" + tempFrame.value;
  agendaButtL.t = _s;
  if (tempFrame != null && tempFrame.time == headPos) {
    selFrameAgendaLeft = tempFrame;
  }
  
  tempFrame = getKeyframe(KFAGENDAS, headPos, RIGHTPLAYER);
  _s = (tempFrame == null) ? "?" : "" + tempFrame.value;
  agendaButtR.t = _s;
  if (tempFrame != null && tempFrame.time == headPos) {
    selFrameAgendaRight = tempFrame;
  }
}

// Draws markers next to overlay buttons to indicate
// if you are currently on a keyframe
void drawKeyframes() {
  fill(color5);
  noStroke();
  
  if (selFrameAgendaLeft != null) {
    ellipse(agendaButtL.x + agendaButtL.w + 10, agendaButtL.y+5, 10, 10); 
  }
  if (selFrameAgendaRight != null) {
    ellipse(agendaButtR.x - 10, agendaButtR.y+5, 10, 10); 
  }
  if (selFrameCreditLeft != null) {
    ellipse(creditButtL.x + creditButtL.w + 10, creditButtL.y+5, 10, 10);
  }
  if (selFrameCreditRight != null) {
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
  if (mouseY > trackerBarY && mouseY < trackerBarY + 18 + trackerLineThickness + 8) {
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
      if (mouseButton == LEFT) { 
        buttonCommand(tButt.verb, tButt.noun);
      } else if (mouseButton == RIGHT) {
        buttonCommandRight(tButt.verb, tButt.noun);
      }
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
  } else if (_verb == "AGENDA") {
    if (_noun == "L") {
      agendaButt(LEFTPLAYER, 1);
    } else {
      agendaButt(RIGHTPLAYER, 1);
    }
  } else if (_verb == "CREDIT") {
    if (_noun == "L") {
      creditButt(LEFTPLAYER, 1);
    } else {
      creditButt(RIGHTPLAYER, 1);
    }
  } else if (_verb == "SAVE") {
    saveVData();
  } else if (_verb == "SAVECLOSE") {
    saveVData();
    switchToLoad();
  }
}

void buttonCommandRight(String _verb, String _noun) {
  if (_verb == "AGENDA") {
    if (_noun == "L") {
      agendaButt(LEFTPLAYER, -1);
    } else {
      agendaButt(RIGHTPLAYER, -1);
    }
  } else if (_verb == "CREDIT") {
    if (_noun == "L") {
      creditButt(LEFTPLAYER, -1);
    } else {
      creditButt(RIGHTPLAYER, -1);
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