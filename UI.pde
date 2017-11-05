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

  nullMap.left = buttMenu.get(0);
  nullMap.right = buttMenu.get(0);
  nullMap.down = buttMenu.get(0);
  nullMap.up = buttMenu.get(0);
}

void beginAnimPos() {
  if (buttMenu == null) {
    String tmpTarget = inputTarget;
    beginAddAnim(inputKeyframe.side);
    inputTarget = tmpTarget;
    for (int i = 0; i < buttMenu.size(); i++) {
      Butt tButt = buttMenu.get(i);
      if (tButt.noun == inputKeyframe.stringValue) {
        tButt.state = "CLICK";
      }
    }
    if (inputKeyframe.side == LEFTPLAYER) {
      addAniButtL.state = "CLICK";
    } else if (inputKeyframe.side == RIGHTPLAYER) {
      addAniButtR.state = "CLICK";
    }
  }
  inputMode = "ANIMPOS";
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

void inputAnimPosLast() {
  inputX = inputLastX;
  inputY = inputLastY;
  inputConfirm();
}

void inputConfirm() {
  if (inputMode == "ANIMPOS") {
    inputKeyframe.x = inputX;
    inputKeyframe.y = inputY;
    if (inputTarget == "NEW") {
      addThisKeyframe(inputKeyframe);
    }
    rememberAnimPos(inputKeyframe);
    buttMenu = null;
  }
  inputMode = "EDITING";
  if (inputTarget == "COMMENT") {
    commentConfirm(inputText);
    commentButt.dirty = true;
    commentButt.caret = false;
  }
  inputText = "";
  inputTarget = "";
  keyboardSelect = null;
  createKeymap();
}

void inputCancel() {
  inputMode = "EDITING";
  if (inputTarget == "COMMENT") {
    commentButt.dirty = true;
    commentButt.caret = false;
  }
  keyboardSelect = null;
  createKeymap();
  buttMenu = null;
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

void createKeymap() {

  // Create keymap
  creditButtL.keyMap.right = creditButtR;
  creditButtL.keyMap.up = agendaButtL;
  creditButtL.keyMap.down = addAniButtL;

  creditButtR.keyMap.left = creditButtL;
  creditButtR.keyMap.up = agendaButtR;
  creditButtR.keyMap.down = addAniButtR;

  addAniButtL.keyMap.right = addAniButtR;
  addAniButtL.keyMap.up = creditButtL;
  addAniButtL.keyMap.down = commentButt;

  addAniButtR.keyMap.left = addAniButtL;
  addAniButtR.keyMap.up = creditButtR;
  addAniButtR.keyMap.down = commentButt;

  agendaButtL.keyMap.right = agendaButtR;
  agendaButtL.keyMap.down = creditButtL;

  agendaButtR.keyMap.left = agendaButtL;
  agendaButtR.keyMap.down = creditButtR;

  commentButt.keyMap.left = addAniButtL;
  commentButt.keyMap.right = addAniButtR;
  commentButt.keyMap.up = addAniButtL;

  Butt tButt = null;
  Butt lastButt = null;
  if (animButtsL.size() != 0) {
    for (int i = 0; i < animButtsL.size(); i++) {
      tButt = animButtsL.get(i);
      if (tButt.verb == "EDITANI") {
        if (lastButt == null) {
          tButt.keyMap.up = addAniButtL;
          addAniButtL.keyMap.down = tButt;
        } else {
          tButt.keyMap.up = lastButt;
          lastButt.keyMap.down = tButt;
        }
        tButt.keyMap.right = addAniButtR;
        lastButt = tButt;
      }
    }
    lastButt.keyMap.down = commentButt;
    commentButt.keyMap.left = lastButt;
    commentButt.keyMap.up = lastButt;
  }
  tButt = null;
  lastButt = null;
  if (animButtsR.size() != 0) {
    for (int i = 0; i < animButtsR.size(); i++) {
      tButt = animButtsR.get(i);
      if (tButt.verb == "EDITANI") {
        if (lastButt == null) {
          tButt.keyMap.up = addAniButtR;
          addAniButtR.keyMap.down = tButt;
        } else {
          tButt.keyMap.up = lastButt;
          lastButt.keyMap.down = tButt;
        }
        tButt.keyMap.right = addAniButtL;
        lastButt = tButt;
      }
    }
    lastButt.keyMap.down = commentButt;
    commentButt.keyMap.right = lastButt;
  }

  nullMap.left = creditButtL;
  nullMap.right = creditButtR;
  nullMap.down = commentButt;
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
        tButt.side = LEFTPLAYER;
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
        tButt.side = RIGHTPLAYER;
        animMenuR.add(tButt);
        j++;
      }
    }
    Butt tButt = null;
    Butt lastButt = null;
    Butt firstButt = null;
    if (animMenuL.size() != 0) {
      for (int i = 0; i < animMenuL.size(); i++) {
        tButt = animMenuL.get(i);
        if (lastButt == null) {
          firstButt = tButt;
        } else {
          tButt.keyMap.up = lastButt;
          lastButt.keyMap.down = tButt;
        }
        lastButt = tButt;
      }
      lastButt.keyMap.down = firstButt;
      firstButt.keyMap.up = lastButt;
      lastButt = null;
      firstButt = null;
      tButt = null;
    }
    if (animMenuR.size() != 0) {
      for (int i = 0; i < animMenuR.size(); i++) {
        tButt = animMenuR.get(i);
        if (lastButt == null) {
          firstButt = tButt;
        } else {
          tButt.keyMap.up = lastButt;
          lastButt.keyMap.down = tButt;
        }
        lastButt = tButt;
      }
      lastButt.keyMap.down = firstButt;
      firstButt.keyMap.up = lastButt;
      lastButt = null;
      firstButt = null;
      tButt = null;
    }
  }
}

