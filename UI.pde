final float trackerLineThickness = 5;
float trackerMousePos = -1;
float trackerBarX = 0;
float trackerBarY = 0;
float trackerBarWidth = 100;

Butt agendaButtL;
Butt agendaButtR;
Butt creditButtL;
Butt creditButtR;

// This draws the video tracker bar
// Not sure if this this the right name
// I mean the progress bar below the video
// Where you can see how far into the video you are

void drawTrackerBar() {
  float mousePos;
  
  noStroke();
  textSize(11);
  fill(color4);
  textFont(smallRobotoMono);
  textAlign(LEFT);
  text(formatTimeCode(myMovie.time()), trackerBarX + 10, trackerBarY + 28);
  textAlign(RIGHT);
  text("-" + formatTimeCode(myMovie.duration()-myMovie.time()), trackerBarWidth-10, trackerBarY + 28);
  fill(color4, 72);
  rect(trackerBarX + 10, trackerBarY + 8, trackerBarWidth-20, trackerLineThickness);
  fill(color4, 255);
  if (myMovie.duration() > 0) {
    rect(trackerBarX + 10, trackerBarY + 8, (trackerBarWidth-20) * (myMovie.time()/myMovie.duration()), trackerLineThickness);
  }
  
  if (trackerMousePos!=-1) {
    fill(color2, 255);
    mousePos = 10 + (trackerMousePos * (trackerBarWidth-20));
    ellipse(mousePos,  trackerBarY + 8 + (trackerLineThickness/2), trackerLineThickness, trackerLineThickness);
    
    fill(color1);
    stroke(color4);  
    strokeWeight(1.2);
    rect(mousePos - (64/2), trackerBarY - 18 , 64, 18, 2);
      
    fill(color4);
    noStroke();
    textFont(smallRobotoMono);
    textAlign(CENTER);
    text(formatTimeCode(trackerMousePos * myMovie.duration()),mousePos,trackerBarY-5);

  }
}

void switchToEdit() {
  UIMode="EDIT";
  purgeButts();
  
  agendaButtL = new Butt("1",5,5,40,48);
  agendaButtL.verb = "AGENDA";
  agendaButtL.noun = "L";
  agendaButtL.style = "AGENDA";
  butts.add(agendaButtL); 
  
  agendaButtR = new Butt("9",videoWidth-(40+5),5,40,48);
  agendaButtR.verb = "AGENDA";
  agendaButtR.noun = "R";
  agendaButtR.style = "AGENDA";
  butts.add(agendaButtR);
  
  creditButtR = new Butt("55",5,10+48,40,32);
  creditButtR.verb = "CREDIT";
  creditButtR.noun = "L";
  creditButtR.style = "CREDIT";
  butts.add(creditButtR);

  creditButtL = new Butt("49",videoWidth-(40+5),10+48,40,32);
  creditButtL.verb = "CREDIT";
  creditButtL.noun = "R";
  creditButtL.style = "CREDIT";
  butts.add(creditButtL);
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
  trackerMousePos = getTrackerMousePos();

}

float getTrackerMousePos() {
  float ret;
  if (mouseY > trackerBarY && mouseY < trackerBarY + 8 + trackerLineThickness + 8) {
    ret = (mouseX - (trackerBarX + 10)) / (trackerBarWidth -20);
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

void updateMousePressed() {
  trackerMousePos = getTrackerMousePos();
  if (trackerMousePos != -1) {
    setHeadPercent(trackerMousePos);
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