// Functions for UI rendering

Butt agendaButtL;
Butt agendaButtR;
Butt creditButtL;
Butt creditButtR;

Butt commentButt;

Butt addAniButtL;
Butt addAniButtR;

Butt delAgendaButtL;
Butt delAgendaButtR;
Butt delCreditButtL;
Butt delCreditButtR;
Butt delCommentButt;

Butt menuSave;
Butt menuSaveClose;
Butt menuExport;

Butt keyboardSelect;

KeyMap nullMap;

ArrayList <Butt> animButtsL;
ArrayList <Butt> animButtsR;

ArrayList <Butt> animMenuL;
ArrayList <Butt> animMenuR;
ArrayList <Butt> buttMenu;

void makeButtons() {
}

void beginAddAnim(int _side) {
  if (_side == LEFTPLAYER) {
    inputTarget = "L";
    buttMenu = animMenuL;
  } else if (_side == RIGHTPLAYER) {
    inputTarget = "R";
    buttMenu = animMenuR;
  } else {
    return;
  }
  Butt tButt;
  for (int i = 0; i < buttMenu.size(); i++) {
    tButt = buttMenu.get(i);
    tButt.state = "";
  }
  inputMode = "ANIM";
}

void beginAnimPos() {
  inputMode = "ANIMPOS";
  inputLastX = 0.5;
  inputLastY = 0.5;
}

void beginCommentInput() {
  inputMode = "TEXT";
  if (selFrameComment == null) {
    inputText = "";
  } else {
    inputText = selFrameComment.stringValue;
  }
  inputTarget = "COMMENT";
  commentButt.state = "CLICK";
  commentButt.visible = false;
}

void inputConfirm() {
  if (inputMode == "ANIMPOS") {
    inputKeyframe.x = inputX;
    inputKeyframe.y = inputY;
    if (inputTarget == "NEW") {
      addThisKeyframe(inputKeyframe);
    }
  }
  inputMode = "";
  if (inputTarget == "COMMENT") {
    commentConfirm(inputText);
    commentButt.dirty = true;
    commentButt.caret = false;
  }
  inputText = "";
  inputTarget = "";
}

void inputCancel() {
  inputMode = "";
  if (inputTarget == "COMMENT") {
    commentButt.dirty = true;
    commentButt.caret = false;
  }
}

void drawInput() {
  fill(0,0,0,162);
  rect(0,0,width,height);
  if (inputTarget == "COMMENT") {
    commentButt.visible = true;
    commentButt.t = inputText;
    commentButt.caret = blink;
    commentButt.w = int(stringButtSize(commentButt.t)+20);
    if (commentButt.w < 100) {
      commentButt.w = 100;
    }
    
    commentButt.x = int((videoWidth / 2) - (commentButt.w / 2));
    delCommentButt.x = commentButt.x - 17;
    commentButt.drawMe();
    commentButt.visible = false;
  }

}

void drawAnimInput() {
  fill(0,0,0,162);
  rect(0,0,width,height);
  for (int i = 0; i < buttMenu.size(); i++) {
    if (buttMenu.get(i).visible) {
      buttMenu.get(i).drawMe();
    }
  }
}

void drawAnimPosInput() {  
  for (int i = 0; i < buttMenu.size(); i++) {
    if (buttMenu.get(i).visible) {
      buttMenu.get(i).drawMe();
    }
  }
  fill(0,0,0,162);
  rect(0,0,width,height);
  stroke(color2);
  
  inputX = mouseX / videoWidth;
  inputY = (mouseY - videoY) / videoHeight;
  
  inputX = constrain(inputX, 0.0, 1.0);
  inputY = constrain(inputY, 0.0, 1.0);
  
  line(0, videoY + (inputY * videoHeight), videoWidth, videoY + (inputY * videoHeight));
  line(inputX * videoWidth, videoY, inputX * videoWidth, videoHeight + videoY);
  
  stroke(color5);
  
  dashedLine(0, videoY + (inputLastY * videoHeight), videoWidth, videoY + (inputLastY * videoHeight), 3);
  dashedLine(inputLastX * videoWidth, videoY, inputLastX * videoWidth, videoHeight + videoY, 3);
  
}

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

