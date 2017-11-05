void switchToEdit() {
  UIMode = "EDIT";
  inputMode = "EDITING";
  File _thisFile = new File(moviePath);
  surface.setTitle("Lockwell - " + _thisFile.getName());

  videoY = menuHeight;

  detailBarX = 0;
  detailBarY = videoHeight + videoY;
  detailBarWidth = width;

  trackerBarX = 0;
  trackerBarY = videoHeight + videoY + detailBarHeight;
  trackerBarWidth = width;

  purgeButts();

  agendaButtL = new Butt("1",5,5 + videoY,40,48);
  agendaButtL.verb = "AGENDA";
  agendaButtL.noun = "L";
  agendaButtL.side = LEFTPLAYER;
  agendaButtL.setStyle("AGENDA");
  agendaButtL.side = LEFTPLAYER;
  butts.add(agendaButtL);

  agendaButtR = new Butt("9",videoWidth-(40+5),5 + videoY,40,48);
  agendaButtR.verb = "AGENDA";
  agendaButtR.noun = "R";
  agendaButtR.side = RIGHTPLAYER;
  agendaButtR.setStyle("AGENDA");
  butts.add(agendaButtR);

  creditButtL = new Butt("55",5,agendaButtL.y + agendaButtL.h + 5,40,32);
  creditButtL.verb = "CREDIT";
  creditButtL.noun = "L";
  creditButtL.side = LEFTPLAYER;
  creditButtL.setStyle("CREDIT");
  butts.add(creditButtL);

  creditButtR = new Butt("49",videoWidth-(40+5),agendaButtR.y + agendaButtR.h + 5,40,32);
  creditButtR.verb = "CREDIT";
  creditButtR.noun = "R";
  creditButtR.side = RIGHTPLAYER;
  creditButtR.setStyle("CREDIT");
  butts.add(creditButtR);

  commentButt = new Butt("(note)",(videoWidth / 2) - 300, videoY + videoHeight - 37,600,32);
  commentButt.verb = "COMMENT";
  commentButt.setStyle("COMMENT");
  commentButt.w = int(stringButtSize(commentButt.t)+20);
  commentButt.x = int((videoWidth / 2) - (commentButt.w / 2));
  commentButt.side = BOTHPLAYERS;
  butts.add(commentButt);

  addAniButtL = new Butt("ADD ANIMATION", 5, creditButtL.y + creditButtL.h + 15, 190, 24);
  addAniButtL.verb = "ADDANIM";
  addAniButtL.noun = "L";
  addAniButtL.side = LEFTPLAYER;
  addAniButtL.setStyle("ANIML");
  butts.add(addAniButtL);

  addAniButtR = new Butt("ADD ANIMATION", videoWidth-(190+5), creditButtR.y + creditButtR.h + 15, 190, 24);
  addAniButtR.verb = "ADDANIM";
  addAniButtR.noun = "R";
  addAniButtR.side = RIGHTPLAYER;
  addAniButtR.setStyle("ANIMR");
  butts.add(addAniButtR);

  // Buttons to delete Keyframes
  delAgendaButtL = new Butt("",agendaButtL.x + agendaButtL.w + 3,agendaButtL.y,14,14);
  delAgendaButtL.verb = "DELETE";
  delAgendaButtL.noun = "LA";
  delAgendaButtL.side = LEFTPLAYER;
  delAgendaButtL.setStyle("KEYFRAME");
  butts.add(delAgendaButtL);

  delAgendaButtR = new Butt("",agendaButtR.x - 17,agendaButtR.y,14,14);
  delAgendaButtR.verb = "DELETE";
  delAgendaButtR.noun = "RA";
  delAgendaButtR.side = RIGHTPLAYER;
  delAgendaButtR.setStyle("KEYFRAME");
  butts.add(delAgendaButtR);

  delCreditButtL = new Butt("",creditButtL.x + creditButtL.w + 3,creditButtL.y,14,14);
  delCreditButtL.verb = "DELETE";
  delCreditButtL.noun = "LC";
  delCreditButtL.side = LEFTPLAYER;
  delCreditButtL.setStyle("KEYFRAME");
  butts.add(delCreditButtL);

  delCreditButtR = new Butt("",creditButtR.x - 17,creditButtR.y,14,14);
  delCreditButtR.verb = "DELETE";
  delCreditButtR.noun = "RC";
  delCreditButtR.side = BOTHPLAYERS;
  delCreditButtR.setStyle("KEYFRAME");
  butts.add(delCreditButtR);

  delCommentButt = new Butt("",commentButt.x - 17,commentButt.y,14,14);
  delCommentButt.verb = "DELETE";
  delCommentButt.noun = "COMMENT";
  delCommentButt.side = BOTHPLAYERS;
  delCommentButt.setStyle("KEYFRAME");
  butts.add(delCommentButt);

  menuSave = new Butt("SAVE",24, menuY + 5 ,94,24);
  menuSave.verb = "SAVE";
  menuSave.noun = "";
  butts.add(menuSave);

  menuSaveClose = new Butt("SAVE & CLOSE", menuSave.x + menuSave.w + 5, menuSave.y,94,24);
  menuSaveClose.verb = "SAVECLOSE";
  menuSaveClose.noun = "";
  butts.add(menuSaveClose);

  menuExport = new Butt("EXPORT", menuSaveClose.x + menuSaveClose.w + 5, menuSave.y,94,24);
  menuExport.verb = "EXPORT";
  menuExport.noun = "";
  butts.add(menuExport);

  animButtsR = new ArrayList<Butt>();
  animButtsL = new ArrayList<Butt>();

  selAnimsLeft = new ArrayList<Keyframe>();
  selAnimsRight = new ArrayList<Keyframe>();

  nullMap = new KeyMap();

  createAnimMenus();
  createKeymap();
}

