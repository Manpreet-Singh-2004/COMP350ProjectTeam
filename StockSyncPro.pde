// =============================================================
// FILE 1: StockSyncPro.pde (MAIN ROUTER & DESIGN 1)
// =============================================================

// ── Screen IDs ───────────────────────────────────────────────
final int SCR_TITLE  = 0;
final int SCR_CHOOSE = 1;
final int SCR_D1     = 2;
final int SCR_D2     = 3;
final int SCR_RECAP  = 4;
int scr = SCR_TITLE;

// ── Fade transition ───────────────────────────────────────────
float tAlpha     = 255;
int   tTarget    = -1;
boolean tFadeOut = false;

// ── Recap data (shared) ───────────────────────────────────────
int   lastMode       = 1;
int   recapScore     = 0;
int   recapCorrect   = 0;
int   recapTotal     = 0;
int   recapCombo     = 0;
int   recapReorders  = 0;
int   recapStockouts = 0;
float recapAcc       = 0;
int[] recapCatOK     = new int[3];
int[] recapCatTot    = new int[3];

// ── Fonts ─────────────────────────────────────────────────────
PFont MONO, SANS;
int W, H;

// =============================================================
//  DESIGN 1 – TACTICAL SCANNER (Conveyor Game)
// =============================================================
int   g_score = 0, g_lives = 3, g_combo = 0, g_maxCombo = 0;
int   g_total = 0, g_correct = 0;
float g_speed = 2.2, g_spawn = 130;
int   g_sinceSpawn = 0, g_startFrame = 0;
ArrayList<ScanItem> g_items = new ArrayList<ScanItem>();
ScanItem g_scanned = null;
int   g_feedTimer  = 0;
boolean g_feedOK   = false;
String  g_feedMsg  = "";
int[] g_catOK  = new int[3];
int[] g_catTot = new int[3];

String[] G_NAME  = { "Milk",   "Cheese", "Bread",  "Bagel",  "Apple",  "Carrot", "Yogurt", "Muffin" };
String[] G_AISLE = { "Dairy",  "Dairy",  "Bakery", "Bakery", "Produce","Produce","Dairy",  "Bakery" };
int[]    G_DEST  = { LEFT,     LEFT,     RIGHT,    RIGHT,    UP,       UP,       LEFT,     RIGHT    };
int[]    G_CAT   = { 0,        0,        1,        1,        2,        2,        0,        1        };
int[][]  G_COL   = {
  {175,215,255},{255,235,80},{255,218,160},{242,188,130},
  {138,232,110},{255,138,70},{198,242,198},{255,202,148}
};

float G_CVY, G_CVH = 108;
float G_SZX, G_SZW = 92;
float G_ITW = 80, G_ITH = 68;

// =============================================================
//  MAIN PROCESSING LOOP
// =============================================================
void setup() {
  size(900, 560);
  W = width; H = height;
  frameRate(60);
  MONO = createFont("Monospace", 14, true);
  SANS = createFont("SansSerif",  14, true);
  textFont(SANS);
  G_CVY = H / 2.0 - G_CVH / 2.0 + 18;
  G_SZX = W / 2.0 - G_SZW / 2.0;
  tAlpha = 255;
}

void draw() {
  switch (scr) {
    case SCR_TITLE:  drawTitle();  break;
    case SCR_CHOOSE: drawChoose(); break;
    case SCR_D1:     drawD1();     break;
    case SCR_D2:     drawD2();     break;  // Function lives in Design2_Manager.pde
    case SCR_RECAP:  drawRecap();  break;
  }
  
  // Fade overlay
  noStroke();
  if (tFadeOut) {
    tAlpha = min(255, tAlpha + 16);
    fill(14, 18, 28, tAlpha);
    rect(0, 0, W, H);
    if (tAlpha >= 255 && tTarget >= 0) {
      scr = tTarget; tTarget = -1;
      tFadeOut = false;
      onEnter(scr);
    }
  } else if (tAlpha > 0) {
    tAlpha = max(0, tAlpha - 14);
    fill(14, 18, 28, tAlpha);
    rect(0, 0, W, H);
  }
}

