// A button class for UI elements

class Butt {
  public String t;
  public float x, y, w, h;
  public float r = 2;
  public String state = "";
  public int sustain = 0; // sustains last state for this ammount of frames
  public String style = "";
  public String verb = "";
  public String noun = "";
  
  public boolean visible = true;
  public boolean caret = false;
  public boolean dirty = false;
  
  public KeyMap keyMap;
  
  private color overFill;
  private color overStroke;
  private color overText;
  
  private color outFill;
  private color outStroke;
  private color outText;

  private color clickFill;
  private color clickStroke;
  private color clickText;
  
  private PFont thisFont;
  
  Butt(String _t, float _x, float _y, float _w, float _h) {
    t = _t;
    x = _x;
    y = _y;
    w = _w;
    h = _h; 
    setStyle("");
    keyMap = new KeyMap();
  }
  
  void setStyle(String _style) {
    if (_style == "LIST") {
      style = "LIST";
      thisFont = smallRoboto;
      
      overFill = color3;
      overStroke = color3;
      overText = color1;
  
      outFill = color1;
      outStroke = color1;
      outText = color4;

      clickFill = color4;
      clickStroke = color4;
      clickText = color1;
    } else if (_style == "AGENDA") {
      style = "AGENDA";
      thisFont = agendaRoboto;
      
      overFill = color5;
      overStroke = -1;
      overText = #000000;
  
      outFill = -1;
      outStroke = -1;
      outText = color5;

      clickFill = color2;
      clickStroke = -1;
      clickText = #000000;
    } else if (_style == "CREDIT") {
      style = "CREDIT";
      thisFont = credRoboto;
      
      overFill = color5;
      overStroke = -1;
      overText = #000000;
  
      outFill = -1;
      outStroke = -1;
      outText = color5;

      clickFill = color2;
      clickStroke = -1;
      clickText = #000000;
    } else if (_style == "ANIML" || _style == "ANIMR") {
      style = _style;
      thisFont = animRoboto;
      
      overFill = color5;
      overStroke = -1;
      overText = #000000;
  
      outFill = -1;
      outStroke = -1;
      outText = color5;

      clickFill = color2;
      clickStroke = -1;
      clickText = #000000;
    } else if (_style == "COMMENT") {
      style = "COMMENT";
      thisFont = commentRoboto;
      
      overFill = color5;
      overStroke = -1;
      overText = #000000;
  
      outFill = color(0,0,0,128);
      outStroke = -1;
      outText = color5;

      clickFill = color2;
      clickStroke = -1;
      clickText = #000000;
    } else if (_style == "KEYFRAME") {
      style = "KEYFRAME";

      overFill = color5;
      overStroke = -1;
      overText = #000000;
  
      outFill = -1;
      outStroke = -1;
      outText = color5;

      clickFill = color2;
      clickStroke = -1;
      clickText = #000000;
    } else {
      style = "";
      thisFont = smallRoboto;
      
      overFill = color2;
      overStroke = color2;
      overText = color1;
  
      outFill = color1;
      outStroke = color1b;
      outText = color1b;

      clickFill = color5;
      clickStroke = color5;
      clickText = color1;
    }
  }
  
  void update() {
    
  }
  
  void drawMe() {
    color textColor = color2;
    int yOffset = 0;
    
    textFont(thisFont);
    strokeWeight(1.2);

    if (state == "OVER") {
      textColor = overText;
      if (overFill == -1) { noFill(); } else {
        fill(overFill);
      }
      if (overStroke == -1) { noStroke(); } else {
        stroke(overStroke);
      }
    } else if (state == "CLICK") {
      textColor = clickText;
      if (clickFill == -1) { noFill(); } else {
        fill(clickFill);
      }
      if (clickStroke == -1) { noStroke(); } else {
        stroke(clickStroke);
      }
      yOffset = 1;
    } else {
      textColor = outText;
      if (outFill == -1) { noFill(); } else {
        fill(outFill);
      }
      if (outStroke == -1) { noStroke(); } else {
        stroke(outStroke);
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
    } else if (style == "KEYFRAME") {
      //ellipse(x+w/2, y+h/2, w-4, h-4);
      float _cx = x+w/2;
      float _cy = y+h/2;
      float _cr = 5;
      quad(_cx, _cy-_cr, 
           _cx-_cr, _cy, 
           _cx, _cy+_cr, 
           _cx+_cr, _cy);
    } else if (style == "COMMENT") {
      textAlign(CENTER);
      /*if (state != "OVER" && state != "CLICK") {
        fill(0);
        for(float i=-1; i<=3;i+=0.5) {
          text(t,x+i,y+2+i, w,h);
        }
        fill(textColor);
      }*/
      text(t,x,y+2, w,h);
      if (caret) {
        rect(x + (w/2) + (textWidth(t)/2)+3,y+4,2,h-8);
      }
    } else if (style == "ANIML") {
      textAlign(LEFT);
      text(t,x+6,y+3,w-12,h-3);
    } else if (style == "ANIMR") {
      textAlign(RIGHT);
      text(t,x+6,y+3,w-12,h-3);
    } else {
      textAlign(CENTER);
      text(t,x+w/2,y+h/2+5+yOffset);
    }
  }
} 