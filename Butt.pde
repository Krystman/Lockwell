class Butt {
  public String t;
  public float x, y, w, h;
  public float r = 2;
  public String state = "";
  public String style = "";
  public String verb = "";
  public String noun = "";
  
  Butt(String _t, float _x, float _y, float _w, float _h) {
    t = _t;
    x = _x;
    y = _y;
    w = _w;
    h = _h;    
  }
  
  void update() {
    
  }
  
  void drawMe() {
    color textColor = color2;
    int yOffset = 0;
    
    textFont(smallRoboto);
    strokeWeight(1.2);
    
    if (style == "LIST") {
      if (state == "OVER") {
        textColor = color1;
        fill(color3);
        stroke(color3);
      } else if (state == "CLICK") {
        textColor = color1;
        fill(color4);
        stroke(color4);
        yOffset = 1;
      } else {
        textColor = color4;
        fill(color1);
        stroke(color1);     
      }
    } else if (style == "AGENDA") {
      textFont(agendaRoboto);
      if (state == "OVER") {
        textColor = #000000;
        fill(color5);
        noStroke();
      } else if (state == "CLICK") {
        textColor = #000000;
        fill(color2);
        noStroke();
        yOffset = 1;
      } else {
        textColor = color5;
        noFill();
        noStroke();     
      }
    } else if (style == "CREDIT") {
      textFont(credRoboto);
      if (state == "OVER") {
        textColor = #000000;
        fill(color5);
        noStroke();
      } else if (state == "CLICK") {
        textColor = #000000;
        fill(color2);
        noStroke();
        yOffset = 1;
      } else {
        textColor = color5;
        noFill();
        noStroke();     
      }
    } else {
      if (state == "OVER") {
        textColor = color1;
        fill(color2);
        stroke(color2);
      } else if (state == "CLICK") {
        textColor = color1;
        fill(color5);
        stroke(color5);
        yOffset = 1;
      } else {
        textColor = color2;
        fill(color1);
        stroke(color2);     
      }
    }
    
    rect(x, y+yOffset, w, h, r);
    
    fill(textColor);
    noStroke();
    
    if(style == "LIST") {
      textAlign(LEFT);
      text(t,x+10,y+h/2+5+yOffset);
    } else if (style == "AGENDA") {
      textAlign(CENTER);
      text(t,x+w/2,y+h/2+21+yOffset);
    } else if (style == "CREDIT") {
      textAlign(CENTER);
      text(t,x+w/2,y+h/2+12+yOffset);
    } else {
      textAlign(CENTER);
      text(t,x+w/2,y+h/2+5+yOffset);
    }
  }
} 