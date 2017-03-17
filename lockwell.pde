// Todo:
// - Ctrl + S for save
// - Resolution select on start screen
// - Keyboard controls on start screen
// - Undo
// - Multi-export
// - UI Notification system

// Currently Working on
// Animation Keyframes / Export etc...
// - Add delete ani butt
// - Add ani button
// - Ani delete / creation functionality
// - Ani position mode
// - Keymap + Keyboard Shortcuts

import controlP5.*;
import processing.video.*;

// Define color palette
final color color1 = #121212; // Dark BG
final color color1b = #a0a0a0; // Neutral text / foreground elements
final color color1c = #181818; // Slightly brighter BG
final color color1d = #3e3e3e; // Dimmed forgeground elemets

final color color2 = #F7B538; // Yellow
final color color3 = #1098F7; // Blue
final color color4 = #AEC5EB; // Pale Blue
final color color5 = #EEEBD3; // Pale Yellow

// Side definitions
final int LEFTPLAYER = 1;
final int RIGHTPLAYER = 2;
final int BOTHPLAYERS = 0;

// Keyframe type definitions
final int KFAGENDAS = 1;
final int KFCREDITS = 2;
final int KFCOMMENTS = 3;
final int KFANIMS = 4;

Movie myMovie;
final float imageratio = 1920.0/1080.0;
final int bottomUI = 40;

int videoHeight = 360;
int videoWidth = 360;
int videoY = 0;

int menuY = 0;
int menuHeight = 5 + 24 + 5;

// Tracker bar is a scrollbar at the bottom of the screen
// It allows you to scroll through the video
float trackerBarX = 0;
float trackerBarY = 0;
float trackerBarWidth = 0;
float trackerBarHeight = 50;
float trackerMousePos;
final float trackerLineThickness = 5;

// Detail bar is a zoomed-in timeline above the tracker bar 
// It shows the keyframes nearby
float detailBarX = 0;
float detailBarY = 0;
float detailBarWidth = 0;
float detailBarHeight = 30;
float detailBarScroll = 0; // The timecode (in seconds) of the left edge of the detail bar
float detailBarTScroll = 0; // The scroll target to scroll to. This is for scroll animation.
float detailBarZoom = 40; // The length of the timeline (in seconds) displayed across the detail bar
float detailMousePos;

String moviePath = "";
String vDataPath = "";
String UIMode = "LOAD";
String inputMode = "";
String inputText = "";
String inputTarget = "";
boolean blink; // This is to make some UI stuff blink
int blinker;

boolean moviePaused = false;
boolean lastNoClick = true;
boolean dialogMouseLockout = false; // Little hack because mouse kept registering as clicked after selectInput

boolean dirty; // indicates if changes have been made to video data

PFont smallRobotoMono;
PFont smallRoboto;
PFont agendaRoboto;
PFont credRoboto;
PFont commentRoboto;
PFont animRoboto;

boolean keyShift = false;
boolean keyAlt = false;
boolean keyControl = false;

Keyframe selFrameAgendaLeft;
Keyframe selFrameAgendaRight;
Keyframe selFrameCreditLeft;
Keyframe selFrameCreditRight;
Keyframe selFrameComment;

ArrayList <Keyframe> selAnimsLeft;
ArrayList <Keyframe> selAnimsRight;

ArrayList <Butt> butts;

ArrayList <Keyframe> keyframes;
VideoContainer videoCon;

Float headPos;
boolean headLocked = false;

String[] history;

void setup() {
  size(640, 400);
  
  //setup360();
  //setup480();
  setup720();
  
  smallRobotoMono = createFont("RobotoMono-Bold.ttf", 10);
  smallRoboto = createFont("Roboto-Bold.ttf", 12);
  agendaRoboto = createFont("Roboto-Bold.ttf", 58);
  credRoboto = createFont("Roboto-Bold.ttf", 32);
  commentRoboto = createFont("Roboto-Bold.ttf", 22);
  animRoboto = createFont("Roboto-Bold.ttf", 16);
  
  loadHistory();
  loadConfig();
  switchToLoad();
  hint(ENABLE_STROKE_PURE);
}

void setup360() {
  videoWidth = 640;
  videoHeight = 360;
  surface.setSize(640, int(360 + 40 + trackerBarHeight + detailBarHeight + menuHeight));
}

void setup480() {
  videoWidth = 853;
  videoHeight = 480;
  surface.setSize(853, int(480 + trackerBarHeight + detailBarHeight + menuHeight));
}

void setup720() {
  videoWidth = 1280;
  videoHeight = 720;
  surface.setSize(1280, int(720 + trackerBarHeight + detailBarHeight + menuHeight));
}