// This deals with a click on the Detail bar
// Detail bar is a zoomed-in timeline above the tracker bar 
void detailBarClick() {  
  float _realdWidth = detailBarWidth - 20; // adding padding to the edges;
  float mouseline = -20; // A mouse line is a selection line showing up one mouse over.
  float mouseTime = -1; // The timecode underneath the mouse
  float mouseKeyTime = -1; // The timecode of the keyframe currently being hovered on my the mouse
  
  mouseline = detailMousePos * detailBarWidth;
  mouseTime = detailBarScroll + (((mouseline-10) / _realdWidth) * detailBarZoom);
  mouseTime = constrain(mouseTime, 0, myMovie.duration());
    
  // Snap to keyframes
  float bestDist = myMovie.duration()*2;
  float bestTime = -1;
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      float dist = abs(keyframes.get(i).time - mouseTime);
      if (dist < bestDist) {
        bestDist = dist;
        bestTime = keyframes.get(i).time;
      }
    }
  }
  if (bestDist < 0.25) {
    mouseKeyTime = bestTime;
  }
  if (mouseKeyTime == -1) {
    setHead(mouseTime);
  } else {
    setHead(mouseKeyTime);
  }
}

// This draws the Detail bar
// Detail bar is a zoomed-in timeline above the tracker bar 
void drawDetailBar() {
  int _thisx; 
  
  float _ticksY = detailBarY + 20; // this is the y position of ticks of the timeline
  float _keysY = _ticksY - 14; // this is the y position of the top corner of the keyframe diamonds
  float _realdWidth = detailBarWidth - 20; // adding padding to the edges;
  float mouseline = -20; // A mouse line is a selection line showing up one mouse over.
  float mouseTime = -1; // The timecode underneath the mouse
  float mouseKeyTime = -1; // The timecode of the keyframe currently being hovered on my the mouse
  
  // Deal with mouse selection. 
  if (detailMousePos!=-1) {
    mouseline = detailMousePos * detailBarWidth;
    mouseTime = detailBarScroll + (((mouseline-10) / _realdWidth) * detailBarZoom);
    mouseTime = constrain(mouseTime, 0, myMovie.duration());
    
    // Snap to keyframes
    float bestDist = myMovie.duration()*2;
    float bestTime = -1;
    if (keyframes != null) {
      for (int i = 0; i < keyframes.size(); i++) {
        float dist = abs(keyframes.get(i).time - mouseTime);
        if (dist < bestDist) {
          bestDist = dist;
          bestTime = keyframes.get(i).time;
        }
      }
    }
    if (bestDist < 0.25) {
      mouseKeyTime = bestTime;
    }
    
  } else {
    // Show a mouse line if the mouse is over the tracker bar too!
    if (trackerMousePos!=-1) {
      mouseTime = trackerMousePos * myMovie.duration();
      if (mouseTime > detailBarScroll-1 && mouseTime < detailBarScroll + detailBarZoom) {
        mouseline = 10 + int(((mouseTime-detailBarScroll) / detailBarZoom) * _realdWidth);
      }
    }
  }
  
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
  
  // draw mouseline
  fill(color2);
  noStroke();  
  if (mouseKeyTime == -1) {
    rect(mouseline, detailBarY, 1, detailBarHeight);
  } else {
    _thisx = 10 + int(((mouseKeyTime-detailBarScroll) / detailBarZoom) * _realdWidth);
    rect(_thisx, detailBarY, 1, detailBarHeight);
  }
  
  // draw keyframe diamonds
  fill(color3);
  noStroke();
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      float _keyPos = keyframes.get(i).time;
      if (_keyPos == mouseKeyTime) {
        fill(color2);
      } else if (_keyPos == headPos) {
        fill(color4);
      } else if (selFrameComment != null && selFrameComment == keyframes.get(i)) {
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

  // draw tooltip   
  if (detailMousePos!=-1) {
    float _showTime = mouseTime;
    float _showX = mouseline; 
    if (mouseKeyTime != -1) {
      _showTime = mouseKeyTime;
      _showX = 10 + int(((mouseKeyTime-detailBarScroll) / detailBarZoom) * _realdWidth);
    } else {
      
    }
    fill(color1);
    stroke(color1b);  
    strokeWeight(1.2);
    rect(_showX - (64/2), detailBarY - 15 , 64, 18, 2);
      
    fill(color1b);
    noStroke();
    textFont(smallRobotoMono);
    textAlign(CENTER);
    text(formatTimeCode(_showTime),_showX,detailBarY-3);
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
  agendaButtL.setStyle("AGENDA");
  butts.add(agendaButtL); 
  
  agendaButtR = new Butt("9",videoWidth-(40+5),5 + videoY,40,48);
  agendaButtR.verb = "AGENDA";
  agendaButtR.noun = "R";
  agendaButtR.setStyle("AGENDA");
  butts.add(agendaButtR);
  
  creditButtL = new Butt("55",5,agendaButtL.y + agendaButtL.h + 5,40,32);
  creditButtL.verb = "CREDIT";
  creditButtL.noun = "L";
  creditButtL.setStyle("CREDIT");
  butts.add(creditButtL);

  creditButtR = new Butt("49",videoWidth-(40+5),agendaButtR.y + agendaButtR.h + 5,40,32);
  creditButtR.verb = "CREDIT";
  creditButtR.noun = "R";
  creditButtR.setStyle("CREDIT");
  butts.add(creditButtR);
  
  commentButt = new Butt("(note)",(videoWidth / 2) - 300, videoY + videoHeight - 37,600,32);
  commentButt.verb = "COMMENT";
  commentButt.setStyle("COMMENT");
  commentButt.w = int(stringButtSize(commentButt.t)+20);
  commentButt.x = int((videoWidth / 2) - (commentButt.w / 2));
  butts.add(commentButt);
  
  addAniButtL = new Butt("ADD ANIMATION", 5, creditButtL.y + creditButtL.h + 15, 190, 24);
  addAniButtL.verb = "ADDANIM";
  addAniButtL.noun = "L";
  addAniButtL.setStyle("ANIML");
  butts.add(addAniButtL);
  
  addAniButtR = new Butt("ADD ANIMATION", videoWidth-(190+5), creditButtR.y + creditButtR.h + 15, 190, 24);
  addAniButtR.verb = "ADDANIM";
  addAniButtR.noun = "R";
  addAniButtR.setStyle("ANIMR");
  butts.add(addAniButtR);
  
  // Buttons to delete Keyframes
  delAgendaButtL = new Butt("",agendaButtL.x + agendaButtL.w + 3,agendaButtL.y,14,14);
  delAgendaButtL.verb = "DELETE";
  delAgendaButtL.noun = "LA";
  delAgendaButtL.setStyle("KEYFRAME");
  butts.add(delAgendaButtL);

  delAgendaButtR = new Butt("",agendaButtR.x - 17,agendaButtR.y,14,14);
  delAgendaButtR.verb = "DELETE";
  delAgendaButtR.noun = "RA";
  delAgendaButtR.setStyle("KEYFRAME");
  butts.add(delAgendaButtR);
  
  delCreditButtL = new Butt("",creditButtL.x + creditButtL.w + 3,creditButtL.y,14,14);
  delCreditButtL.verb = "DELETE";
  delCreditButtL.noun = "LC";
  delCreditButtL.setStyle("KEYFRAME");
  butts.add(delCreditButtL);
  
  delCreditButtR = new Butt("",creditButtR.x - 17,creditButtR.y,14,14);
  delCreditButtR.verb = "DELETE";
  delCreditButtR.noun = "RC";
  delCreditButtR.setStyle("KEYFRAME");
  butts.add(delCreditButtR);

  delCommentButt = new Butt("",commentButt.x - 17,commentButt.y,14,14);
  delCommentButt.verb = "DELETE";
  delCommentButt.noun = "COMMENT";
  delCommentButt.setStyle("KEYFRAME");
  butts.add(delCommentButt);
  
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
  
  // Create keymap
  creditButtL.keyMap.right = creditButtR;
  creditButtL.keyMap.up = agendaButtL;
  creditButtL.keyMap.down = commentButt;
  
  creditButtR.keyMap.left = creditButtL;
  creditButtR.keyMap.up = agendaButtR;
  creditButtR.keyMap.down = commentButt;

  agendaButtL.keyMap.right = agendaButtR;
  agendaButtL.keyMap.down = creditButtL;

  agendaButtR.keyMap.left = agendaButtL;
  agendaButtR.keyMap.down = creditButtR;
  
  commentButt.keyMap.left = creditButtL;
  commentButt.keyMap.right = creditButtR;
  commentButt.keyMap.up = creditButtL;
  
  animButtsR = new ArrayList<Butt>();
  animButtsL = new ArrayList<Butt>();

  selAnimsLeft = new ArrayList<Keyframe>();
  selAnimsRight = new ArrayList<Keyframe>();
  
  nullMap = new KeyMap();
  nullMap.left = creditButtL;
  nullMap.right = creditButtR;
  nullMap.down = commentButt;
  
  createAnimMenus();
}

void createAnimMenus() {
  animMenuL = new ArrayList<Butt>();
  animMenuR = new ArrayList<Butt>();
  int j = 0;
  if (expAnims!=null) {
    for (int i = 0; i < expAnims.size(); i++) {
      AnimConfig _ACfg = expAnims.get(i); 
      if (_ACfg.side != RIGHTPLAYER) {
        String buttname = _ACfg.name;
        buttname = buttname.toUpperCase();
        Butt tButt = new Butt(buttname, addAniButtL.x+190+5, addAniButtL.y + (28 * j), 190, 24);
        tButt.verb = "ANIML";
        tButt.noun = _ACfg.name;
        tButt.setStyle("ANIML");
        animMenuL.add(tButt);
        j++;
      }
    }
    j = 0;
    for (int i = 0; i < expAnims.size(); i++) {
      AnimConfig _ACfg = expAnims.get(i);
      if (_ACfg.side != LEFTPLAYER) {
        String buttname = _ACfg.name;
        buttname = buttname.toUpperCase();
        Butt tButt = new Butt(buttname, addAniButtR.x-(190+5), addAniButtR.y + (28 * j), 190, 24);
        tButt.verb = "ANIMR";
        tButt.noun = _ACfg.name;
        tButt.setStyle("ANIMR");
        animMenuR.add(tButt);
        j++;
      }
    }
  }
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
    tButt.setStyle("LIST");
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
    if (butts.get(i).visible) {
      butts.get(i).drawMe();
    }
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
  
  tempFrame = getKeyframe(KFCOMMENTS, headPos, LEFTPLAYER);
  if (tempFrame != null && tempFrame.time < (headPos - 1.0f)) {
    tempFrame = null;
  }
  if (selFrameComment != tempFrame || commentButt.dirty) {
    if (tempFrame == null) {
      commentButt.t = "(note)";
      commentButt.w = int(stringButtSize(commentButt.t)+20);
      commentButt.x = int((videoWidth / 2) - (commentButt.w / 2));
      delCommentButt.x = commentButt.x - 17;
    } else {
      commentButt.t = trimStringToSize(tempFrame.stringValue, 600);
      commentButt.w = int(stringButtSize(commentButt.t)+20);
      commentButt.x = int((videoWidth / 2) - (commentButt.w / 2));
      delCommentButt.x = commentButt.x - 17;
    }
    selFrameComment = tempFrame;
    commentButt.dirty = false;
  }
  if (!moviePaused && selFrameComment == null) {
    commentButt.visible = false;
  } else {
    commentButt.visible = true;
  }
  if (selFrameComment == null) {
    delCommentButt.visible = false;
  } else {
    delCommentButt.visible = true;
  }
  
  // Anims
  boolean _leftDirty = false;
  boolean _rightDirty = false;
  ArrayList <Keyframe> _tempAnisL = getAnims(headPos, LEFTPLAYER);
  ArrayList <Keyframe> _tempAnisR = getAnims(headPos, RIGHTPLAYER);
  if (_tempAnisL.size() != selAnimsLeft.size()) {
    _leftDirty = true;
  } else {
    // Go through all entries in selAnims and check if they are still playing   
    for (int i = 0; i < selAnimsLeft.size(); i++) {
      Keyframe _tempFrame = selAnimsLeft.get(i);
      if (!(_tempFrame.time <= headPos && _tempFrame.time + _tempFrame.duration >= headPos)) {
        _leftDirty = true;
      }
    }
  }
  if (_tempAnisR.size() != selAnimsRight.size()) {
    _rightDirty = true;
  } else {
    // Go through all entries in selAnims and check if they are still playing   
    for (int i = 0; i < selAnimsRight.size(); i++) {
      Keyframe _tempFrame = selAnimsRight.get(i);
      if (!(_tempFrame.time <= headPos && _tempFrame.time + _tempFrame.duration >= headPos)) {
        _rightDirty = true;
      }
    }   
  }
  
  if (_leftDirty) {
    // Repopulate
    selAnimsLeft = _tempAnisL;
    // Clear anim butts
    if (animButtsL != null) {
      for (int i = 0; i < animButtsL.size(); i++) {
        butts.remove(animButtsL.get(i));
      }
    }
    // Re-create anim butts
    animButtsL = new ArrayList<Butt>();
    for (int i = 0; i < selAnimsLeft.size(); i++) {
      Keyframe _tempFrame = selAnimsLeft.get(i);
      String buttname = _tempFrame.stringValue;
      buttname = buttname.toUpperCase();
      Butt tButt = new Butt(buttname, 5+17+4, creditButtL.y + creditButtL.h + 15 + (28 * (i+1)), 190, 24);
      tButt.verb = "";
      tButt.noun = "";
      tButt.setStyle("ANIML");
      tButt.aniKeyframe = _tempFrame;
      
      Butt tButt2 = new Butt("", 5+4, tButt.y+5, 14, 14);
      tButt2.verb = "DELETEANIL";
      tButt2.noun = "" + i;
      tButt2.setStyle("KEYFRAME");
      
      butts.add(tButt);
      butts.add(tButt2);
      animButtsL.add(tButt);
      animButtsL.add(tButt2);
    }
  }
  if (_rightDirty) {
    // Repopulate
    selAnimsRight = _tempAnisR;
    // Clear anim butts
    if (animButtsR != null) {
      for (int i = 0; i < animButtsR.size(); i++) {
        butts.remove(animButtsR.get(i));
      }
    }
    // Re-create anim butts
    animButtsR = new ArrayList<Butt>();
    for (int i = 0; i < selAnimsRight.size(); i++) {
      Keyframe _tempFrame = selAnimsRight.get(i);
      String buttname = _tempFrame.stringValue;
      buttname = buttname.toUpperCase();
      Butt tButt = new Butt(buttname, videoWidth-(190+5+17+4), creditButtR.y + creditButtR.h + 15 + (28 * (i+1)), 190, 24);
      tButt.verb = "DELETEANI";
      tButt.noun = "";
      tButt.setStyle("ANIMR");
      tButt.aniKeyframe = _tempFrame;

      Butt tButt2 = new Butt("", tButt.x+tButt.w+3+4, tButt.y+5, 14, 14);
      tButt2.verb = "DELETEANIR";
      tButt2.noun = "" + i;
      tButt2.setStyle("KEYFRAME");
      
      butts.add(tButt);
      butts.add(tButt2);
      animButtsR.add(tButt);
      animButtsR.add(tButt2);
    }
  }
  if (!moviePaused) {
    addAniButtL.visible = false;
    addAniButtR.visible = false;
  } else {
    addAniButtL.visible = true;
    addAniButtR.visible = true;
  }
}

// Draws buttons next to overlay buttons to indicate
// if you are currently on a keyframe
// You can click the buttons to delete a keyframe
void drawKeyframes() {
  fill(color5);
  noStroke();
  
  delAgendaButtL.visible = false;
  delAgendaButtR.visible = false;
  delCreditButtL.visible = false;
  delCreditButtR.visible = false;
  
  if (selFrameAgendaLeft != null) {
    delAgendaButtL.visible = true; 
  }
  if (selFrameAgendaRight != null) {
    delAgendaButtR.visible = true;  
  }
  if (selFrameCreditLeft != null) {
    delCreditButtL.visible = true;
  }
  if (selFrameCreditRight != null) {
    delCreditButtR.visible = true;
  }
}

void updateMouseOver() {
  Butt tButt;
  for (int i = 0; i < butts.size(); i++) {
    tButt = butts.get(i);
    if (tButt.sustain > 0) {
      tButt.sustain--;
    } else {
      if (tButt.visible &&
          mouseX >= tButt.x &&
          mouseX <= tButt.x+tButt.w &&
          mouseY >= tButt.y &&
          mouseY <= tButt.y+tButt.h) {
        
        tButt.state = "OVER";
      } else if (tButt.visible && tButt == keyboardSelect) {
        tButt.state = "OVER";
      } else {
        tButt.state = "";
      }
    }
  }
  trackerMousePos = getTrackerMousePos();
  detailMousePos = getDetailMousePos();
}

void updateMouseOverMenu() {
  Butt tButt;
  for (int i = 0; i < buttMenu.size(); i++) {
    tButt = buttMenu.get(i);
    if (tButt.sustain > 0) {
      tButt.sustain--;
    } else {
      if (tButt.visible &&
          mouseX >= tButt.x &&
          mouseX <= tButt.x+tButt.w &&
          mouseY >= tButt.y &&
          mouseY <= tButt.y+tButt.h) {
        
        tButt.state = "OVER";
      } else if (tButt.visible && tButt == keyboardSelect) {
        tButt.state = "OVER";
      } else {
        tButt.state = "";
      }
    }
  }  
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

float getDetailMousePos() {
  float ret;
  if (mouseY > detailBarY && mouseY < detailBarY + detailBarHeight) {
    ret = ((mouseX - detailBarX) / detailBarWidth);
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
    if (tButt.sustain <= 0) {
      if (tButt.visible &&
          mouseX >= tButt.x &&
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
  
  if (UIMode=="EDIT") {
    detailMousePos = getDetailMousePos();
    if (detailMousePos != -1) {
      detailBarClick();
    }
  }
}

void updateMouseClickMenu() {
  Butt tButt;
  for (int i = 0; i < buttMenu.size(); i++) {
    tButt = buttMenu.get(i);
    if (tButt.sustain <= 0) {
      if (tButt.visible &&
          mouseX >= tButt.x &&
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
}

void updateMousePressed() {
  if (UIMode=="EDIT") {
    trackerMousePos = getTrackerMousePos();
    if (trackerMousePos != -1) {
      setHeadPercent(trackerMousePos);
    }
  }
}

void buttonCommand(String _verb, String _noun) {
  //println(_verb + " " + _noun);
  if (_verb == "LOAD") {
    if (_noun == "") {
      dialogMouseLockout = true;
      selectInput("Select a video to load:", "fileSelected");
      lastNoClick = true;
    } else {
      videoCon = new VideoContainer();
      loadMovie(_noun, videoCon);
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
  } else if (_verb == "COMMENT") {
    beginCommentInput();
  } else if (_verb == "ADDANIM") {
    if (_noun == "L") {
      beginAddAnim(LEFTPLAYER);
    } else {
      beginAddAnim(RIGHTPLAYER);
    }    
  } else if (_verb == "SAVE") {
    saveVData();
  } else if (_verb == "EXPORT") {
    dialogMouseLockout = true;
    selectOutput("Export as Final Cut XML:", "fileSelectedExport");
    lastNoClick = true;
  } else if (_verb == "SAVECLOSE") {
    saveVData();
    switchToLoad();
  } else if (_verb == "ANIML") {
    animButt(_noun, LEFTPLAYER);
    beginAnimPos();
  } else if (_verb == "ANIMR") {
    animButt(_noun, RIGHTPLAYER);
    beginAnimPos();
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
  } else if (_verb == "DELETE") {
    if (_noun == "LA") {
      clearKeyframe(KFAGENDAS, headPos, LEFTPLAYER);
    } else if (_noun == "RA") {
      clearKeyframe(KFAGENDAS, headPos, RIGHTPLAYER);
    } else if (_noun == "LC") {
      clearKeyframe(KFCREDITS, headPos, LEFTPLAYER);
    } else if (_noun == "RC") {
      clearKeyframe(KFCREDITS, headPos, RIGHTPLAYER);
    } else if (_noun == "COMMENT") {
      commentConfirm("");
      commentButt.dirty = true;
    }
  } else if (_verb == "DELETEANIL") {
    clearAnimKeyframe(LEFTPLAYER,int(_noun));
  } else if (_verb == "DELETEANIR") {
    clearAnimKeyframe(RIGHTPLAYER,int(_noun));
  }
  
}

boolean buttonCommandPlus(String _verb, String _noun) {
  if (_verb == "AGENDA") {
    buttonCommand(_verb, _noun);
    return true;
  } else if (_verb == "CREDIT") {
    buttonCommand(_verb, _noun);
    return true;
  }
  return false;
}

boolean buttonCommandMinus(String _verb, String _noun) {
  if (_verb == "AGENDA") {
    buttonCommandRight(_verb, _noun);
    return true;
  } else if (_verb == "CREDIT") {
    buttonCommandRight(_verb, _noun);
    return true;
  }
  return false;
}

boolean buttonCommandEnter(String _verb, String _noun) {
  if (_verb == "LOAD") {
    buttonCommand(_verb, _noun);
    return true;
  } else if (_verb == "COMMENT") {
    buttonCommand(_verb, _noun);
    return true;
  } else if (_verb == "SAVE") {
    buttonCommand(_verb, _noun);
    return true;
  } else if (_verb == "EXPORT") {
    buttonCommand(_verb, _noun);
    return true;
  } else if (_verb == "SAVECLOSE") {
    buttonCommand(_verb, _noun);
    return true;
  }
  return false;
}

boolean buttonCommandDel(String _verb, String _noun) {
  if (_verb == "AGENDA") {
    if (_noun == "L") {
      clearKeyframe(KFAGENDAS, headPos, LEFTPLAYER);
    } else {
      clearKeyframe(KFAGENDAS, headPos, RIGHTPLAYER);
    }
    return true;
  } else if (_verb == "CREDIT") {
    if (_noun == "L") {
      clearKeyframe(KFCREDITS, headPos, LEFTPLAYER);
    } else {
      clearKeyframe(KFCREDITS, headPos, RIGHTPLAYER);
    }
    return true;
  } else if (_verb == "COMMENT") {
    commentConfirm("");
    commentButt.dirty = true;
    return true;
  }
  return false;
}

// This is what gets executed when you press a button to add an Anim
void animButt(String _anim, int _side) {
  inputKeyframe = new Keyframe();
  inputKeyframe.type = KFANIMS;
  inputKeyframe.time = headPos;
  inputKeyframe.value = 0;
  inputKeyframe.side = _side;
  inputKeyframe.stringValue = _anim;
  inputKeyframe.duration = getAnimLength(_anim);
  inputTarget = "NEW";
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

float stringButtSize(String _s) {
  textFont(commentRoboto);
  return textWidth(_s);
}

String trimStringToSize(String _s, int _maxw) {
  String _ret = _s;
  textFont(commentRoboto);
  if (textWidth(_ret) > _maxw) {
    for (int i=1; i < _s.length(); i++) {
      _ret = _s.substring(0, _s.length()-i) + "...";
      if (textWidth(_ret) <= _maxw) {
        return _ret;
      }
    }
  }
  return _ret;
}

void dashedLine(float _x1, float _y1, float _x2, float _y2, float _dashLen) {
  float _dist = dist(_x1, _y1, _x2, _y2);
  float dashCount = _dist / _dashLen;
  
  float xdiff = (_x2 - _x1) / dashCount;
  float ydiff = (_y2 - _y1) / dashCount;
  
  float _sx = _x1;
  float _sy = _y1;
  float _dx = _sx + xdiff;
  float _dy = _sy + ydiff;
  
  int i;
  
  i = 0;
  do {
    if (i % 4 == 0) {
      line(_sx, _sy, _dx, _dy);
    }
    _sx = _dx;
    _sy = _dy;
    _dx = _sx + xdiff;
    _dy = _sy + ydiff;
    i++;

  } while (i < int(dashCount));

}  
  