

void drawDiffScreen() {
  stroke(BORDER_C,25);
  strokeWeight(1);
  for (int i=0;i<WIN_W;i+=38) line(i,0,i,WIN_H);
  for (int j=0;j<WIN_H;j+=38) line(0,j,WIN_W,j);

  for (int i=0;i<18;i++) {
    float bx=noise(i*7.3,frameCount*0.005)*WIN_W;
    float by=noise(i*3.7+100,frameCount*0.005)*WIN_H;
    color pc=DIFF_COLS[i%3];
    fill(red(pc),green(pc),blue(pc),40+20*sin(pulse+i));
    noStroke();
    ellipse(bx,by,6,6);
  }

 int mw = 530;
int mh = 430;
int mx = (width - mw) / 2;
int my = (height - mh) / 2;
  fill(color(18,25,36));
  stroke(color(55,80,110));
  strokeWeight(2);
  rect(mx,my,mw,mh,12);

  for (int i=0;i<4;i++) {
    stroke(red(CYAN_C),green(CYAN_C),blue(CYAN_C),(80-i*20));
    strokeWeight(4-i);
    line(mx+24,my,mx+mw-24,my);
  }

  textFont(titleFont);
  textSize(26);
  textAlign(CENTER,TOP);
  fill(CYAN_C);
  noStroke();
  text("WAREHOUSE NAVIGATOR",mx+mw/2,my+20);

  textFont(nameFont);
  textSize(12);
  textAlign(CENTER,TOP);
  fill(TXT_MED);
  text("3 Shifts · Outscore the rival before time and spoilage beat you!",mx+mw/2,my+58);

  int cardW=148,cardH=185,gap=10,totalW=3*cardW+2*gap,startX=mx+(mw-totalW)/2,cardY=my+92;
  for (int d=0;d<3;d++) {
    int cx=startX+d*(cardW+gap);
    boolean hov=(mouseX>=cx&&mouseX<=cx+cardW&&mouseY>=cardY&&mouseY<=cardY+cardH);
    color dc=DIFF_COLS[d];

    if (hov) {
      for (int g=0;g<5;g++) {
        fill(0,0,0,0);
        stroke(red(dc),green(dc),blue(dc),(50-g*10));
        strokeWeight(6-g);
        rect(cx-g,cardY-g,cardW+g*2,cardH+g*2,12+g);
      }
    }

    fill(hov?color(red(dc)*0.18,green(dc)*0.18,blue(dc)*0.18):color(22,32,44));
    stroke(dc);
    strokeWeight(hov?2:1.2);
    rect(cx,cardY,cardW,cardH,10);

    drawDiffIcon(d,cx+cardW/2,cardY+50,dc,hov);

    textFont(titleFont);
    textSize(15);
    textAlign(CENTER,TOP);
    fill(dc);
    noStroke();
    text(DIFF_NAMES[d],cx+cardW/2,cardY+92);

    textFont(mono);
    textSize(9);
    textAlign(CENTER,TOP);
    fill(TXT_MED);
    String[] parts=DIFF_DESCS[d].split(" · ");
    for (int p2=0;p2<parts.length;p2++) text(parts[p2],cx+cardW/2,cardY+114+p2*14);

    if (hov) {
      textFont(mono);
      textSize(9);
      textAlign(CENTER,BOTTOM);
      fill(dc,200+30*sin(pulse*3));
      text("CLICK TO SELECT",cx+cardW/2,cardY+cardH-8);
    }
  }

  for (int z=0;z<4;z++) {
    float lx=mx+28+z*120,ly=my+mh-36;
    fill(ZONE_DOT[z]);
    noStroke();
    rect(lx,ly+2,10,10,2);
    textFont(mono);
    fill(TXT_MED);
    textSize(10);
    textAlign(LEFT,TOP);
    text(ZONE_NAME[z],lx+14,ly+1);
  }

  // Back button (bottom-left of panel)
  int backW=110,backH=30,backX=mx+16,backY=my+mh-42;
  boolean backHov=(mouseX>=backX&&mouseX<=backX+backW&&mouseY>=backY&&mouseY<=backY+backH);
  fill(backHov ? TXT_MED : color(22,30,42));
  stroke(TXT_MED);
  strokeWeight(1.3);
  rect(backX,backY,backW,backH,6);
  fill(backHov ? BG : TXT_MED);
  noStroke();
  textFont(titleFont);
  textSize(12);
  textAlign(CENTER,CENTER);
  text("← BACK",backX+backW/2,backY+backH/2);
}