void goTo(int t) { if (!tFadeOut) { tTarget = t; tFadeOut = true; } }

void onEnter(int s) {
  if (s == SCR_D1) initD1();
  if (s == SCR_D2) initD2(); // Function lives in Design2_Manager.pde
}

// ─────────────────────────────────────────────────────────────
//  TITLE SCREEN
// ─────────────────────────────────────────────────────────────
void drawTitle() {
  background(14, 18, 28);
  stroke(26, 34, 54); strokeWeight(1);
  for (int x = 0; x < W; x += 44) line(x, 0, x, H);
  for (int y = 0; y < H; y += 44) line(0, y, W, y);
  noStroke();

  drawLogoMark(W/2, 160, 62);

  fill(255); textFont(MONO); textAlign(CENTER); textSize(48);
  text("STOCK-SYNC PRO", W/2, 268);
  fill(80, 140, 220); textFont(SANS); textSize(14);
  text("REAL-TIME INVENTORY MANAGEMENT SYSTEM", W/2, 298);

  fill(120, 140, 180); textSize(13);
  text("Dual-Mode Platform  ·  Floor Associates  &  Inventory Managers", W/2, 344);

  fill(60, 75, 120); textSize(11);
  text("Manpreet Singh  ·  Paramvir Singh Thind  ·  Shreyas Dutt", W/2, 392);

  if (frameCount % 70 < 52) {
    fill(50, 150, 255); textSize(16);
    text("PRESS  ENTER  TO  LAUNCH", W/2, 462);
  }
}

void drawLogoMark(float cx, float cy, float sz) {
  noStroke();
  fill(26, 72, 180);
  rect(cx - sz*0.62, cy - sz*0.50, sz*1.24, sz, 7);
  fill(14, 18, 28);
  int bars = 9;
  float bw = sz * 0.95, bx = cx - bw*0.5;
  float barW = bw / (bars * 2.0 - 1);
  for (int i = 0; i < bars; i++)
    rect(bx + i * barW * 2, cy - sz*0.35, barW, sz * 0.70);
  fill(255, 255, 255, 50);
  rect(cx - sz*0.62, cy - sz*0.50, sz*1.24, sz*0.28, 7, 7, 0, 0);
}

// ─────────────────────────────────────────────────────────────
//  CHOOSE SCREEN
// ─────────────────────────────────────────────────────────────
void drawChoose() {
  background(18, 22, 36);
  fill(160, 180, 220); textFont(SANS); textAlign(CENTER); textSize(12);
  text("SELECT YOUR DESIGN VARIATION", W/2, 56);
  fill(255); textSize(22);
  text("Which UI paradigm do you want to prototype?", W/2, 82);

  drawD1Card(44,  116, (W/2) - 62, 370);
  drawD2Card(W/2 + 18, 116, (W/2) - 62, 370);

  fill(70, 85, 130); textSize(12);
  text("Press  1  or  2  to begin", W/2, 510);
}

