// Functions for video control and rendering

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
    headPos = cur;
    if (moviePaused) {
      pauseOnRead = true;
      myMovie.play();
    }
  } else {
    headPos = 0f;
  }
}

void setHead(float _s) {
  float cur;
  if (moviePath != "") {
    cur = _s;
    cur = constrain(cur, 0, myMovie.duration());
    myMovie.jump(cur);
    headPos = cur;
    if (moviePaused) {
      pauseOnRead = true;
      myMovie.play();
    }
  } else {
    headPos = 0f;
  }
}