void drawDiffIcon(int d, float cx, float cy, color dc, boolean hov) {
  float sc=hov?1.1:1.0;
  fill(red(dc)*0.3,green(dc)*0.3,blue(dc)*0.3);
  stroke(dc);
  strokeWeight(2);
  ellipse(cx,cy,36*sc,36*sc);

  fill(dc);
  noStroke();
  ellipse(cx-8*sc,cy-5*sc,5*sc,5*sc);
  ellipse(cx+8*sc,cy-5*sc,5*sc,5*sc);

  if (d==0) {
    noFill();
    stroke(dc);
    strokeWeight(2);
    arc(cx,cy+2*sc,18*sc,12*sc,0.2,PI-0.2);
  } else if (d==1) {
    stroke(dc);
    strokeWeight(2);
    line(cx-8*sc,cy+6*sc,cx+8*sc,cy+6*sc);
  } else {
    stroke(dc);
    strokeWeight(2);
    line(cx-12*sc,cy-10*sc,cx-4*sc,cy-6*sc);
    line(cx+4*sc,cy-6*sc,cx+12*sc,cy-10*sc);
    noFill();
    arc(cx,cy+10*sc,18*sc,12*sc,PI+0.2,TWO_PI-0.2);
  }
}

void drawNameScreen() {
  stroke(BORDER_C,25);
  strokeWeight(1);
  for (int i=0;i<WIN_W;i+=38) line(i,0,i,WIN_H);
  for (int j=0;j<WIN_H;j+=38) line(0,j,WIN_W,j);

  // Floating ambient dots
  for (int i=0;i<14;i++) {
    float bx=noise(i*7.3,frameCount*0.005)*WIN_W;
    float by=noise(i*3.7+100,frameCount*0.005)*WIN_H;
    color pc=ZONE_DOT[i%4];
    fill(red(pc),green(pc),blue(pc),35+20*sin(pulse+i));
    noStroke();
    ellipse(bx,by,5,5);
  }

  int mw = 500;
int mh = 360;
int mx = (width - mw) / 2;
int my = (height - mh) / 2;

  // Glow border
  for (int g=0;g<4;g++) {
    fill(0,0,0,0);
    stroke(CYAN_C,50-g*12);
    strokeWeight(5-g);
    rect(mx-g,my-g,mw+g*2,mh+g*2,14+g);
  }

  fill(color(16,22,32));
  stroke(CYAN_C);
  strokeWeight(2);
  rect(mx,my,mw,mh,12);

  for (int i=0;i<4;i++) {
    stroke(red(CYAN_C),green(CYAN_C),blue(CYAN_C),(80-i*20));
    strokeWeight(4-i);
    line(mx+24,my,mx+mw-24,my);
  }

  textFont(titleFont);
  textSize(28);
  textAlign(CENTER,TOP);
  fill(CYAN_C);
  noStroke();
  text("WAREHOUSE NAVIGATOR",mx+mw/2,my+22);

  textFont(mono);
  textSize(11);
  textAlign(CENTER,TOP);
  fill(TXT_MED);
  text("3 Shifts · Deliver packages · Outscore the A.I. Rival!",mx+mw/2,my+62);

  float preY=my+100;
  noStroke();
  fill(0,40);
  ellipse(mx+mw/2-55,preY+26,22,7);
  drawBlueChar(mx+mw/2-55,preY+14,false,false);
  textFont(mono);
  fill(PLAYER_COL);
  textSize(9);
  textAlign(CENTER,TOP);
  text("YOU",mx+mw/2-55,preY+30);

  textFont(titleFont);
  textSize(14);
  textAlign(CENTER,CENTER);
  fill(YLW);
  text("VS",mx+mw/2,preY+16);

  noStroke();
  fill(0,40);
  ellipse(mx+mw/2+55,preY+26,22,7);
  drawRedChar(mx+mw/2+55,preY+14,false);
  textFont(mono);
  fill(AI_COL);
  textSize(9);
  textAlign(CENTER,TOP);
  text("A.I. RIVAL",mx+mw/2+55,preY+30);

  // Name input box
  int bx=mx+70,by=my+168,bw=mw-140,bh=52;
  fill(color(10,16,26));
  stroke(CYAN_C);
  strokeWeight(1.8);
  rect(bx,by,bw,bh,8);

  String display=nameInputBuf+(frameCount%40<20?"|":" ");
  textFont(titleFont);
  textSize(20);
  textAlign(CENTER,CENTER);
  fill(nameInputBuf.length()>0 ? TXT_BRT : TXT_DIM);
  noStroke();
  text(display,bx+bw/2,by+bh/2);

  textFont(mono);
  textSize(10);
  textAlign(CENTER,TOP);
  fill(TXT_DIM);
  text("Enter your name then press ENTER or click CONTINUE",mx+mw/2,my+232);

  int btnY=my+258, btnH=42, btnW=156, gap=24;
  int totalBtnW=btnW*2+gap;
  int backX=mx+(mw-totalBtnW)/2;
  int continueX=backX+btnW+gap;

  boolean hovBack=(mouseX>=backX&&mouseX<=backX+btnW&&mouseY>=btnY&&mouseY<=btnY+btnH);
  if (hovBack) {
    noFill();
    stroke(TXT_MED,90);
    strokeWeight(4);
    rect(backX-2,btnY-2,btnW+4,btnH+4,10);
  }
  fill(hovBack?color(34,46,62):color(20,28,38));
  stroke(TXT_MED);
  strokeWeight(1.8);
  rect(backX,btnY,btnW,btnH,9);
  fill(hovBack?TXT_BRT:TXT_MED);
  noStroke();
  textFont(titleFont);
  textSize(14);
  textAlign(CENTER,CENTER);
  text("← BACK",backX+btnW/2,btnY+btnH/2-1);

  boolean hov2=(mouseX>=continueX&&mouseX<=continueX+btnW&&mouseY>=btnY&&mouseY<=btnY+btnH);
  if (nameInputBuf.length()>0) {
    if (hov2) {
      noFill();
      stroke(CYAN_C,100);
      strokeWeight(4);
      rect(continueX-2,btnY-2,btnW+4,btnH+4,10);
    }
    fill(hov2?color(28,88,112):color(16,40,54));
    stroke(CYAN_C);
    strokeWeight(1.8);
    rect(continueX,btnY,btnW,btnH,9);
    fill(hov2?TXT_BRT:CYAN_C);
    noStroke();
    textFont(titleFont);
    textSize(14);
    textAlign(CENTER,CENTER);
    text("CONTINUE →",continueX+btnW/2,btnY+btnH/2-1);
  } else {
    fill(color(16,40,54));
    stroke(CYAN_C,90);
    strokeWeight(1.8);
    rect(continueX,btnY,btnW,btnH,9);
    fill(TXT_DIM);
    noStroke();
    textFont(mono);
    textSize(10);
    textAlign(CENTER,CENTER);
    text("TYPE NAME FIRST",continueX+btnW/2,btnY+btnH/2);
  }
}

