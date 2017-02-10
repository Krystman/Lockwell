import processing.video.*;

//Define color palette
final color color1 = #121212; // Dark BG
final color color1b = #a0a0a0; // Neutral text / foreground elements
final color color1c = #181818; // Slightly brighter BG
final color color1d = #3e3e3e; // Dimmed forgeground elemets

final color color2 = #F7B538; // Yellow
final color color3 = #1098F7; // Blue
final color color4 = #AEC5EB; // Pale Blue
final color color5 = #EEEBD3; // Pale Yellow

//Side Definitions
final int LEFTPLAYER = 1;
final int RIGHTPLAYER = 2;

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

String moviePath = "";
String vDataPath = "";
String UIMode = "LOAD";
boolean moviePaused = false;
boolean lastNoClick = true;

PFont smallRobotoMono;
PFont smallRoboto;
PFont agendaRoboto;
PFont credRoboto;

boolean keyShift = false;
boolean keyAlt = false;
boolean keyControl = false;


Keyframe selFrameAgendaLeft;
Keyframe selFrameAgendaRight;
Keyframe selFrameCreditLeft;
Keyframe selFrameCreditRight;

ArrayList <Butt> butts;

ArrayList <Keyframe> keyframes;

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
  
  loadHistory();
  switchToLoad();
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
      
      // Draw Bars
      drawDetailBar();
      drawTrackerBar();
    }
  }
  drawButts();
}

void update() {
  // Update stuff every frame
  if (mousePressed) {
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
}

void keyPressed() {
  
  //println("key: " + key + " keyCode: " + keyCode); 
  
  if (key=='q') {
    println("head at " + headPos);
    if (headLocked) {
      println("head locked");
    } else {
      println("head not locked");     
    }
  }
  
  if (keyCode==32) {
    buttPause();
  } else if (keyCode==LEFT) {
    //This works well for frame-by-frame rewinding
    //moveHead(-0.05f);
    if (keyShift) {
      moveHead(-1f);
    } else if (keyControl) {
      setHead(getLastKeyframe());
    } else if (keyAlt) {
      moveHead(-10f);
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
    }
  } else if (keyCode==SHIFT) {
    keyShift = true;
  } else if (keyCode==CONTROL) {
    keyControl = true;
  } else if (keyCode==ALT) {
    keyAlt = true;
  }  
}

void keyReleased() {
  
  //println("key: " + key + " keyCode: " + keyCode);  
  if (keyCode==SHIFT) {
    keyShift = false;
  } else if (keyCode==CONTROL) {
    keyControl = false;
  } else if (keyCode==ALT) {
    keyAlt = false;
  }  
}

void buttPause() {
  if (moviePath != "") {
    if (moviePaused) {
      println("Plaing...");
      headLocked = false;
      myMovie.play();
      myMovie.read();
      moviePaused = false;
    } else {
      println("Pausing...");
      headLocked = false;
      myMovie.pause();
      moviePaused = true;
      myMovie.read();
      myMovie.jump(headPos);      
    }
  }
}