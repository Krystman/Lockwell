
// This draws the video tracker bar
// Not sure if this this the right name
// I mean the progress bar below the video
// Where you can see how far into the video you are
void drawTrackerBar(int _x, int _y, int _width) {
  float _lineThickness = 5;
  noStroke();
  textSize(11);
  fill(color4);
  textFont(smallRobotoMono);
  textAlign(LEFT);
  text(formatTimeCode(myMovie.time()), _x + 10, _y + 28);
  textAlign(RIGHT);
  text("-" + formatTimeCode(myMovie.duration()-myMovie.time()), _width-10, _y + 28);
  fill(color4, 72);
  rect(_x + 10, _y + 8, _width-20, _lineThickness);
  fill(color4, 255);
  if (myMovie.duration() > 0) {
    rect(_x + 10, _y + 8, (_width-20) * (myMovie.time()/myMovie.duration()), _lineThickness);
  }  
}