void drawShiftSummaryModal() {
  fill(BG,185);
  noStroke();
  rect(MAP_X,MAP_Y,MAP_W,MAP_H);

  int mw=340,mh=290,mx=MAP_X+(MAP_W-mw)/2-18,my=MAP_Y+(MAP_H-mh)/2;
  int outcome = shiftOutcome[currentShift-1];
  color topCol = outcome>0 ? GRN : (outcome<0 ? RED_C : YLW);
  String title = outcome>0 ? "SHIFT "+currentShift+" WON!" : (outcome<0 ? "SHIFT "+currentShift+" LOST" : "SHIFT "+currentShift+" TIED");

  for (int g=0;g<4;g++) {
    fill(0,0,0,0);
    stroke(topCol,50-g*12);
    strokeWeight(4-g);
    rect(mx-g,my-g,mw+g*2,mh+g*2,12+g);
  }

  fill(color(14,22,30));
  stroke(topCol);
  strokeWeight(1.8);
  rect(mx,my,mw,mh,10);

  textFont(titleFont);
  textSize(18);
  textAlign(CENTER,TOP);
  fill(topCol);
  noStroke();
  text(title,mx+mw/2,my+14);

  textFont(mono);
  textSize(11);
  textAlign(CENTER,TOP);
  fill(TXT_MED);
  text(shiftEndReason,mx+mw/2,my+42);

  stroke(BORDER_C);
  strokeWeight(1);
  line(mx+12,my+68,mx+mw-12,my+68);

  textFont(nameFont);
  textSize(12);
  textAlign(LEFT,TOP);
  fill(PLAYER_COL);
  text(playerName+":",mx+24,my+84);
  fill(AI_COL);
  text("RIVAL:",mx+188,my+84);

  textFont(mono);
  textSize(11);
  textAlign(LEFT,TOP);
  fill(TXT_BRT);
  text("Score  "+score,mx+24,my+108);
  text("Del    "+deliveries+"/"+N_PKG,mx+24,my+126);
  text("Lives  "+lives,mx+24,my+144);

  text("Score  "+aiScore,mx+188,my+108);
  text("Del    "+aiDeliveries+"/"+N_PKG,mx+188,my+126);
  text("Speed  x"+nf(ASPEED/DIFF_AI_SPEED[difficulty],1,2),mx+188,my+144);

  stroke(BORDER_C);
  strokeWeight(1);
  line(mx+12,my+174,mx+mw-12,my+174);

  textFont(nameFont);
  textSize(12);
  textAlign(CENTER,TOP);
  String verdict = outcome>0 ? "You outscored the rival this shift."
    : (outcome<0 ? "The rival finished ahead this shift." : "Dead even. Nobody took this shift.");
  fill(topCol);
  text(verdict,mx+mw/2,my+186);

  for (int s=0;s<TOTAL_SHIFTS;s++) {
    color sc2 = (s+1<currentShift) ? (shiftOutcome[s]>0 ? GRN : (shiftOutcome[s]<0 ? RED_C : YLW))
      : (s+1==currentShift ? topCol : BORDER_C);
    fill(sc2);
    noStroke();
    ellipse(mx+mw/2-18+s*18,my+214,12,12);
    textFont(mono);
    textSize(8);
    textAlign(CENTER,CENTER);
    fill(BG);
    text(str(s+1),mx+mw/2-18+s*18,my+214);
  }

  if (outcome < 0) {
    int btnW=96, btnH=34, gap=10;
    int totalW = btnW*3 + gap*2;
    int btnY = my+mh-50;
    int btn1X = mx + (mw-totalW)/2;
    int btn2X = btn1X + btnW + gap;
    int btn3X = btn2X + btnW + gap;

    boolean hov1 = mouseX>=btn1X&&mouseX<=btn1X+btnW&&mouseY>=btnY&&mouseY<=btnY+btnH;
    boolean hov2 = mouseX>=btn2X&&mouseX<=btn2X+btnW&&mouseY>=btnY&&mouseY<=btnY+btnH;
    boolean hov3 = mouseX>=btn3X&&mouseX<=btn3X+btnW&&mouseY>=btnY&&mouseY<=btnY+btnH;

    fill(hov1 ? topCol : color(20,30,42));
    stroke(topCol);
    strokeWeight(1.5);
    rect(btn1X,btnY,btnW,btnH,6);

    fill(hov1 ? BG : topCol);
    noStroke();
    textFont(titleFont);
    textSize(10);
    textAlign(CENTER,CENTER);
    text("TRY AGAIN",btn1X+btnW/2,btnY+btnH/2);

    fill(hov2 ? TXT_MED : color(22,30,42));
    stroke(TXT_MED);
    strokeWeight(1.5);
    rect(btn2X,btnY,btnW,btnH,6);

    fill(hov2 ? BG : TXT_MED);
    noStroke();
    text("CHANGE DIFF",btn2X+btnW/2,btnY+btnH/2);

    fill(hov3 ? BLUE_B : color(18,28,42));
    stroke(BLUE_B);
    strokeWeight(1.5);
    rect(btn3X,btnY,btnW,btnH,6);

    fill(hov3 ? BG : BLUE_B);
    noStroke();
    text("MAIN MENU",btn3X+btnW/2,btnY+btnH/2);
  } else {
    int btnW=210,btnH=34,btnX=mx+(mw-btnW)/2,btnY=my+mh-88;
    boolean hov=mouseX>=btnX&&mouseX<=btnX+btnW&&mouseY>=btnY&&mouseY<=btnY+btnH;

    fill(hov?topCol:color(20,30,42));
    stroke(topCol);
    strokeWeight(1.5);
    rect(btnX,btnY,btnW,btnH,6);

    fill(hov?BG:topCol);
    noStroke();
    textFont(titleFont);
    textSize(13);
    textAlign(CENTER,CENTER);
    text(currentShift<TOTAL_SHIFTS ? "NEXT SHIFT" : "SEE FINAL RESULTS",btnX+btnW/2,btnY+btnH/2);

    // Secondary buttons: Restart | Change Difficulty | Main Menu
int sbW=96, sbH=34, gap2=10;
int totalSW = sbW*3 + gap2*2;
int sb1X = mx + (mw-totalSW)/2;
int sb2X = sb1X + sbW + gap2;
int sb3X = sb2X + sbW + gap2;
int sbY = my+mh-50;

    boolean hSb1=mouseX>=sb1X&&mouseX<=sb1X+sbW&&mouseY>=sbY&&mouseY<=sbY+sbH;
fill(hSb1?YLW:color(30,26,8));
stroke(YLW);
strokeWeight(1.2);
rect(sb1X,sbY,sbW,sbH,5);
fill(hSb1?BG:YLW);
noStroke();
textFont(titleFont);
textSize(10);
textAlign(CENTER,CENTER);
text("↺ RESTART",sb1X+sbW/2,sbY+sbH/2);

    boolean hSb2=mouseX>=sb2X&&mouseX<=sb2X+sbW&&mouseY>=sbY&&mouseY<=sbY+sbH;
fill(hSb2?TXT_MED:color(20,28,38));
stroke(TXT_MED);
strokeWeight(1.2);
rect(sb2X,sbY,sbW,sbH,5);
fill(hSb2?BG:TXT_MED);
noStroke();
textFont(titleFont);
textSize(9);
textAlign(CENTER,CENTER);
text("CHANGE DIFF",sb2X+sbW/2,sbY+sbH/2);

    boolean hSb3=mouseX>=sb3X&&mouseX<=sb3X+sbW&&mouseY>=sbY&&mouseY<=sbY+sbH;
fill(hSb3?BLUE_B:color(18,28,42));
stroke(BLUE_B);
strokeWeight(1.2);
rect(sb3X,sbY,sbW,sbH,5);
fill(hSb3?BG:BLUE_B);
noStroke();
textFont(titleFont);
textSize(10);
textAlign(CENTER,CENTER);
text("MAIN MENU",sb3X+sbW/2,sbY+sbH/2);
  }
}

