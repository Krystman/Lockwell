void drawInput() {
  fill(0,0,0,162);
  rect(0,0,width,height);
  if (inputTarget == "COMMENT") {
    commentButt.visible = true;
    commentButt.t = inputText;
    commentButt.caret = blink;
    commentButt.w = int(stringButtSize(commentButt.t)+20);
    if (commentButt.w < 100) {
      commentButt.w = 100;
    }
    
    commentButt.x = int((videoWidth / 2) - (commentButt.w / 2));
    delCommentButt.x = commentButt.x - 17;
    commentButt.drawMe();
    commentButt.visible = false;
  }
}

void drawAnimInput() {
  fill(0,0,0,162);
  rect(0,0,width,height);
  for (int i = 0; i < buttMenu.size(); i++) {
    if (buttMenu.get(i).visible) {
      buttMenu.get(i).drawMe();
    }
  }
}

void drawAnimPosInput() {
  if (inputTarget == "NEW") {
    for (int i = 0; i < buttMenu.size(); i++) {
      if (buttMenu.get(i).visible) {
        buttMenu.get(i).drawMe();
      }
    }
  }
  fill(0,0,0,128);
  rect(0,0,width,height);
  
  if (inputTarget == "NEW") {
    stroke(color5);
  } else {
    stroke(color3);
  }
  strokeWeight(2);
  
  if (inputPositioning == 0 || inputPositioning == 1) {
    dashedLine((inputLastX + 0.5) * videoWidth, videoY, (inputLastX + 0.5) * videoWidth, videoHeight + videoY, 3);
  } else {
    inputLastX = 0.0;
  }
  if (inputPositioning == 0 || inputPositioning == 2) {
    dashedLine(0, videoY + ((inputLastY + 0.5) * videoHeight), videoWidth, videoY + ((inputLastY + 0.5) * videoHeight), 3);
  } else {
    inputLastY = 0.0;
  }
  
  stroke(color2);
  if (inputPositioning == 0 || inputPositioning == 1) {
    inputX = mouseX / videoWidth;
    inputX = constrain(inputX, 0.0, 1.0) - 0.5;
    line((inputX + 0.5) * videoWidth, videoY, (inputX + 0.5) * videoWidth, videoHeight + videoY);
  } else {
    inputX = 0.0;
  } 
  if (inputPositioning == 0 || inputPositioning == 2) {
    inputY = (mouseY - videoY) / videoHeight;
    inputY = constrain(inputY, 0.0, 1.0) - 0.5;
    line(0, videoY + ((inputY + 0.5) * videoHeight), videoWidth, videoY + ((inputY + 0.5) * videoHeight));
  } else {
    inputY = 0.0;
  }
}

// This draws the video tracker bar
// Not sure if this this the right name
// I mean the progress bar below the video
// Where you can see how far into the video you are

void drawTrackerBar() {
  float mousePos;
  
  // this is the y position of the actual progress bar line
  float _lineY = trackerBarY + 18;
  
  // draw background
  noStroke();
  fill(color1c);
  rect(trackerBarX, trackerBarY, trackerBarWidth, trackerBarHeight);
  
  // Draw timecode / time remaining
  noStroke();
  textSize(11);
  fill(color1b);
  textFont(smallRobotoMono);
  textAlign(LEFT);
  text(formatTimeCode(headPos), trackerBarX + 10, _lineY + 20);
  textAlign(RIGHT);
  text("-" + formatTimeCode(myMovie.duration()-headPos), trackerBarWidth-10, _lineY + 20);
  
  // Draw bar
  fill(color1d);
  rect(trackerBarX + 10, _lineY, trackerBarWidth-20, trackerLineThickness);
  
  // Draw progress
  fill(color1b);
  if (myMovie.duration() > 0) {
    rect(trackerBarX + 10, _lineY, (trackerBarWidth-20) * (headPos/myMovie.duration()), trackerLineThickness);
  }
  
  // Draw keyframe ticks
  fill(color3);
  noStroke();
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      float _tickPos = keyframes.get(i).time;
      rect(int(trackerBarX + 10 + ((trackerBarWidth-20) * (_tickPos/myMovie.duration()))), _lineY - 10, 1, 5);
    }
  }
  
  // Draw mouse over info
  if (trackerMousePos!=-1) {
    fill(color2, 255);
    mousePos = 10 + (trackerMousePos * (trackerBarWidth-20));
    
    triangle(mousePos, _lineY+trackerLineThickness+1, mousePos-4, _lineY+trackerLineThickness+5, mousePos+4, _lineY+trackerLineThickness+5);
    rect(mousePos, _lineY, 1, trackerLineThickness);
    //ellipse(mousePos,  _lineY + (trackerLineThickness/2), trackerLineThickness, trackerLineThickness);
    
    fill(color1);
    stroke(color1b);  
    strokeWeight(1.2);
    rect(mousePos - (64/2), trackerBarY - 8 , 64, 18, 2);
      
    fill(color1b);
    noStroke();
    textFont(smallRobotoMono);
    textAlign(CENTER);
    text(formatTimeCode(trackerMousePos * myMovie.duration()),mousePos,trackerBarY+5);
  }
}

