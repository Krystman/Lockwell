import processing.video.*;

//Define color palette
final color color1 = #020122; // BG
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
String moviePath = "";
String vDataPath = "";
String UIMode = "LOAD";
boolean moviePaused = false;
boolean lastNoClick = true;

PFont smallRobotoMono;
PFont smallRoboto;
PFont agendaRoboto;
PFont credRoboto;

AgendaEvent selectedAEventLeft;
AgendaEvent selectedAEventRight;
CreditEvent selectedCEventLeft;
CreditEvent selectedCEventRight;

ArrayList <Butt> butts;

ArrayList <AgendaEvent> agendaEvents;
ArrayList <CreditEvent> creditEvents;
Float headPos;

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
  
  trackerBarX = 0;
  trackerBarY = videoHeight;
  trackerBarWidth = width;
  
  loadHistory();
  switchToLoad();
}

void setup360() {
  videoWidth = 640;
  videoHeight = 360;
  surface.setSize(640, 360+40);
}

void setup480() {
  videoWidth = 853;
  videoHeight = 480;
  surface.setSize(853, 480+40);
}

void setup720() {
  videoWidth = 1280;
  videoHeight = 720;
  surface.setSize(1280, 720+40);
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
      headPos = myMovie.time();
      // Draw Video
      image(myMovie, 0, 0, videoWidth,videoHeight);
    }
    
    // Update Overlay Values
    updateValues();
    drawKeyframes();
    
    // Draw Tracker Bar
    drawTrackerBar();
  }
  drawButts();
}



void update() {
  // Update stuff every frame
  if (mousePressed && (mouseButton == LEFT)) {
    // LMB
    if (lastNoClick) {
      updateMouseClick();
      lastNoClick = false;
    }
    updateMousePressed();
  } else if (mousePressed && (mouseButton == RIGHT)) {
    // RMB
  } else {
    updateMouseOver();
    lastNoClick = true;
  }
}

void keyPressed() {
  //println("key: " + key + " keyCode: " + keyCode);  
  if (keyCode==32) {
    buttPause();
  } else if (keyCode==LEFT) {
    //This works well for frame-by-frame rewinding
    //moveHead(-0.05f);
    moveHead(-30f);
  } else if (keyCode==RIGHT) {
    //This works well for frame-by-frame rewinding
    //moveHead(0.05f);
    moveHead(30f);
  }
  
}

void buttPause() {
  if (moviePath != "") {
    if (moviePaused) {
      println("Plaing...");
      myMovie.play();
      myMovie.read();
      moviePaused = false;
    } else {
      println("Pausing...");
      myMovie.pause();
      myMovie.read();
      moviePaused = true;
    }
  }
}