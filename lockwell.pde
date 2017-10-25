// Todo:
// - Seperate into Keybord commands during editng and in main screen
// - Keyboard Debug Overlay
// - Volume
// - Right-click to manually clear history files
// - Keyboard controls on start screen
// - Undo
// - Multi-export
// - UI Notification system
// - Stats display
// - Resolution select on start screen
// - ESC back from animation shortcut to last button
// - Video Export

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

float videoHeight = 360;
float videoWidth = 360;
float videoY = 0;

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
int gapTracks = 0; // How many extra tracks should be added between the video and the overlays. You can set this in the config.xml file
String UIMode = "LOAD";
String inputMode = "";
String inputText = "";
String inputTarget = "";
Float inputX;
Float inputY;
Float inputLastX;
Float inputLastY;
int inputPositioning; // Positioning mode for Animations. 0 - Free, 1 - Only X, 2 - Only Y 
Keyframe inputKeyframe;

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
ArrayList <AnimPos> animPosMem;
VideoContainer videoCon;

Float headPos;
boolean headLocked = false;

String[] history;
String[] exportList;

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
      } else if (inputMode == "ANIM") {
        drawAnimInput();
      } else if (inputMode == "ANIMPOS") {
        drawAnimPosInput();
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
  } else if (inputMode == "ANIM") {
    // Update stuff every frame
    if (mousePressed == false) {
      dialogMouseLockout = false;
    }
    
    if (mousePressed && !dialogMouseLockout) {
      // LMB
      if (lastNoClick) {
        updateMouseClickMenu();
        lastNoClick = false;
      }
    } else {
      updateMouseOverMenu();
      lastNoClick = true;
    }
  } else if (inputMode == "ANIMPOS") {
    // Update stuff every frame
    if (mousePressed == false) {
      dialogMouseLockout = false;
    }
    
    if (mousePressed && !dialogMouseLockout) {
      // LMB
      if (lastNoClick) {
        inputConfirm();
        lastNoClick = false;
      }
    } else {
      lastNoClick = true;
    }    
  }

}

void printDebug() {
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