// This draws the Detail bar
// Detail bar is a zoomed-in timeline above the tracker bar 
void drawDetailBar() {
  int _thisx; 
  
  float _ticksY = detailBarY + 20; // this is the y position of ticks of the timeline
  float _keysY = _ticksY - 14; // this is the y position of the top corner of the keyframe diamonds
  float _realdWidth = detailBarWidth - 20; // adding padding to the edges;
  float mouseline = -20; // A mouse line is a selection line showing up one mouse over.
  float mouseTime = -1; // The timecode underneath the mouse
  float mouseKeyTime = -1; // The timecode of the keyframe currently being hovered on my the mouse
  
  // Deal with mouse selection. 
  if (detailMousePos!=-1) {
    mouseline = detailMousePos * detailBarWidth;
    mouseTime = detailBarScroll + (((mouseline-10) / _realdWidth) * detailBarZoom);
    mouseTime = constrain(mouseTime, 0, myMovie.duration());
    
    // Snap to keyframes
    float bestDist = myMovie.duration()*2;
    float bestTime = -1;
    if (keyframes != null) {
      for (int i = 0; i < keyframes.size(); i++) {
        float dist = abs(keyframes.get(i).time - mouseTime);
        if (dist < bestDist) {
          bestDist = dist;
          bestTime = keyframes.get(i).time;
        }
      }
    }
    if (bestDist < 0.25) {
      mouseKeyTime = bestTime;
    }
    
  } else {
    // Show a mouse line if the mouse is over the tracker bar too!
    if (trackerMousePos!=-1) {
      mouseTime = trackerMousePos * myMovie.duration();
      if (mouseTime > detailBarScroll-1 && mouseTime < detailBarScroll + detailBarZoom) {
        mouseline = 10 + int(((mouseTime-detailBarScroll) / detailBarZoom) * _realdWidth);
      }
    }
  }
  
  // draw background
  noStroke();
  fill(color1);
  rect(detailBarX, detailBarY, detailBarWidth, detailBarHeight);
  
  // draw second ticks
  noStroke();
  fill(color1d);
  for (float i = int(detailBarScroll-1); i < detailBarScroll + detailBarZoom + 1; i=i+0.5) {
    if (i >= 0 && i <= myMovie.duration()) {
      int _tickH = 6;
      if (i != int(i)) {
        _tickH = 1;
      }
      _thisx = 10 + int(((i-detailBarScroll) / detailBarZoom) * _realdWidth);
      rect(_thisx, _ticksY, 1, _tickH);
    }
  }
  
  // draw mouseline
  fill(color2);
  noStroke();  
  if (mouseKeyTime == -1) {
    rect(mouseline, detailBarY, 1, detailBarHeight);
  } else {
    _thisx = 10 + int(((mouseKeyTime-detailBarScroll) / detailBarZoom) * _realdWidth);
    rect(_thisx, detailBarY, 1, detailBarHeight);
  }
  
  // draw keyframe diamonds
  fill(color3);
  noStroke();
  if (keyframes != null) {
    for (int i = 0; i < keyframes.size(); i++) {
      float _keyPos = keyframes.get(i).time;
      if (_keyPos == mouseKeyTime) {
        fill(color2);
      } else if (_keyPos == headPos) {
        fill(color4);
      } else if (selFrameComment != null && selFrameComment == keyframes.get(i)) {
        fill(color4);
      } else {
        fill(color3);
      }
      if (_keyPos > detailBarScroll-1 && _keyPos < detailBarScroll + detailBarZoom) {
        _thisx = 10 + int(((_keyPos-detailBarScroll) / detailBarZoom) * _realdWidth);
        quad(_thisx, _keysY, _thisx-4, _keysY+4, _thisx, _keysY+8, _thisx+4, _keysY+4);
        
        //rect(int(trackerBarX + 10 + ((trackerBarWidth-20) * (_tickPos/myMovie.duration()))), _lineY - 10, 1, 5);
      }
    }
  }
  
  // draw cursor
  noStroke();
  fill(color2);
  if (headPos > detailBarScroll-1 && headPos < detailBarScroll + detailBarZoom) {
    _thisx = 10 + int(((headPos-detailBarScroll) / detailBarZoom) * _realdWidth);
    triangle(_thisx, _ticksY, _thisx-4, _ticksY+4, _thisx+4, _ticksY+4);
    rect(_thisx-4, _ticksY+4, 7.8, 5);
  }

  // draw tooltip   
  if (detailMousePos!=-1) {
    float _showTime = mouseTime;
    float _showX = mouseline; 
    if (mouseKeyTime != -1) {
      _showTime = mouseKeyTime;
      _showX = 10 + int(((mouseKeyTime-detailBarScroll) / detailBarZoom) * _realdWidth);
    } else {
      
    }
    fill(color1);
    stroke(color1b);  
    strokeWeight(1.2);
    rect(_showX - (64/2), detailBarY - 15 , 64, 18, 2);
      
    fill(color1b);
    noStroke();
    textFont(smallRobotoMono);
    textAlign(CENTER);
    text(formatTimeCode(_showTime),_showX,detailBarY-3);
  }
}