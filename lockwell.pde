import processing.video.*;

//Define color palette
final color color1 = #020122; // BG
final color color2 = #F7B538; // Yellow
final color color3 = #1098F7; // Blue
final color color4 = #AEC5EB; // Pale Blue
final color color5 = #EEEBD3; // Pale Yellow

Movie myMovie;
float imageratio = 1920.0/1080.0;
int videoheight = 360;
String moviePath = "";
boolean moviePaused = false;

void setup() {
  size(640, 400);
  selectInput("Select a file to process:", "fileSelected");
}

void draw() {
  update();
  
  // Draw stuff
  clear();
  background(color1);
  if (myMovie!=null) {
    // Draw Video
    image(myMovie, 0, 0, int(videoheight*imageratio),videoheight);
    
    // Draw Timecode
    noStroke();
    textSize(11);
    fill(color4);
    textAlign(LEFT);
    text(formatTimeCode(myMovie.time()), 10, videoheight + 32);
    textAlign(RIGHT);
    text("-" + formatTimeCode(myMovie.duration()-myMovie.time()), width-10, videoheight + 32);
    fill(color3);
    rect(10,videoheight + 8, width-20, 2);
    fill(color2);
    if (myMovie.duration() > 0) {
      rect(10,videoheight + 8, (width-20) * (myMovie.time()/myMovie.duration()), 2);
    }
  } else {
    stroke(color4);
    strokeWeight(3);
    noFill();
    rect(10,10,width-20,videoheight-20);
    line(10,10,width-10,videoheight-10);
    line(10,videoheight-10,width-10,10);
  }
}

void update() {
  // Update stuff every frame
}

void loadMovie(String _f) {
  // loads a movie
  println("Loading movie " + _f);
  moviePath = _f;
  myMovie = new Movie(this, _f);
  myMovie.play();
  myMovie.pause();
  moviePaused=true;
  myMovie.read();
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    loadMovie(selection.getAbsolutePath());
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
    myMovie.jump(cur);
    if (moviePaused) {
      myMovie.play();
      myMovie.read();
      myMovie.pause();
    } else {
      myMovie.read();
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
      moviePaused=false;
    } else {
      println("Pausing...");
      myMovie.pause();
      myMovie.read();
      moviePaused=true;
    }
  }
}