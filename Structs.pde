// A bunch of Structs 
// Mainly to hold information for Video Data

// Both, CreditEvent and AgendaEvent are identical
// Right now, but we'll keep them seperate just in case
// We want to add more functionality in the future
// (PHASING THIS OUT NOW)

public class CreditEvent {
  public float time;
  public int value;
  public int side;
}

public class AgendaEvent {
  public float time;
  public int value;
  public int side;
}

// We are going to use a universal keyframe struct
// To store information about the change of various
// stats (credits, agendas, etc...)

public class Keyframe {
  public float time; // Keyframe timecode in seconds
  public float duration; // Keyframe duration in seconds. Used for animations.
  public int value;
  public String stringValue;
  public int side;
  public int type;
  // Position of the clip on the screen.
  // Units are multiples of screen width / height
  // 0.0 means centered
  // -1.0 means offscreen left or up
  // 1.0 means offscreen right or down
  // -0.5 means the center of the clip is at the left or upper edge
  public float x = 0.0;
  public float y = 0.0;  
}

// This is to old video information so that multiple videos can be loaded
// The implementation of this is WIP at this point
public class VideoContainer {
  public String file;
  public String path;
  public float duration;
  public ArrayList <Keyframe> keyframes;
}

// This one is to hold library data when exporting to Final Cut XML

public class Footage {
  public int value;
  public String stringValue;
  public int side;
  public int duration;
  public String name;
  public String path;
  public String masterclipid;
  public String fileid;
  public String clipitemid;
  
  Footage clone() {
    Footage tempF = new Footage();
    tempF.value = this.value;
    tempF.stringValue = this.stringValue;
    tempF.side = this.side;
    tempF.duration = this.duration;
    tempF.name = this.name;
    tempF.path = this.path;
    tempF.masterclipid = this.masterclipid;
    tempF.fileid = this.fileid;
    tempF.clipitemid = this.clipitemid;
    return tempF;
  }
}

// This helps keeping track of which button to jump to when a key is pressed
public class KeyMap {
  public Butt up;
  public Butt down;
  public Butt left;
  public Butt right;
}

// This holds various data about animations. Mainly for export. But also for UI stuff.
public class AnimConfig {
  public String name;
  public String path;
  public String file;
  public int length;
  public int side;
  public int positioning;
  float lastXL = 0.0;
  float lastYL = 0.0;
  float lastXR = 0.0;
  float lastYR = 0.0;  
}