void drawD1Card(float x, float y, float w, float h) {
  noStroke();
  fill(18, 26, 44); rect(x, y, w, h, 10);
  fill(26, 76, 186); rect(x, y, w, 50, 10, 10, 0, 0);

  fill(255); textFont(MONO); textAlign(LEFT); textSize(10);
  text("DESIGN  1", x+14, y+18);
  textSize(15); text("TACTICAL  SCANNER", x+14, y+38);

  fill(40, 46, 66); rect(x+14, y+66, w-28, 54, 4);
  fill(175,215,255); rect(x+48, y+73, 52, 38, 4);
  fill(14, 18, 28); textFont(MONO); textAlign(CENTER); textSize(10);
  text("Milk", x+74, y+88); fill(40,40,80); textSize(9); text("DAIRY", x+74, y+102);
  stroke(255,255,100,180); strokeWeight(1.5); noFill();
  rect(x+118, y+62, 36, 62, 3); noStroke();
  fill(255,255,100,80); textFont(SANS); textSize(8); textAlign(CENTER);
  text("SCAN", x+136, y+84); text("ZONE", x+136, y+96);

  fill(130, 165, 215); textFont(SANS); textSize(12); textAlign(LEFT);
  text("For: Floor Associates", x+14, y+148);
  text("High-contrast, speed-focused", x+14, y+168);
  text("Large interaction targets", x+14, y+188);
  text("Skeuomorphic scan feedback", x+14, y+208);
  text("Linear 3-step flow: Scan-ID-Route", x+14, y+228);

  fill(22, 54, 140); rect(x+14, y+248, 78, 22, 4);
  fill(180,215,255); textSize(10); textAlign(CENTER);
  text("DARK  MODE", x+53, y+263);
  fill(16, 42, 110); rect(x+102, y+248, 84, 22, 4);
  fill(160,200,255); text("TOUCH-FIRST", x+144, y+263);

  fill(90,130,210); textFont(MONO); textSize(11); textAlign(CENTER);
  text("SPACE  ←  →  ↑", x+w/2, y+296);

  fill(30, 88, 200); rect(x+w/2-52, y+h-52, 104, 36, 6);
  fill(255); textFont(SANS); textSize(15);
  text("PRESS  1", x+w/2, y+h-28);
}

void drawD2Card(float x, float y, float w, float h) {
  noStroke();
  fill(244, 246, 252); rect(x, y, w, h, 10);
  fill(24, 40, 74); rect(x, y, w, 50, 10, 10, 0, 0);

  fill(255); textFont(MONO); textAlign(LEFT); textSize(10);
  text("DESIGN  2", x+14, y+18);
  textSize(15); text("COMMAND  CENTER", x+14, y+38);

  float[] bv = {0.75, 0.45, 0.90, 0.32, 0.68};
  color[] bc = {color(60,120,220),color(220,160,40),color(60,180,100),color(220,80,80),color(60,120,220)};
  for (int i = 0; i < 5; i++) {
    float bh = bv[i] * 46;
    fill(bc[i], 180);
    rect(x+14+i*30, y+66+(46-bh), 22, bh, 2);
  }
  stroke(188,200,224); strokeWeight(0.8);
  line(x+12, y+112, x+170, y+112); noStroke();
  fill(220,40,40); rect(x+w-56, y+68, 40, 18, 3);
  fill(255); textFont(SANS); textSize(10); textAlign(CENTER);
  text("LOW", x+w-36, y+81);

  fill(55, 70, 110); textFont(SANS); textSize(12); textAlign(LEFT);
  text("For: Inventory Managers", x+14, y+148);
  text("Data-dense analytics view", x+14, y+168);
  text("SKU performance metrics", x+14, y+188);
  text("Live stock level tracking", x+14, y+208);
  text("Resource Budget Management", x+14, y+228);

  fill(218,228,248); stroke(168,188,228); strokeWeight(0.8);
  rect(x+14, y+248, 82, 22, 4); noStroke();
  fill(36, 68, 155); textSize(10); textAlign(CENTER);
  text("LIGHT  MODE", x+55, y+263);
  fill(218,240,224); stroke(155,208,170); strokeWeight(0.8);
  rect(x+106, y+248, 82, 22, 4); noStroke();
  fill(25, 115, 58); text("DATA-DENSE", x+147, y+263);

  fill(90,100,150); textFont(MONO); textSize(11); textAlign(CENTER);
  text("KEYS  1-6  to  REORDER", x+w/2, y+296);

  fill(24, 40, 74); rect(x+w/2-52, y+h-52, 104, 36, 6);
  fill(255); textFont(SANS); textSize(15);
  text("PRESS  2", x+w/2, y+h-28);
}

