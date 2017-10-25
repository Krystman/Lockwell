
void keyPressed() {
  if (inputMode == "") {
    //println("key: " + key + " keyCode: " + keyCode); 
    
    if (key=='q') {
      println("head at " + headPos);
      if (headLocked) {
        println("head locked");
      } else {
        println("head not locked");     
      }
      if (dirty) {
        println("vData dirty");
      } else {
        println("vData clean");     
      }
      int mando = 0;
      if (keyframes != null) {
        for (int i = 0; i < keyframes.size(); i++) {
          Keyframe _tempFrame = keyframes.get(i);
          if (_tempFrame.stringValue.equals("mandatory draw")) {mando++;};
        }
      }
      println("Mandos: " + mando);
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
    
    if (keyCode==32) {
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
      if (keyShift) {
      } else if (keyControl) {
      } else if (keyAlt) {
      } else {
        moveKeySelect(keyCode);
      }
    } else if (keyCode==UP) {
      if (keyShift) {
      } else if (keyControl) {
      } else if (keyAlt) {
      } else {
        moveKeySelect(keyCode);
      }
    } else if (keyCode==SHIFT) {
      keyShift = true;
    } else if (keyCode==CONTROL) {
      keyControl = true;
    } else if (keyCode==ALT) {
      keyAlt = true;
    } else if (keyCode == ESC) {
      key = 0;
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
  } else if (inputMode == "TEXT") {
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
  } else if (inputMode == "ANIM") {
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
  } else if (inputMode == "ANIMPOS") {
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