void drawResultsScreen() {
  stroke(BORDER_C,20);
  strokeWeight(1);
  for (int i=0;i<WIN_W;i+=38) line(i,0,i,WIN_H);
  for (int j=0;j<WIN_H;j+=38) line(0,j,WIN_W,j);

  int playerWins=0, rivalWins=0, ties=0, totalPlayerScore=0, totalAiScore=0;
  for (int s=0;s<TOTAL_SHIFTS;s++) {
    totalPlayerScore += shiftPlayerScore[s];
    totalAiScore += shiftAiScore[s];
    if (shiftOutcome[s]>0) playerWins++;
    else if (shiftOutcome[s]<0) rivalWins++;
    else ties++;
  }

  int mw=570,mh=480,mx=(WIN_W-mw)/2,my=(WIN_H-mh)/2;
  color topCol = playerWins>rivalWins ? CYAN_C : (rivalWins>playerWins ? RED_C : YLW);

  for (int g=0;g<4;g++) {
    fill(0,0,0,0);
    stroke(topCol,50-g*12);
    strokeWeight(5-g);
    rect(mx-g,my-g,mw+g*2,mh+g*2,14+g);
  }

  fill(color(16,22,32));
  stroke(topCol);
  strokeWeight(2);
  rect(mx,my,mw,mh,12);

  textFont(titleFont);
  textSize(22);
  textAlign(CENTER,TOP);
  fill(topCol);
  noStroke();
  String title = playerWins>rivalWins ? "YOU WIN THE MATCH!" : (rivalWins>playerWins ? "RIVAL WINS THE MATCH" : "MATCH TIED");
  text(title,mx+mw/2,my+16);

  textFont(nameFont);
  textSize(13);
  textAlign(CENTER,TOP);
  fill(TXT_MED);
  text(playerName+" vs A.I. Rival — 3 Shift Score Battle",mx+mw/2,my+48);

  int col0=mx+16,col1=mx+140,col2=mx+292,col3=mx+444,hy=my+82;
  textFont(mono);
  textSize(10);
  textAlign(LEFT,TOP);
  noStroke();
  fill(TXT_DIM);
  text("SHIFT",col0,hy);
  fill(PLAYER_COL);
  text(playerName.toUpperCase()+" (YOU)",col1,hy);
  fill(AI_COL);
  text("A.I. RIVAL",col2,hy);
  fill(TXT_MED);
  text("RESULT",col3,hy);
  stroke(BORDER_C);
  strokeWeight(1);
  line(mx+10,hy+16,mx+mw-10,hy+16);

  for (int s=0;s<TOTAL_SHIFTS;s++) {
    int ry=hy+28+s*66;
    int outcome=shiftOutcome[s];
    fill(outcome>0?color(10,26,14):(outcome<0?color(26,10,10):color(34,28,10)));
    noStroke();
    rect(mx+10,ry-4,mw-20,58,6);

    textFont(titleFont);
    textSize(13);
    textAlign(LEFT,TOP);
    fill(TXT_BRT);
    noStroke();
    text("SHIFT "+(s+1),col0,ry+4);

    textFont(mono);
    textSize(10);
    textAlign(LEFT,TOP);
    fill(PLAYER_COL);
    text("Score: "+shiftPlayerScore[s],col1,ry);
    text("Del: "+shiftPlayerDel[s]+"/"+N_PKG,col1,ry+18);

    fill(AI_COL);
    text("Score: "+shiftAiScore[s],col2,ry);
    text("Del: "+shiftAiDel[s]+"/"+N_PKG,col2,ry+18);

    fill(outcome>0?color(10,36,16):(outcome<0?color(36,10,10):color(44,34,10)));
    stroke(outcome>0?GRN:(outcome<0?RED_C:YLW));
    strokeWeight(1.2);
    rect(col3,ry+6,96,24,5);
    textFont(titleFont);
    textSize(11);
    textAlign(CENTER,CENTER);
    fill(outcome>0?GRN:(outcome<0?RED_C:YLW));
    noStroke();
    text(outcome>0?"YOU":(outcome<0?"RIVAL":"TIE"),col3+48,ry+18);

    stroke(BORDER_C);
    strokeWeight(1);
    line(mx+10,ry+62,mx+mw-10,ry+62);
  }

  int sy=hy+28+TOTAL_SHIFTS*66+4;
  fill(color(20,28,40));
  stroke(BORDER_C);
  strokeWeight(1);
  rect(mx+10,sy,mw-20,78,6);

  textFont(titleFont);
  textSize(12);
  textAlign(LEFT,TOP);
  fill(TXT_BRT);
  noStroke();
  text("FINAL TOTALS",col0+4,sy+8);

  textFont(mono);
  textSize(11);
  textAlign(LEFT,TOP);
  fill(PLAYER_COL);
  text(playerName+": "+totalPlayerScore+" pts   "+playerWins+" shift wins",col0+4,sy+28);
  fill(AI_COL);
  text("A.I. Rival: "+totalAiScore+" pts   "+rivalWins+" shift wins",col0+4,sy+44);
  fill(YLW);
  text("Tied shifts: "+ties,col0+4,sy+60);

  String verdict;
  color vCol;
  if (playerWins>rivalWins) {
    verdict="Nice run — you won more shifts and finished ahead overall.";
    vCol=CYAN_C;
  } else if (rivalWins>playerWins) {
    verdict="The rival edged this one. Your scoring loop is working — now go beat it.";
    vCol=RED_C;
  } else {
    verdict="Deadlock. Same number of shift wins — total score says "+totalPlayerScore+" to "+totalAiScore+".";
    vCol=YLW;
  }

  textFont(nameFont);
  textSize(12);
  textAlign(CENTER,TOP);
  fill(vCol);
  noStroke();
  text(verdict,mx+mw/2,sy+88);

  int bh=34,btnY=my+mh-46,b1w=150,b2w=170,b3w=150,gap3=10;
  int totalBW=b1w+b2w+b3w+gap3*2;
  int b1x=mx+(mw-totalBW)/2;
  int b2x=b1x+b1w+gap3;
  int b3x=b2x+b2w+gap3;

  boolean h1=mouseX>=b1x&&mouseX<=b1x+b1w&&mouseY>=btnY&&mouseY<=btnY+bh;
  fill(h1?PLAYER_COL:color(20,36,54));
  stroke(PLAYER_COL);
  strokeWeight(1.4);
  rect(b1x,btnY,b1w,bh,6);
  fill(h1?BG:PLAYER_COL);
  noStroke();
  textFont(titleFont);
  textSize(12);
  textAlign(CENTER,CENTER);
  text("↺ PLAY AGAIN",b1x+b1w/2,btnY+bh/2);

  boolean h2=mouseX>=b2x&&mouseX<=b2x+b2w&&mouseY>=btnY&&mouseY<=btnY+bh;
  fill(h2?TXT_MED:color(22,30,42));
  stroke(TXT_MED);
  strokeWeight(1.4);
  rect(b2x,btnY,b2w,bh,6);
  fill(h2?BG:TXT_MED);
  noStroke();
  textSize(11);
  text("CHANGE DIFFICULTY",b2x+b2w/2,btnY+bh/2);

  boolean h3=mouseX>=b3x&&mouseX<=b3x+b3w&&mouseY>=btnY&&mouseY<=btnY+bh;
  fill(h3?BLUE_B:color(18,28,42));
  stroke(BLUE_B);
  strokeWeight(1.4);
  rect(b3x,btnY,b3w,bh,6);
  fill(h3?BG:BLUE_B);
  noStroke();
  textSize(12);
  text("MAIN MENU",b3x+b3w/2,btnY+bh/2);
}