// ─────────────────────────────────────────────────────────────
//  DESIGN 1 — TACTICAL SCANNER GAME
// ─────────────────────────────────────────────────────────────
void initD1() {
  g_score=0; g_lives=3; g_combo=0; g_maxCombo=0;
  g_total=0; g_correct=0;
  g_items.clear(); g_scanned=null; g_feedTimer=0;
  g_sinceSpawn=0; g_startFrame=frameCount;
  g_speed=2.2; g_spawn=130;
  g_catOK=new int[3]; g_catTot=new int[3];
}

void drawD1() {
  background(12, 16, 26);
  stroke(20,26,42); strokeWeight(1);
  for (int x=0; x<W; x+=50) line(x,0,x,H);
  for (int y=0; y<H; y+=50) line(0,y,W,y);
  noStroke();

  d1Scale();
  g_sinceSpawn++;
  if (g_sinceSpawn >= g_spawn) { d1Spawn(); g_sinceSpawn=0; }

  for (int i=g_items.size()-1; i>=0; i--) {
    ScanItem it = g_items.get(i);
    it.update();
    if (it.x > W + G_ITW) {
      if (!it.routed) {
        g_lives=max(0,g_lives-1); g_combo=0; g_total++;
        g_catTot[it.cat]++;
        d1Feed(false,"MISSED!");
      }
      g_items.remove(i);
    }
  }

  d1DrawAisles(); d1DrawConveyor();
  for (ScanItem it : g_items) it.render();
  d1DrawScanZone(); d1DrawHUD();
  if (g_feedTimer > 0) { d1DrawFeedback(); g_feedTimer--; }
  if (g_lives <= 0) d1End();
}

void d1DrawHUD() {
  noStroke(); fill(8,12,22,235); rect(0,0,W,54);
  fill(0,150,80); rect(0,0,4,54);
  fill(0,140,75); rect(12,13,72,22,3);
  fill(255); textFont(MONO); textAlign(LEFT); textSize(10);
  text("DESIGN 1",20,28);

  fill(50,210,120); textSize(11); text("SCORE",102,17);
  textSize(24); text(g_score,102,44);
  int mult = d1Mult();
  fill(mult>1 ? color(255,160,40) : color(140,160,200));
  textAlign(CENTER); textSize(11); text("COMBO",W/2,17);
  textSize(24); text(g_combo+"  x"+mult,W/2,44);

  fill(255,70,70); textAlign(RIGHT); textSize(11); text("LIVES",W-18,17);
  String h=""; for(int i=0;i<3;i++) h+=(i<g_lives)?"♥ ":"♡ ";
  textSize(20); text(h.trim(),W-18,44);

  int e=frameCount-g_startFrame;
  String phase=e<1800?"EASY":e<5400?"MEDIUM":"HARD";
  color pc=e<1800?color(60,220,100):e<5400?color(255,190,40):color(255,80,80);
  fill(pc); textAlign(CENTER); textFont(SANS); textSize(10); text(phase,W/2,52);
  fill(50,60,100); textFont(SANS); textAlign(LEFT); textSize(10);
  text("ESC = end shift",12,H-8);
}

void d1DrawAisles() {
  noStroke();
  fill(40,100,220,18); rect(0,0,72,H);
  fill(40,100,220,16); rect(W-72,0,72,H);
  fill(30,155,80,18); rect(0,54,W,40);

  textFont(MONO); textSize(11); textAlign(CENTER);
  fill(60,140,255,185);
  pushMatrix(); translate(26,H/2); rotate(-HALF_PI); text("◄  DAIRY",0,0); popMatrix();
  fill(255,185,40,185);
  pushMatrix(); translate(W-26,H/2); rotate(HALF_PI); text("BAKERY  ►",0,0); popMatrix();
  fill(60,220,100,185); text("▲  PRODUCE",W/2,80);
}