void draw() {
  update();

  // Draw stuff
  clear();
  background(color1);
  
  if (UIMode=="LOAD") {
    drawButts();
  } else if (UIMode=="EDIT") {
    if (myMovie!=null) {
      if (myMovie.available()) {
        myMovie.read();
      }
      if (!headLocked) {
        // This is a bit of a hack
        // Video sometimes kept jumping a tiny bit a second after being paused
        // Made stopping at a specific keyframe impossible
        // So we "freeze" the head position if we jump to a specific time
        headPos = myMovie.time();
      }
      
      // Draw Video
      image(myMovie, 0, videoY, videoWidth,videoHeight);
    
      // Update the scroll of the detail bar and animate
      detailBarTScroll = headPos - (detailBarZoom / 2);
      detailBarTScroll = constrain(detailBarTScroll, 0, myMovie.duration()-detailBarZoom);
      if (moviePaused) {
        detailBarScroll += (detailBarTScroll - detailBarScroll) / 5;
      } else {
        detailBarScroll = detailBarTScroll;
      }
      
      // Update Overlay Values
      updateValues();
      drawKeyframes();
      
      // Draw all buttons
      drawButts();
      
      // Draw Bars
      drawDetailBar();
      drawTrackerBar();
      
      if (inputMode == "TEXT") {
        drawInput();
      }
    }
  }
  
}

void update() {
  blinker++;
  if (blinker < 20) {
    blink = true;
  } else if (blinker < 40) {
    blink = false;
  } else {
    blinker = 0;
  }
  
  if (inputMode == "") {
    // Update stuff every frame
    if (mousePressed == false) {
      dialogMouseLockout = false;
    }
    
    if (mousePressed && !dialogMouseLockout) {
      // LMB
      if (lastNoClick) {
        updateMouseClick();
        lastNoClick = false;
      }
      updateMousePressed();
    } else {
      updateMouseOver();
      lastNoClick = true;
    }
  } else if (inputMode == "TEXT") {
  }

}

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
        KeyMap km;
        if (keyboardSelect == null) {
          km = nullMap;
        } else {
          km = keyboardSelect.keyMap;
        }
        if (km != null) {
          Butt b = km.left;
          if (b != null) {
            pause();
            keyboardSelect = b;
          }
        }
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
        KeyMap km;
        if (keyboardSelect == null) {
          km = nullMap;
        } else {
          km = keyboardSelect.keyMap;
        }
        if (km != null) {
          Butt b = km.right;
          if (b != null) {
            pause();
            keyboardSelect = b;
          }
        }
      }
    } else if (keyCode==DOWN) {
      if (keyShift) {
      } else if (keyControl) {
      } else if (keyAlt) {
      } else {
        KeyMap km;
        if (keyboardSelect == null) {
          km = nullMap;
        } else {
          km = keyboardSelect.keyMap;
        }
        if (km != null) {
          Butt b = km.down;
          if (b != null) {
            pause();
            keyboardSelect = b;
          }
        }
      }
    } else if (keyCode==UP) {
      if (keyShift) {
      } else if (keyControl) {
      } else if (keyAlt) {
      } else {
        KeyMap km;
        if (keyboardSelect == null) {
          km = nullMap;
        } else {
          km = keyboardSelect.keyMap;
        }
        if (km != null) {
          Butt b = km.up;
          if (b != null) {
            pause();
            keyboardSelect = b;
          }
        }
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
        if (buttonCommandMinus(keyboardSelect.verb,keyboardSelect.noun)) {
          keyboardSelect.state = "CLICK";
          keyboardSelect.sustain = 3;
        }
      }
    } else if (key == '+') {
      if (keyboardSelect != null) {
        if (buttonCommandPlus(keyboardSelect.verb,keyboardSelect.noun)) {
          keyboardSelect.state = "CLICK";
          keyboardSelect.sustain = 3;
        }
      }
    } else if (keyCode==ENTER || keyCode == RETURN) {
      if (keyboardSelect != null) {
        if (buttonCommandEnter(keyboardSelect.verb,keyboardSelect.noun)) {
          keyboardSelect.state = "CLICK";
          keyboardSelect.sustain = 3;
        }
      }  
    } else if (keyCode==DELETE || keyCode == BACKSPACE) {
      if (keyboardSelect != null) {
        if (buttonCommandDel(keyboardSelect.verb,keyboardSelect.noun)) {
          keyboardSelect.state = "CLICK";
          keyboardSelect.sustain = 3;
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
  }
}

void keyReleased() {
  if (inputMode == "") {
    //println("key: " + key + " keyCode: " + keyCode);  
    if (keyCode==SHIFT) {
      keyShift = false;
    } else if (keyCode==CONTROL) {
      keyControl = false;
    } else if (keyCode==ALT) {
      keyAlt = false;
    }
  } else if (inputMode == "TEXT") {
    
  }
}

void flipPause() {
  if (moviePath != "") {
    if (moviePaused) {
      play();
    } else {
      pause();  
    }
  }
}

void pause() {
  if (moviePath != "") {
    if (!moviePaused) {
      println("Pausing...");
      headLocked = false;
      myMovie.pause();
      moviePaused = true;
      myMovie.read();
      myMovie.jump(headPos);      
    }
  }
}

void play() {
  if (moviePath != "") {
    if (moviePaused) {
      println("Plaing...");
      headLocked = false;
      myMovie.play();
      myMovie.read();
      moviePaused = false;
      keyboardSelect = null;
      if (dirty) {
        dirty = false;
        saveVData();
      }     
    }
  }
}

void stop() {
  if (myMovie!=null) {
    myMovie.stop();
    myMovie.dispose();
    myMovie = null;
  }
}