void drawPauseOverlay() {
  fill(BG,185);
  noStroke();
  rect(MAP_X,MAP_Y,MAP_W,MAP_H);

  textFont(titleFont);
  textSize(26);
  textAlign(CENTER,CENTER);
  fill(YLW);
  noStroke();
  text("PAUSED",MAP_X+MAP_W/2,MAP_Y+MAP_H/2-68);

  textFont(mono);
  textSize(11);
  fill(TXT_DIM);
  textAlign(CENTER,CENTER);
  text("ESC to pause · R to resume",MAP_X+MAP_W/2,MAP_Y+MAP_H/2-40);

  int btnW=180,btnH=36,btnX=(int)(MAP_X+MAP_W/2)-btnW/2;

  // Resume
  int r1y=(int)(MAP_Y+MAP_H/2)-12;
  boolean hR=mouseX>=btnX&&mouseX<=btnX+btnW&&mouseY>=r1y&&mouseY<=r1y+btnH;
  fill(hR?GRN:color(12,36,18));
  stroke(GRN);
  strokeWeight(1.5);
  rect(btnX,r1y,btnW,btnH,6);
  fill(hR?BG:GRN);
  noStroke();
  textFont(titleFont);
  textSize(13);
  textAlign(CENTER,CENTER);
  text("▶  RESUME  (R)",btnX+btnW/2,r1y+btnH/2);

  // Restart
  int r2y=r1y+btnH+10;
  boolean hRs=mouseX>=btnX&&mouseX<=btnX+btnW&&mouseY>=r2y&&mouseY<=r2y+btnH;
  fill(hRs?YLW:color(34,28,8));
  stroke(YLW);
  strokeWeight(1.5);
  rect(btnX,r2y,btnW,btnH,6);
  fill(hRs?BG:YLW);
  noStroke();
  textFont(titleFont);
  textSize(13);
  textAlign(CENTER,CENTER);
  text("↺  RESTART",btnX+btnW/2,r2y+btnH/2);

  // Change Difficulty
  int r3y=r2y+btnH+10;
  boolean hD=mouseX>=btnX&&mouseX<=btnX+btnW&&mouseY>=r3y&&mouseY<=r3y+btnH;
  fill(hD?TXT_MED:color(20,28,38));
  stroke(TXT_MED);
  strokeWeight(1.5);
  rect(btnX,r3y,btnW,btnH,6);
  fill(hD?BG:TXT_MED);
  noStroke();
  textFont(titleFont);
  textSize(13);
  textAlign(CENTER,CENTER);
  text("CHANGE DIFFICULTY",btnX+btnW/2,r3y+btnH/2);

  int r4y=r3y+btnH+10;
  boolean hM=mouseX>=btnX&&mouseX<=btnX+btnW&&mouseY>=r4y&&mouseY<=r4y+btnH;
  fill(hM?BLUE_B:color(18,28,42));
  stroke(BLUE_B);
  strokeWeight(1.5);
  rect(btnX,r4y,btnW,btnH,6);
  fill(hM?BG:BLUE_B);
  noStroke();
  textFont(titleFont);
  textSize(13);
  textAlign(CENTER,CENTER);
  text("MAIN MENU",btnX+btnW/2,r4y+btnH/2);
  
  
  // --- 5th UI Component: Toggle A.I. Path Checkbox ---
  int r5y = r4y + btnH + 15;
  int boxSize = 18;
  int boxX = btnX + 20;
  
  // Create a larger invisible bounding box for easier clicking
  boolean hToggle = mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= r5y - 4 && mouseY <= r5y + 26;

  // Hover background glow
  fill(hToggle ? color(30, 40, 50) : color(20, 25, 35, 0));
  noStroke();
  rect(btnX, r5y - 4, btnW, 26, 4);

  // Draw the actual checkbox
  stroke(TXT_MED);
  strokeWeight(1.5);
  fill(color(14, 22, 30));
  rect(boxX, r5y, boxSize, boxSize, 3);

  // Draw the Checkmark (Fill) if toggled ON
  if (showPath) {
    fill(GRN);
    noStroke();
    rect(boxX + 4, r5y + 4, boxSize - 8, boxSize - 8, 2); 
  }

  // Label
  textFont(mono);
  textSize(11);
  textAlign(LEFT, CENTER);
  fill(TXT_BRT);
  text("Show A.I. Path", boxX + boxSize + 12, r5y + boxSize / 2 - 1);
}