void switchToLoad() {
  int j;

  Butt tButt;
  Butt tButt2;

  UIMode = "LOAD";
  inputMode = "MENU";
  surface.setTitle("Lockwell");

  purgeButts();

  tButt = new Butt("LOAD VIDEO",24,24,94,24);
  tButt.verb = "LOAD";
  tButt.noun = "";
  butts.add(tButt);

  tButt = new Butt("EXPORT MULTIPLE",123,24,130,24);
  tButt.verb = "EXPORTMULT";
  tButt.noun = "";
  butts.add(tButt);

  tButt = new Butt("EXPORT",24,24,94,24);
  tButt.verb = "EXPORTCONFIRM";
  tButt.noun = "";
  tButt.visible = false;
  butts.add(tButt);

  tButt = new Butt("CANCEL",123,24,94,24);
  tButt.verb = "EXPORTCANCEL";
  tButt.noun = "";
  tButt.visible = false;
  butts.add(tButt);

  j = 0;
  for (int i = history.length-1; i >= 0; i--) {
    tButt = new Butt(history[i],24+5+24,64+25*j,512,24);
    tButt.setStyle("LIST");
    tButt.verb = "LOAD";
    tButt.noun = history[i];
    butts.add(tButt);

    tButt2 = new Butt("0",24,64+25*j,24,24);
    tButt2.setStyle("CHECKLIST");
    tButt2.verb = "CHECKLIST";
    tButt2.noun = history[i];
    tButt2.visible = false;
    butts.add(tButt2);
    j++;
  }
}

void switchToExport() {
  UIMode = "EXPORT";
  for (int i = 0; i < butts.size(); i++) {
    Butt tButt = butts.get(i);
    if (tButt.verb == "CHECKLIST") {
      tButt.visible = true;
    } else if (tButt.verb == "EXPORTMULT" || (tButt.verb == "LOAD" && tButt.noun == "")) {
      tButt.visible = false;
    } else if (tButt.verb == "EXPORTCONFIRM" || tButt.verb == "EXPORTCANCEL") {
      tButt.visible = true;
      tButt.sustain = 15;
    }
  }
}
