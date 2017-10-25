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
      myMovie.play();
      myMovie.pause();
      myMovie.read();
      myMovie.jump(cur);
    }
  } else {
    headPos = 0f;
  }
}

void setHead(float _s) {
  println("setHead " + _s);
  float cur;
  if (moviePath != "") {
    cur = _s;
    cur = constrain(cur, 0, myMovie.duration());
    myMovie.jump(cur);
    headPos = cur;
    if (moviePaused) {
      headLocked = true;
      myMovie.play();
      myMovie.pause();
      myMovie.read();
      myMovie.jump(cur);
    }
  } else {
    headPos = 0f;
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
      //myMovie.volume(0.1f); // TODO Debug
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