void drawTerminalScreen() {
  // Darken the background
  fill(BG, 200);
  noStroke();
  rect(MAP_X, MAP_Y, MAP_W, MAP_H);

  int mw = 300, mh = 360;
  int mx = MAP_X + (MAP_W - mw) / 2;
  int my = MAP_Y + (MAP_H - mh) / 2;

  // Terminal Window
  fill(color(14, 22, 30));
  stroke(CYAN_C);
  strokeWeight(2);
  rect(mx, my, mw, mh, 8);

  textFont(titleFont);
  textSize(18);
  textAlign(CENTER, TOP);
  fill(CYAN_C);
  text("INVENTORY LOCATOR SYSTEM", mx + mw / 2, my + 16);
  
  textFont(mono);
  textSize(11);
  fill(TXT_MED);
  text("Select an active package to ping its location.", mx + mw / 2, my + 42);

  // Draw the "Dropdown" List
  int startY = my + 80;
  for (int i = 0; i < terminalList.length; i++) {
    int btnY = startY + i * 32;
    boolean hov = mouseX >= mx + 20 && mouseX <= mx + mw - 20 && mouseY >= btnY && mouseY <= btnY + 26;
    
    fill(hov ? color(28, 88, 112) : color(20, 30, 42));
    stroke(hov ? CYAN_C : BORDER_C);
    strokeWeight(1);
    rect(mx + 20, btnY, mw - 40, 26, 4);
    
    textAlign(LEFT, CENTER);
    fill(hov ? TXT_BRT : TXT_MED);
    text(terminalList[i], mx + 30, btnY + 12);
  }

  // Cancel Button
  int cY = my + mh - 40;
  boolean c_hov = mouseX >= mx + mw/2 - 50 && mouseX <= mx + mw/2 + 50 && mouseY >= cY && mouseY <= cY + 26;
  fill(c_hov ? RED_C : color(40, 20, 20));
  stroke(RED_C);
  rect(mx + mw/2 - 50, cY, 100, 26, 4);
  textAlign(CENTER, CENTER);
  fill(c_hov ? BG : RED_C);
  text("CLOSE", mx + mw/2, cY + 12);
}
