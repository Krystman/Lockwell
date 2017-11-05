// A bunch of Structs
// Mainly to hold information for Video Data

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

  Keyframe clone() {
    Keyframe _tempKF = new Keyframe();
    _tempKF.time = time;
    _tempKF.duration = duration;
    _tempKF.value = value;
    _tempKF.stringValue = stringValue;
    _tempKF.side = side;
    _tempKF.type = type;
    _tempKF.x = x;
    _tempKF.y = y;

    return _tempKF;
  }
}

// This is to old video information so that multiple videos can be loaded
// The implementation of this is WIP at this point
public class VideoContainer {
  public String file;
  public String path;
  public float duration;
  public ArrayList <Keyframe> keyframes;
  public ArrayList <AnimPos> animPosMem;
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
  public char keyShortcut;
  public int length;
  public int side; // This restricts the animation to show up for a specific side only
  public int positioning;
}

// This is to remember the last position each animation was set to
// Speeds up editing as animations tend to re-appear on the same positions
public class AnimPos {
  public String name;
  public int side;
  public float x;
  public float y;
}