void d1DrawConveyor() {
  noStroke(); fill(44,50,70); rect(0,G_CVY,W,G_CVH);
  stroke(56,64,84); strokeWeight(1.5);
  int sp=52, off=(int)(frameCount*g_speed*0.5)%sp;
  for (int x=-sp*2+off; x<W+sp; x+=sp) line(x,G_CVY,x+26,G_CVY+G_CVH);
  noStroke();
  fill(62,70,92); rect(0,G_CVY-8,W,8); rect(0,G_CVY+G_CVH,W,8);
  fill(80,90,115); rect(0,G_CVY-8,W,2); rect(0,G_CVY+G_CVH+6,W,2);
}

void d1DrawScanZone() {
  ScanItem inZ = d1InZone();
  boolean hot  = inZ!=null;
  float gx=G_SZX-6, gy=G_CVY-18, gw=G_SZW+12, gh=G_CVH+36;
  float p = hot ? 0.5+0.5*sin(frameCount*0.15) : 0;
  noStroke(); fill(hot?color(255,255,80,18+p*42):color(255,255,255,8));
  rect(gx,gy,gw,gh,5);
  stroke(hot?color(255,255,80,200+p*55):color(120,130,165,160));
  strokeWeight(hot?2.2:1.2); noFill(); rect(gx,gy,gw,gh,5); noStroke();
  color lc=hot?color(255,255,80):color(120,130,165);
  fill(lc); textFont(MONO); textAlign(CENTER); textSize(10);
  text("SCAN",G_SZX+G_SZW/2,G_CVY-24);
  text("[SPACE]",G_SZX+G_SZW/2,G_CVY+G_CVH+24);
}

void d1DrawFeedback() {
  float a=map(g_feedTimer,0,50,0,255);
  float dy=map(g_feedTimer,50,0,0,22);
  fill(g_feedOK?color(60,230,120,a):color(255,80,80,a));
  textFont(MONO); textAlign(CENTER); textSize(28);
  text(g_feedMsg,W/2,G_CVY-62+dy);
}

void d1Spawn() {
  int ti=(int)random(G_NAME.length);
  g_items.add(new ScanItem(-G_ITW,G_CVY+G_CVH/2-G_ITH/2,ti));
}

void d1Scale() {
  int e=frameCount-g_startFrame;
  if (e<1800) { g_speed=2.2; g_spawn=130; }
  else if (e<5400) { float t=(e-1800)/3600.0; g_speed=lerp(2.2,3.8,t); g_spawn=lerp(130,70,t); }
  else { float t=min(1,(e-5400)/3600.0); g_speed=lerp(3.8,5.5,t); g_spawn=max(46,lerp(70,46,t)); }
}

ScanItem d1InZone() {
  ScanItem best=null; float bd=Float.MAX_VALUE;
  for (ScanItem it : g_items) {
    float cx=it.x+G_ITW/2;
    if (cx>G_SZX&&cx<G_SZX+G_SZW) {
      float d=abs(cx-(G_SZX+G_SZW/2));
      if (d<bd) { bd=d; best=it; }
    }
  }
  return best;
}

int d1Mult() { return g_combo>=6?3:g_combo>=3?2:1; }
void d1Feed(boolean ok,String msg) { g_feedOK=ok; g_feedMsg=msg; g_feedTimer=50; }

void d1Route(ScanItem it, int key) {
  it.routed=true; g_total++; g_catTot[it.cat]++;
  boolean ok=(key==it.destKey);
  if (ok) {
    g_combo++; if(g_combo>g_maxCombo) g_maxCombo=g_combo;
    int mult=d1Mult(); int pts=10*mult;
    boolean fast=(frameCount-it.scannedAt)<50; if(fast) pts+=5;
    g_score+=pts; g_correct++; g_catOK[it.cat]++;
    d1Feed(true,"+"+ pts+(fast?"  FAST!":""));
  } else {
    g_lives=max(0,g_lives-1); g_combo=0; g_score=max(0,g_score-10);
    d1Feed(false,"WRONG AISLE!");
  }
  g_items.remove(it);
}

