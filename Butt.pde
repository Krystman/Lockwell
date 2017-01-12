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
    color fillColor = color1;
    color borderColor = color2;
    int yOffset = 0;
    
    if (style == "LIST") {
      if (state == "OVER") {
        textColor = color1;
        fillColor = color3;
        borderColor = color3;
      } else if (state == "CLICK") {
        textColor = color1;
        fillColor = color4;
        borderColor = color4;
        yOffset = 1;
      } else {
        textColor = color4;
        fillColor = color1;
        borderColor = color1;
        yOffset = 1;        
      }
    } else {
      if (state == "OVER") {
        textColor = color1;
        fillColor = color2;
        borderColor = color2;
      } else if (state == "CLICK") {
        textColor = color1;
        fillColor = color5;
        borderColor = color5;
        yOffset = 1;
      } else {
        textColor = color2;
        fillColor = color1;
        borderColor = color2;
        yOffset = 1;        
      }
    }
    
    fill(fillColor);
    stroke(borderColor);  
    strokeWeight(1.2);
    rect(x, y+yOffset, w, h, r);
    
    fill(textColor);
    noStroke();
    textFont(smallRoboto);
    if(style == "LIST") {
      textAlign(LEFT);
      text(t,x+10,y+h/2+5+yOffset);
    } else {
      textAlign(CENTER);
      text(t,x+w/2,y+h/2+5+yOffset);
    }
  }
} 