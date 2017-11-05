
void keyPressed() {
  // Dealing with the Modifier Keys
  if (keyCode==SHIFT) {
    keyShift = true;
  } else if (keyCode==CONTROL) {
    keyControl = true;
  } else if (keyCode==ALT) {
    keyAlt = true;
  } else if (keyCode == ESC) {
    // Cancel the ESC
    key = 0;
  }

  if (inputMode == "MENU") {
    keyPressedMenu();
  } else if (inputMode == "EDITING") {
    keyPressedEditing();
  } else if (inputMode == "TEXT") {
    keyPressedText();
  } else if (inputMode == "ANIM") {
    keyPressedAnim();
  } else if (inputMode == "ANIMPOS") {
    keyPressedAnimPos();
  }
}

void keyPressedMenu() {
  if (key=='q') {
    // A little debug print
    println("You are in a Menu right now");
  } else if (keyCode == DOWN || keyCode == UP || keyCode == RIGHT || keyCode == LEFT) {
    // Moving around with the keyboard
    moveKeySelect(keyCode);
  } else if (keyCode==ENTER || keyCode == RETURN) {
    if (keyboardSelect != null) {
      keyboardSelect.state = "CLICK";
      keyboardSelect.sustain = 3;
      if (keyboardSelect.verb == "CHECKLIST") {
        // This is such a hack
        // We're doing it here because buttonComand has no reference to the button
        // Might be wise to just pass butt to buttonCommand in the future
        if (keyboardSelect.t.equals("0")) {
          keyboardSelect.t = "1";
        } else {
          keyboardSelect.t = "0";
        }
      } else {
        buttonCommandEnter(keyboardSelect.verb,keyboardSelect.noun,keyboardSelect.aniKeyframe);
      }
    }
  }
}

void keyPressedEditing() {
  //println("key: " + key + " keyCode: " + keyCode);

  // Pre-baked shortcuts

  if (key=='q') {
    // Print debug into the Processing console on q
    printDebug();
  } else if (keyCode==83 && keyControl) {
    // Ctrl + S for Save Project
    saveVData();
  } else if (keyCode==123) {
    // Toggle Debug Overlay
    debugOverlay = !debugOverlay;
  } else if (keyCode == 90 && keyControl && !keyShift) {
    undo();
  } else if ((keyCode == 90 && keyControl && keyShift) || (keyCode == 89 && keyControl)) {
    redo();
  }

  // Check if animation keyframe shortcut
  if (!keyShift && !keyControl && !keyAlt) {
    if (expAnims != null && keyboardSelect != null && keyboardSelect.side != BOTHPLAYERS) {
      AnimConfig _found = null;
      for (int i=0; i < expAnims.size(); i++) {
        AnimConfig _tacfg = expAnims.get(i);
        if (_tacfg.keyShortcut == key && (_tacfg.side == keyboardSelect.side || _tacfg.side == BOTHPLAYERS)) {
          _found = _tacfg;
          break;
        }
      }
      if (_found != null) {
        mouseClearButts();
        animNewButt(_found.name,keyboardSelect.side);
        keyboardSelect = null;
      }
    }
  }

  // Keyboard input to manipulate UI
  if (keyCode==32) {
    // Space
    flipPause();
  } else if (keyCode==LEFT) {
    //This works well for frame-by-frame rewinding
    //moveHead(-0.05f);
    if (keyShift) {
      moveHead(-1f);
    } else if (keyControl) {
      setHead(getLastKeyframe());
    } else if (keyAlt) {
      moveHead(-10f);
    } else {
      moveKeySelect(keyCode);
    }
  } else if (keyCode==RIGHT) {
    //This works well for frame-by-frame rewinding
    //moveHead(0.05f);
    if (keyShift) {
      moveHead(1f);
    } else if (keyControl) {
      setHead(getNextKeyframe());
    } else if (keyAlt) {
      moveHead(10f);
    } else {
      moveKeySelect(keyCode);
    }
  } else if (keyCode==DOWN) {
    if (keyControl) {
      setVol(movieVol-0.05f);
    } else if (!keyShift && !keyControl && !keyAlt) {
      moveKeySelect(keyCode);
    }
  } else if (keyCode==UP) {
    if (keyControl) {
      setVol(movieVol+0.05f);
    } else if (!keyShift && !keyControl && !keyAlt) {
      moveKeySelect(keyCode);
    }
  } else if (key == 'n') {
    pause();
    beginCommentInput();
  } else if (key == '-') {
    if (keyboardSelect != null) {
      if (buttonCommandMinus(keyboardSelect.verb,keyboardSelect.noun,keyboardSelect.aniKeyframe)) {
        keyboardSelect.state = "CLICK";
        keyboardSelect.sustain = 3;
      }
    }
  } else if (key == '+') {
    if (keyboardSelect != null) {
      if (buttonCommandPlus(keyboardSelect.verb,keyboardSelect.noun,keyboardSelect.aniKeyframe)) {
        keyboardSelect.state = "CLICK";
        keyboardSelect.sustain = 3;
      }
    }
  } else if (keyCode==ENTER || keyCode == RETURN) {
    if (keyboardSelect != null) {
      if (buttonCommandEnter(keyboardSelect.verb,keyboardSelect.noun,keyboardSelect.aniKeyframe)) {
        keyboardSelect.state = "CLICK";
        keyboardSelect.sustain = 3;
      }
    }
  } else if (keyCode==DELETE || keyCode == BACKSPACE) {
    if (keyboardSelect != null) {
      if (buttonCommandDel(keyboardSelect.verb,keyboardSelect.noun,keyboardSelect.aniKeyframe)) {
        if (keyboardSelect != null) {
          keyboardSelect.state = "CLICK";
          keyboardSelect.sustain = 3;
        }
      }
    }
  }
}

