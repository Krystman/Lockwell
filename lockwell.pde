import processing.video.*;

//Define color palette
final color color1 = #020122; // BG
final color color2 = #F7B538; // Yellow
final color color3 = #1098F7; // Blue
final color color4 = #AEC5EB; // Pale Blue
final color color5 = #EEEBD3; // Pale Yellow

Movie myMovie;
final float imageratio = 1920.0/1080.0;
final int bottomUI = 40;

int videoHeight = 360;
int videoWidth = 360;
String moviePath = "";
String UIMode = "LOAD";
boolean moviePaused = false;
boolean pauseOnRead = false;
boolean lastNoClick = true;

PFont smallRobotoMono;
PFont smallRoboto;

ArrayList <Butt> butts;

String[] history;

void setup() {
  //setup360();
  //size(640, 400);
  
  //setup480();
  //size(853, 520);
  
  setup720();
  size(1280, 760);
  
  smallRobotoMono = createFont("RobotoMono-Bold.ttf", 10);
  smallRoboto = createFont("Roboto-Bold.ttf", 12);
  
  trackerBarX = 0;
  trackerBarY = videoHeight;
  trackerBarWidth = width;
  
  loadHistory();
  switchToLoad();
}

void setup360() {
  videoWidth = 640;
  videoHeight = 360;
}

void setup480() {
  videoWidth = 853;
  videoHeight = 480;
}

void setup720() {
  videoWidth = 1280;
  videoHeight = 720;
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
        if (pauseOnRead) {
          pauseOnRead = false;
          myMovie.pause();
        }      
      }
      // Draw Video
      image(myMovie, 0, 0, videoWidth,videoHeight);
    }
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
  println("key: " + key + " keyCode: " + keyCode);  
  if (keyCode==32) {
    buttPause();
  } else if (keyCode==LEFT) {
    moveHead(-60);
  } else if (keyCode==RIGHT) {
    moveHead(60);
  }
  
}

void moveHead(float _s) {
  float cur;
  if (moviePath != "") {
    cur = myMovie.time();
    cur += _s;
    cur = constrain(cur, 0, myMovie.duration());
    setHead(cur);
  }  
}

void setHeadPercent(float _s) {
  float cur;
  if (moviePath != "") {
    cur = _s * myMovie.duration();
    cur = constrain(cur, 0, myMovie.duration());
    myMovie.jump(cur);
    if (moviePaused) {
      pauseOnRead = true;
      myMovie.play();
    }
  }  
}

void setHead(float _s) {
  float cur;
  if (moviePath != "") {
    cur = _s;
    cur = constrain(cur, 0, myMovie.duration());
    myMovie.jump(cur);
    if (moviePaused) {
      pauseOnRead = true;
      myMovie.play();
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

void buttPause() {
  if (moviePath != "") {
    if (moviePaused) {
      println("Plaing...");
      myMovie.play();
      myMovie.read();
      moviePaused = false;
      pauseOnRead = false;
    } else {
      println("Pausing...");
      myMovie.pause();
      myMovie.read();
      moviePaused = true;
      pauseOnRead = false;
    }
  }
}