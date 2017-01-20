// A bunch of Structs 
// Mainly to hold information for Video Data

// Both, CreditEvent and AgendaEvent are identical
// Right now, but we'll keep them seperate just in case
// We want to add more functionality in the future

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