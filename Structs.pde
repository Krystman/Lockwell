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
  public float time;
  public int value;
  public String stingValue;
  public int side;
  public int type;
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
  public int side;
  public String name;
  public String path;
  public String masterclipid;
  public String fileid;
  public String clipitemid;
  
  Footage clone() {
    Footage tempF = new Footage();
    tempF.value = this.value;
    tempF.side = this.side;
    tempF.name = this.name;
    tempF.path = this.path;
    tempF.masterclipid = this.masterclipid;
    tempF.fileid = this.fileid;
    tempF.clipitemid = this.clipitemid;
    return tempF;
  }
}