void d1End() {
  lastMode=1; recapScore=g_score; recapCorrect=g_correct; recapTotal=g_total;
  recapCombo=g_maxCombo; recapCatOK=g_catOK.clone(); recapCatTot=g_catTot.clone();
  recapAcc=g_total>0?(float)g_correct/g_total*100:0;
  goTo(SCR_RECAP);
}

class ScanItem {
  float x,y; int ti,cat; String name,aisle; int destKey; color col;
  boolean scanned=false,routed=false; int flashTimer=0,scannedAt=0;

  ScanItem(float x,float y,int ti) {
    this.x=x;this.y=y;this.ti=ti;
    name=G_NAME[ti];aisle=G_AISLE[ti];destKey=G_DEST[ti];cat=G_CAT[ti];
    col=color(G_COL[ti][0],G_COL[ti][1],G_COL[ti][2]);
  }
  void update() { if(!routed) x+=g_speed; if(flashTimer>0) flashTimer--; }
  void render() {
    float cx=x+G_ITW/2,cy=y+G_ITH/2;
    noStroke();
    fill(0,0,0,58); rect(x+4,y+4,G_ITW,G_ITH,8);
    color base=scanned?lerpColor(col,color(255,255,255),0.25):col;
    if(flashTimer>0) base=lerpColor(base,color(255,255,120),0.62);
    fill(base); stroke(255,255,255,68); strokeWeight(1.3); rect(x,y,G_ITW,G_ITH,8); noStroke();
    if(scanned) {
      fill(60,232,118); ellipse(x+G_ITW-10,y+11,9,9);
      color ac=destKey==LEFT?color(90,165,255):destKey==RIGHT?color(255,185,40):color(70,228,100);
      fill(ac,228); textFont(MONO); textAlign(CENTER); textSize(18);
      text(destKey==LEFT?"◄":destKey==RIGHT?"►":"▲",cx,y-8);
    }
    fill(16,20,32); textFont(MONO); textAlign(CENTER); textSize(12); text(name,cx,cy-4);
    fill(44,52,88); textFont(SANS); textSize(9); text(aisle,cx,cy+11);
    stroke(22,26,40,155); strokeWeight(1);
    for(int i=0;i<9;i++){float bx=x+6+i*7.4;line(bx,y+G_ITH-13,bx,y+G_ITH-5);}
    noStroke();
  }
}

// ─────────────────────────────────────────────────────────────
//  RECAP / SESSION SUMMARY
// ─────────────────────────────────────────────────────────────
void drawRecap() {
  background(14,18,28);
  color accent=(lastMode==1)?color(0,150,80):color(55,130,255);
  noStroke(); fill(accent); rect(0,0,W,6);

  fill(145,165,210); textFont(MONO); textAlign(CENTER); textSize(11);
  text("STOCK-SYNC PRO  |  SESSION COMPLETE",W/2,34);
  fill(255); textSize(36); text("SHIFT  SUMMARY",W/2,76);
  fill(accent); textFont(SANS); textSize(13);
  String ml=(lastMode==1)?"DESIGN 1 — TACTICAL SCANNER":"DESIGN 2 — COMMAND CENTER";
  text(ml,W/2,100);

  if(lastMode==1) recapD1(); else recapD2(); // Function lives in Design2_Manager.pde

  color other=(lastMode==1)?color(55,130,255):color(0,150,80);
  noStroke(); fill(other); rect(W/2-215,H-76,200,40,6);
  fill(255); textFont(SANS); textSize(13); textAlign(CENTER);
  text(lastMode==1?"TRY DESIGN 2  [2]":"TRY DESIGN 1  [1]",W/2-115,H-50);
  fill(38,48,78); rect(W/2+15,H-76,200,40,6);
  fill(255); text("PLAY AGAIN  [ENTER]",W/2+115,H-50);
  fill(55,68,115); textSize(12);
  text("ESC  →  Main Menu",W/2,H-14);
}

