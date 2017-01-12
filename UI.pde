
// This draws the video tracker bar
// Not sure if this this the right name
// I mean the progress bar below the video
// Where you can see how far into the video you are
final float trackerLlineThickness = 5;

void drawTrackerBar(int _x, int _y, int _width) {
  
  noStroke();
  textSize(11);
  fill(color4);
  textFont(smallRobotoMono);
  textAlign(LEFT);
  text(formatTimeCode(myMovie.time()), _x + 10, _y + 28);
  textAlign(RIGHT);
  text("-" + formatTimeCode(myMovie.duration()-myMovie.time()), _width-10, _y + 28);
  fill(color4, 72);
  rect(_x + 10, _y + 8, _width-20, trackerLlineThickness);
  fill(color4, 255);
  if (myMovie.duration() > 0) {
    rect(_x + 10, _y + 8, (_width-20) * (myMovie.time()/myMovie.duration()), trackerLlineThickness);
  }  
}

void switchToEdit() {
  UIMode="EDIT";
  purgeButts();
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
    tButt.style = "LIST";
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
    butts.get(i).drawMe();
  }
}

void updateMouseOver() {
  Butt tButt;
  for (int i = 0; i < butts.size(); i++) {
    tButt = butts.get(i);
    if (mouseX >= tButt.x &&
        mouseX <= tButt.x+tButt.w &&
        mouseY >= tButt.y &&
        mouseY <= tButt.y+tButt.h) {
      
      tButt.state = "OVER";
    } else {
      tButt.state = "";
    }
  }
  
  if (mouseY > videoHeight && mouseY < videoHeight + 8 + trackerLlineThickness) {
  
  }
}

void updateMouseClick() {
  Butt tButt;
  for (int i = 0; i < butts.size(); i++) {
    tButt = butts.get(i);
    if (mouseX >= tButt.x &&
        mouseX <= tButt.x+tButt.w &&
        mouseY >= tButt.y &&
        mouseY <= tButt.y+tButt.h) {
      tButt.state = "CLICK";
      buttonCommand(tButt.verb, tButt.noun);
    } else {
      tButt.state = "";
    }
  }
}

void buttonCommand(String _verb, String _noun) {
  if (_verb == "LOAD") {
    if (_noun == "") {
      selectInput("Select a video to load:", "fileSelected");
    } else {
      loadMovie(_noun);
    }
  }
}