void keyPressedText() {
  if (keyCode == BACKSPACE) {
    if (inputText.length() > 0) {
      inputText = inputText.substring(0, inputText.length()-1);
    }
  } else if (keyCode == ENTER || keyCode == RETURN) {
    inputConfirm();
  } else if (keyCode == ESC) {
    key = 0;
    inputCancel();
  } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT && keyCode!=LEFT && keyCode!=RIGHT && keyCode!=UP && keyCode!=DOWN) {
    inputText = inputText + key;
  }
}

void keyPressedAnim() {
  if (keyCode == BACKSPACE || keyCode == ESC) {
    inputCancel();
    key = 0;
  } else if (keyCode==LEFT) {
    moveKeySelect(keyCode);
  } else if (keyCode==RIGHT) {
    moveKeySelect(keyCode);
  } else if (keyCode==DOWN) {
    moveKeySelect(keyCode);
  } else if (keyCode==UP) {
    moveKeySelect(keyCode);
  } else if (keyCode==ENTER || keyCode == RETURN) {
    if (keyboardSelect != null) {
      if (buttonCommandEnter(keyboardSelect.verb,keyboardSelect.noun,keyboardSelect.aniKeyframe)) {
        keyboardSelect.state = "CLICK";
        //keyboardSelect.sustain = 3;
      }
    }
  }
}

void keyPressedAnimPos() {
  if (keyCode == BACKSPACE || keyCode == ESC) {
    inputCancel();
    key = 0;
  } else if (keyCode == ENTER || keyCode == RETURN) {
    inputAnimPosLast();
  } else {
    if (!keyShift && !keyControl && !keyAlt) {
      AnimConfig _acfg = getAnimCfg(inputKeyframe.stringValue);
      if (_acfg != null && _acfg.keyShortcut != 0 && _acfg.keyShortcut == key) {
        inputAnimPosLast();
      }
    }
  }
}


void moveKeySelect(int kc) {
  if (kc == LEFT || kc == UP || kc == RIGHT || kc == DOWN) {
    KeyMap km;
    if (keyboardSelect == null) {
      km = nullMap;
    } else {
      km = keyboardSelect.keyMap;
    }
    if (km != null) {
      Butt b = null;
      if (kc == LEFT) {
        b = km.left;
      } else if (kc == UP) {
        b = km.up;
      } else if (kc == RIGHT) {
        b = km.right;
      } else if (kc == DOWN) {
        b = km.down;
      }
      if (b != null) {
        pause();
        keyboardSelect = b;
      }
    }
  }
}

void keyReleased() {
  if (keyCode==SHIFT) {
    keyShift = false;
  } else if (keyCode==CONTROL) {
    keyControl = false;
  } else if (keyCode==ALT) {
    keyAlt = false;
  } else {
    if (inputMode == "") {
      //println("key: " + key + " keyCode: " + keyCode);
    } else if (inputMode == "TEXT") {

    }
  }
}