void recapD1() {
  float cy=122;
  float[] xs={W/2-265,W/2-88,W/2+88,W/2+265};
  String[] labs={"SCORE","ACCURACY","BEST COMBO","ITEMS OK"};
  String[] vals={str(recapScore),nf(recapAcc,1,1)+"%","x"+recapCombo,recapCorrect+"/"+recapTotal};
  color[] cs={color(50,210,120),color(55,155,255),color(255,155,40),color(190,80,255)};

  for(int i=0;i<4;i++){
    noStroke(); fill(22,28,48); rect(xs[i]-77,cy,154,78,8);
    fill(cs[i]); rect(xs[i]-77,cy,154,4,8,8,0,0);
    fill(95,115,175); textFont(MONO); textSize(10); textAlign(CENTER);
    text(labs[i],xs[i],cy+20);
    fill(cs[i]); textSize(26); text(vals[i],xs[i],cy+56);
  }

  float by=cy+108;
  String[] cats={"DAIRY","BAKERY","PRODUCE"};
  color[] cc={color(55,130,225),color(255,180,40),color(55,210,95)};
  fill(140,160,205); textFont(SANS); textSize(12); textAlign(CENTER);
  text("ACCURACY  BY  CATEGORY",W/2,by-10);

  for(int i=0;i<3;i++){
    float bx=W/2-240+i*168;
    float acc=recapCatTot[i]>0?(float)recapCatOK[i]/recapCatTot[i]:0;
    noStroke(); fill(22,28,48); rect(bx,by,148,72,8);
    fill(32,40,64); rect(bx+10,by+35,128,10,3);
    fill(cc[i]); rect(bx+10,by+35,128*acc,10,3);
    fill(cc[i]); textFont(MONO); textSize(11); textAlign(CENTER); text(cats[i],bx+74,by+18);
    fill(195,208,232); textSize(13); text(nf(acc*100,1,0)+"%  ("+recapCatOK[i]+"/"+recapCatTot[i]+")",bx+74,by+60);
  }
}

// ─────────────────────────────────────────────────────────────
//  INPUT
// ─────────────────────────────────────────────────────────────
void keyPressed() {
  if(keyCode==ESC) key=0; // block ESC

  if(scr==SCR_TITLE)  { if(keyCode==ENTER) goTo(SCR_CHOOSE); }

  else if(scr==SCR_CHOOSE) {
    if(key=='1') goTo(SCR_D1);
    if(key=='2') goTo(SCR_D2);
  }

  else if(scr==SCR_D1) {
    if(keyCode==ESC) { d1End(); return; }
    if(key==' ') {
      ScanItem iz=d1InZone();
      if(iz!=null&&!iz.scanned&&!iz.routed){
        iz.scanned=true; iz.scannedAt=frameCount; iz.flashTimer=12; g_scanned=iz;
      }
    }
    if((keyCode==LEFT||keyCode==RIGHT||keyCode==UP)&&g_scanned!=null&&!g_scanned.routed){
      d1Route(g_scanned,keyCode); g_scanned=null;
    }
  }

  else if(scr==SCR_D2) {
    if(keyCode==ESC) { d2End(); return; }
    if(key>='1'&&key<='6') d2Reorder(key-'1'); // Function lives in Design2_Manager.pde
  }

  else if(scr==SCR_RECAP) {
    if(keyCode==ENTER) goTo(lastMode==1?SCR_D1:SCR_D2);
    if(keyCode==ESC)   goTo(SCR_CHOOSE);
    if(key=='1')       goTo(SCR_D1);
    if(key=='2')       goTo(SCR_D2);
  }
}