void createExportList() {
  exportList = new String[0];
  for (int i = 0; i < butts.size(); i++) {
    Butt tButt = butts.get(i);
    if (tButt.verb == "CHECKLIST" && tButt.t == "1") {
      exportList = append(exportList, tButt.noun);
    }
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

void mouseClearButts() {
  for (int i = 0; i < butts.size(); i++) {
    if (butts.get(i).visible) {
      butts.get(i).state = "";
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
      tButt.verb = "EDITANI";
      tButt.noun = "" + i;
      tButt.side = LEFTPLAYER;
      tButt.setStyle("ANIML");
      tButt.aniKeyframe = _tempFrame;

      Butt tButt2 = new Butt("", 5+4, tButt.y+5, 14, 14);
      tButt2.verb = "DELETEANIL";
      tButt2.noun = "" + i;
      tButt2.side = LEFTPLAYER;
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
      tButt.verb = "EDITANI";
      tButt.noun = "" + i;
      tButt.side = RIGHTPLAYER;
      tButt.setStyle("ANIMR");
      tButt.aniKeyframe = _tempFrame;

      Butt tButt2 = new Butt("", tButt.x+tButt.w+3+4, tButt.y+5, 14, 14);
      tButt2.verb = "DELETEANIR";
      tButt2.noun = "" + i;
      tButt2.side = RIGHTPLAYER;
      tButt2.setStyle("KEYFRAME");

      butts.add(tButt);
      butts.add(tButt2);
      animButtsR.add(tButt);
      animButtsR.add(tButt2);
    }
  }
  if (_rightDirty || _leftDirty) {
    createKeymap();
  }
  if (!moviePaused) {
    addAniButtL.visible = false;
    addAniButtR.visible = false;
  } else {
    addAniButtL.visible = true;
    addAniButtR.visible = true;
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

  // Check if Mouse is over volume slider
  if (mouseX >= (width - volumeSliderWidth) &&
      mouseX <= width &&
      mouseY >= menuY &&
      mouseY <= menuY + menuHeight) {

        volumeSliderOver = true;
        volumeSliderClicked = false;
  } else {
    volumeSliderOver = false;
    volumeSliderClicked = false;
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
          if (tButt.verb == "CHECKLIST") {
            // This is such a hack
            if (tButt.t.equals("0")) {
              tButt.t = "1";
            } else {
              tButt.t = "0";
            }
          } else {
            buttonCommand(tButt.verb, tButt.noun, tButt.aniKeyframe);
          }
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

    // Check if Mouse is over volume slider
    if (mouseX >= (width - volumeSliderWidth) &&
        mouseX <= width &&
        mouseY >= menuY &&
        mouseY <= menuY + menuHeight) {

          volumeSliderClick();
    } else {
      volumeSliderClicked = false;
      volumeSliderOver = false;
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
          mouseY <= tButt.y+tButt.h &&
          tButt.state != "CLICK") {


        tButt.state = "CLICK";
        if (mouseButton == LEFT) {
          buttonCommand(tButt.verb, tButt.noun, null);
          return;
        } else if (mouseButton == RIGHT) {
          buttonCommandRight(tButt.verb, tButt.noun);
          return;
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

    // Check if Mouse is over volume slider
    if (mouseX >= (width - volumeSliderWidth) &&
        mouseX <= width &&
        mouseY >= menuY &&
        mouseY <= menuY + menuHeight) {

          volumeSliderClick();
    } else {
      volumeSliderClicked = false;
      volumeSliderOver = false;
    }
  }
}

void buttonCommand(String _verb, String _noun, Keyframe _kf) {
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
    animNewButt(_noun, LEFTPLAYER);
  } else if (_verb == "ANIMR") {
    animNewButt(_noun, RIGHTPLAYER);
  } else if (_verb == "EDITANI") {
    animButt(_kf);
    beginAnimPos();
  } else if (_verb == "EXPORTMULT") {
    switchToExport();
  } else if (_verb == "EXPORTCANCEL") {
    switchToLoad();
  } else if (_verb == "EXPORTCONFIRM") {
    createExportList();
    if (exportList.length > 0) {
      dialogMouseLockout = true;
      selectOutput("Export as Final Cut XML:", "fileSelectedExportM");
      lastNoClick = true;
    }
  }
}

void buttonCommandRight(String _verb, String _noun) {
  if (_verb == "LOAD") {
    if (_noun != "") {
      // Delete that button here
      removeFromHistory(_noun);
      switchToLoad();
    }
  } else if (_verb == "AGENDA") {
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

boolean buttonCommandPlus(String _verb, String _noun, Keyframe _kf) {
  if (_verb == "AGENDA") {
    buttonCommand(_verb, _noun, null);
    return true;
  } else if (_verb == "CREDIT") {
    buttonCommand(_verb, _noun, null);
    return true;
  }
  return false;
}

boolean buttonCommandMinus(String _verb, String _noun, Keyframe _kf) {
  if (_verb == "AGENDA") {
    buttonCommandRight(_verb, _noun);
    return true;
  } else if (_verb == "CREDIT") {
    buttonCommandRight(_verb, _noun);
    return true;
  }
  return false;
}

boolean buttonCommandEnter(String _verb, String _noun, Keyframe _kf) {
  if (_verb == "LOAD") {
    buttonCommand(_verb, _noun, _kf);
    return true;
  } else if (_verb == "COMMENT") {
    buttonCommand(_verb, _noun, _kf);
    return true;
  } else if (_verb == "SAVE") {
    buttonCommand(_verb, _noun, _kf);
    return true;
  } else if (_verb == "EXPORT") {
    buttonCommand(_verb, _noun, _kf);
    return true;
  } else if (_verb == "SAVECLOSE") {
    buttonCommand(_verb, _noun, _kf);
    return true;
  } else if (_verb == "ANIML" || _verb == "ANIMR") {
    buttonCommand(_verb, _noun, _kf);
  } else if (_verb == "ADDANIM") {
    buttonCommand(_verb, _noun, _kf);
    if (_noun == "L") {
      keyboardSelect = animMenuL.get(0);
    } else {
      keyboardSelect = animMenuR.get(0);
    }
  } else if (_verb == "EDITANI") {
    buttonCommand(_verb, _noun, _kf);
  }
  return false;
}

boolean buttonCommandDel(String _verb, String _noun, Keyframe _kf) {
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
  } else if (_verb == "EDITANI") {
    clearAnimKeyframe(_kf.side,int(_noun));
    keyboardSelect = null;
    return true;
  }
  return false;


}

// This is what gets executed when you press a button from the dropdown list of animations to add an Anim
void animNewButt(String _anim, int _side) {
  inputKeyframe = new Keyframe();
  inputKeyframe.type = KFANIMS;
  inputKeyframe.time = headPos;
  inputKeyframe.value = 0;
  inputKeyframe.side = _side;
  inputKeyframe.stringValue = _anim;
  inputKeyframe.duration = getAnimLength(_anim);

  AnimPos _tapos =  getAnimPosMem(_anim, _side);
  if (_tapos == null) {
    inputLastX = 0.0;
    inputLastY = 0.0;
  } else {
    inputLastX = _tapos.x;
    inputLastY = _tapos.y;
  }
  inputTarget = "NEW";
  AnimConfig _ac = getAnimCfg(_anim);
  if (_ac != null) {
    inputPositioning = _ac.positioning;
  } else {
    inputPositioning = 0;
  }
  beginAnimPos();
}

// This is what gets executed when you press a button to edit an animation
void animButt(Keyframe _kf) {
  inputKeyframe = _kf;
  inputLastX = _kf.x;
  inputLastY = _kf.y;
  inputTarget = "EDIT";

  AnimConfig _ac = getAnimCfg(_kf.stringValue);
  if (_ac != null) {
    inputPositioning = _ac.positioning;
  } else {
    inputPositioning = 0;
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

void drawAniPosReminder() {
  String t = "CLICK - Place\nENTER - Place at previous position\nESC - Cancel";
  float _w = 220;
  float _h = 63;
  float _x = (videoWidth /2) - (_w/2);
  float _y = videoY + videoHeight - (_h+5);
  noStroke();
  fill(color1);
  rect(_x, _y, _w, _h, 2);
  textAlign(LEFT);
  textFont(smallRoboto);
  fill(color1b);
  text(t,_x+12,_y+4,_w-12,_h-4);
}

void volumeSliderClick() {
  volumeSliderClicked = true;

  float newVol = mouseX - ((width - volumeSliderWidth) + volBarX);
  newVol = newVol / volBarW;
  newVol = constrain(newVol,0f,1f);
  setVol(newVol);
}
