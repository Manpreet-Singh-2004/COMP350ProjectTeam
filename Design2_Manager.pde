// =============================================================
// FILE 2: Design2_Manager.pde (ANALYTICS & ECONOMY LOGIC)
// =============================================================

int   d2_startFrame = 0;
int   d2_duration = 180 * 60;

// ── Decoupled Stock Arrays (The Lerp System) ─────────────────
float[] d2_stock_target = { 0.82, 0.55, 0.93, 0.38, 0.71, 0.49 };
float[] d2_stock_render = { 0.82, 0.55, 0.93, 0.38, 0.71, 0.49 };

float[] d2_rate     = { 0.00018, 0.00028, 0.00012, 0.00040, 0.00022, 0.00030 };
String[] d2_sku     = { "Whole Milk 2L", "White Bread", "Fuji Apples", "Cheddar 400g",  "Orange Juice","Greek Yogurt" };
String[] d2_cat     = { "Dairy","Bakery","Produce","Dairy","Produce","Dairy" };

int   d2_reorders   = 0;
int   d2_score      = 0;
int   d2_stockouts  = 0;
boolean[] d2_alert  = new boolean[6];

// ── Sparkline History ─────────────────────────────────────────
int SL_LEN = 80;
float[][] d2_hist   = new float[6][SL_LEN];
int d2_histIdx      = 0;
int d2_histTimer    = 0;

// ── Operations Budget (The Economy) ───────────────────────────
float d2_budget    = 100.0;
float BUDGET_COST  = 25.0;
float BUDGET_REGEN = 0.12;

// ── Visual FX ─────────────────────────────────────────────────
float alarmAlpha   = 0;

// =============================================================

void initD2() {
  d2_budget = 100.0;
  d2_reorders = 0; d2_score = 0; d2_stockouts = 0;
  alarmAlpha = 0;
  
  float[] initialStock = {0.82, 0.55, 0.93, 0.38, 0.71, 0.49};
  for(int s=0; s<6; s++) {
    d2_stock_target[s] = initialStock[s];
    d2_stock_render[s] = initialStock[s];
    d2_alert[s] = false;
    for(int t=0; t<SL_LEN; t++) d2_hist[s][t] = initialStock[s];
  }
  
  d2_histIdx = 0; d2_histTimer = 0; d2_startFrame = frameCount;
}

void drawD2() {
  background(236,240,250);
  int remaining = d2_duration - (frameCount - d2_startFrame);
  
  // 1. Core Logic Update (Math & Economy)
  d2_budget = min(100.0, d2_budget + BUDGET_REGEN);
  boolean hasCritical = false;

  for(int s=0; s<6; s++) {
    // Drain actual target
    d2_stock_target[s] = max(0, d2_stock_target[s] - d2_rate[s]);
    
    // Lerp visual representation towards target (Fluid Data)
    d2_stock_render[s] += (d2_stock_target[s] - d2_stock_render[s]) * 0.15;
    
    // Check thresholds based on TARGET
    if(d2_stock_target[s] < 0.28 && !d2_alert[s]) { d2_alert[s] = true; }
    if(d2_stock_target[s] <= 0.002) { 
      d2_score = max(0, d2_score - 50);
      d2_stock_target[s] = 0; 
      d2_stockouts++; 
      d2_alert[s] = true; 
    }
    if(d2_stock_target[s] <= 0.05) hasCritical = true;
  }

  // 2. Sparkline Update
  d2_histTimer++;
  if(d2_histTimer >= 6) {
    d2_histTimer = 0; 
    d2_histIdx = (d2_histIdx + 1) % SL_LEN;
    for(int s=0; s<6; s++) d2_hist[s][d2_histIdx] = d2_stock_target[s];
  }

  // 3. Render Dashboard Elements
  d2DrawHeader(remaining);
  d2DrawSKUPanel(10, 76, 344, H-86);
  d2DrawRightPanel(362, 76, W-372, H-86);

  // 4. Critical Alarm State (Night Filter logic)
  if (hasCritical) {
    float pulse = 100 + 50 * sin(frameCount * 0.15);
    alarmAlpha += (pulse - alarmAlpha) * 0.1;
  } else {
    alarmAlpha += (0 - alarmAlpha) * 0.1;
  }
  
  if (alarmAlpha > 1) {
    noStroke(); fill(220, 20, 20, alarmAlpha);
    rect(0, 0, W, H);
  }

  // 5. Draw Floating Messages (From UI_Elements.pde)
  updateAndDrawMessages();

  if(remaining <= 0) d2End();
}

void d2Reorder(int s) {
  if (s < 0 || s >= 6) return;
  
  // Economy Check: Do they have the budget to order?
  if (d2_budget >= BUDGET_COST) {
    d2_budget -= BUDGET_COST;
    boolean wasLow = d2_stock_target[s] < 0.28;
    
    d2_stock_target[s] = 1.0; 
    d2_alert[s] = false; 
    d2_reorders++;
    d2_score += wasLow ? 50 : 10;
    
    // Success feedback
    spawnMsg(mouseX > 0 ? mouseX : W/2, mouseY > 0 ? mouseY : H/2, "-$" + int(BUDGET_COST), color(255, 80, 80));
  } else {
    // Failure feedback (Punishes button mashing)
    spawnMsg(W/2, H - 40, "INSUFFICIENT BUDGET", color(150, 150, 150));
    d2_score = max(0, d2_score - 5); // Penalize spamming
  }
}

// ─────────────────────────────────────────────────────────────
//  DASHBOARD DRAWING FUNCTIONS
// ─────────────────────────────────────────────────────────────
void d2DrawHeader(int remaining) {
  noStroke(); fill(24,40,74); rect(0,0,W,68);
  fill(60,140,255); rect(0,0,4,68);
  fill(46,110,220); rect(14,15,80,22,3);
  fill(255); textFont(MONO); textSize(10); textAlign(LEFT); text("DESIGN  2",22,30);
  fill(255); textFont(SANS); textSize(17); text("STOCK-SYNC PRO  |  Inventory Command Center",106,28);
  fill(145,175,225); textSize(11); text("Live Dashboard  ·  Real-time SKU Performance  ·  Reorder Management",106,48);

  // Budget Meter
  float bw = 120;
  fill(14, 25, 48); rect(W/2 - bw/2, 20, bw, 12, 6);
  fill(d2_budget >= BUDGET_COST ? color(55, 185, 95) : color(220, 80, 80));
  rect(W/2 - bw/2, 20, bw * (d2_budget/100.0), 12, 6);
  fill(255); textAlign(CENTER); textFont(MONO); textSize(10);
  text("OP BUDGET: " + int(d2_budget) + "%", W/2, 48);

  // Timer & Score
  int secs=remaining/60;
  fill(secs<20?color(255,100,80):color(90,220,140));
  textAlign(RIGHT); textSize(11); text("SESSION",W-16,22);
  textSize(26); text(nf(secs/60,1)+":"+nf(secs%60,2),W-16,52);

  fill(165,195,240); textSize(11); textAlign(RIGHT); text("SCORE",W-126,22);
  fill(255); textSize(22); text(d2_score,W-126,50);
}

void d2DrawSKUPanel(float x,float y,float w,float h) {
  noStroke(); fill(255,255,255); rect(x,y,w,h,8);
  fill(240,243,252); rect(x,y,w,34,8,8,0,0);
  stroke(200,210,232); strokeWeight(0.7); line(x,y+34,x+w,y+34); noStroke();
  fill(72,88,140); textFont(SANS); textSize(11); textAlign(LEFT);
  text("SKU / PRODUCT",x+12,y+22); textAlign(RIGHT);
  text("STOCK %",x+w-88,y+22); text("STATUS",x+w-10,y+22);

  float rowH=(h-62)/6.0;
  for(int s=0;s<6;s++){
    float ry=y+34+s*rowH;
    noStroke();
    fill(s%2==0?color(248,250,255):color(255,255,255)); rect(x,ry,w,rowH);
    if(d2_stock_target[s]<0.28){fill(255,235,235); rect(x,ry,w,rowH);}
    stroke(215,222,238); strokeWeight(0.5); line(x,ry+rowH,x+w,ry+rowH); noStroke();

    color cc=d2_cat[s].equals("Dairy")?color(55,115,225):d2_cat[s].equals("Bakery")?color(205,145,35):color(55,175,80);
    fill(cc); ellipse(x+14,ry+rowH/2,8,8);

    fill(24,40,74); textFont(SANS); textSize(12); textAlign(LEFT);
    text(d2_sku[s],x+26,ry+rowH/2+4);
    fill(95,115,165); textSize(10);
    text(d2_cat[s]+"  ·  key ["+(s+1)+"]",x+26,ry+rowH/2+18);

    // USE LERPED VISUAL DATA HERE
    float pct = d2_stock_render[s]; 
    float barW=80, bh=8, bx=x+w-186, by=ry+rowH/2-bh/2;
    fill(215,222,238); rect(bx,by,barW,bh,2);
    color bc=pct>0.5?color(55,185,98):pct>0.28?color(252,178,38):color(252,78,78);
    fill(bc); rect(bx,by,barW*pct,bh,2);

    fill(52,66,110); textAlign(RIGHT); textFont(MONO); textSize(12);
    text(nf(pct*100,1,0)+"%",x+w-96,ry+rowH/2+5);

    String ss=pct<0.15?"CRITICAL":pct<0.28?"LOW STOCK":"IN STOCK";
    color sb=pct<0.15?color(195,38,38):pct<0.28?color(215,135,18):color(38,158,78);
    fill(sb); int bwidth=pct<0.15?64:pct<0.28?72:62;
    rect(x+w-bwidth-4,ry+rowH/2-9,bwidth,18,3);
    fill(255); textFont(MONO); textSize(10); textAlign(CENTER);
    text(ss,x+w-4-bwidth/2,ry+rowH/2+4);
  }

  noStroke(); fill(230,235,250); rect(x,y+h-28,w,28,0,0,8,8);
  stroke(200,210,232); strokeWeight(0.5); line(x,y+h-28,x+w,y+h-28); noStroke();
  fill(75,95,165); textFont(SANS); textSize(11); textAlign(CENTER);
  text("Keys 1-6 to reorder  ·  Cost: $35 Budget",x+w/2,y+h-10);
}

void d2DrawRightPanel(float x,float y,float w,float h) {
  float mid=(h-12)/2;
  d2DrawBarChart(x,y,w,mid);
  d2DrawSparklines(x,y+mid+12,w,h-mid-12);
}

void d2DrawBarChart(float x,float y,float w,float h) {
  noStroke(); fill(255,255,255); rect(x,y,w,h,8);
  fill(24,40,74); textFont(SANS); textSize(13); textAlign(LEFT); text("Current Stock Levels",x+14,y+22);
  fill(115,135,185); textSize(10); text("Live — fluid rendering",x+14,y+38);

  float cx=x+14,cy=y+48,cw=w-28,ch=h-68;
  stroke(200,210,230); strokeWeight(0.7); line(cx,cy,cx,cy+ch); line(cx,cy+ch,cx+cw,cy+ch);
  stroke(252,178,38,150); line(cx,cy+ch*0.72,cx+cw,cy+ch*0.72); noStroke();
  fill(200,150,30,140); textFont(SANS); textSize(9); textAlign(LEFT); text("30% threshold",cx+3,cy+ch*0.72-3);

  for(int s=0;s<6;s++){
    float bx=cx+s*(cw/6)+3, bw=cw/6-8;
    // USE LERPED VISUAL DATA HERE
    float bh=d2_stock_render[s]*ch, by=cy+ch-bh;
    fill(222,228,245); rect(bx,cy,bw,ch,3);
    color bc=d2_stock_render[s]>0.5?color(55,185,98):d2_stock_render[s]>0.28?color(252,178,38):color(252,78,78);
    fill(bc,218); rect(bx,by,bw,bh,3);
    fill(72,88,140); textFont(SANS); textSize(9); textAlign(CENTER);
    text(d2_sku[s].split(" ")[0],bx+bw/2,cy+ch+14);
    if(bh>16){fill(255,255,255,215); textFont(MONO); textSize(10); text(nf(d2_stock_render[s]*100,1,0)+"%",bx+bw/2,by+13);}
  }
}

void d2DrawSparklines(float x,float y,float w,float h) {
  noStroke(); fill(255,255,255); rect(x,y,w,h,8);
  fill(24,40,74); textFont(SANS); textSize(13); textAlign(LEFT); text("Stock Trends  (last 80 ticks)",x+14,y+22);

  float slW=(w-44)/2, slH=(h-48)/3;
  for(int s=0;s<6;s++){
    int col=s%2, row=s/2;
    float sx=x+14+col*(slW+16), sy=y+34+row*(slH+7);
    noStroke(); fill(d2_stock_target[s]<0.28?color(255,242,242):color(248,250,255));
    stroke(205,215,234); strokeWeight(0.5); rect(sx,sy,slW,slH,4); noStroke();

    fill(52,72,128); textFont(SANS); textSize(10); textAlign(LEFT); text(d2_sku[s],sx+6,sy+13);
    color vc=d2_stock_target[s]>0.5?color(35,165,85):d2_stock_target[s]>0.28?color(195,135,16):color(195,45,45);
    fill(vc); textFont(MONO); textSize(12); textAlign(RIGHT); text(nf(d2_stock_target[s]*100,1,0)+"%",sx+slW-6,sy+13);

    float lx=sx+5,ly=sy+18,lw=slW-10,lh=slH-24;
    stroke(vc,200); strokeWeight(1.5); noFill();
    boolean started=false;
    for(int t=0;t<SL_LEN;t++){
      int idx=(d2_histIdx+1+t)%SL_LEN;
      float px=lx+(float)t/(SL_LEN-1)*lw;
      float py=ly+lh-d2_hist[s][idx]*lh;
      if(!started){beginShape();started=true;}
      vertex(px,py);
    }
    if(started) endShape();
    noStroke();
  }
}

void d2End(){
  lastMode=2; recapScore=d2_score; recapReorders=d2_reorders; recapStockouts=d2_stockouts;
  goTo(SCR_RECAP);
}

void recapD2() {
  float cy=126;
  float[] xs={W/2-180,W/2,W/2+180};
  String[] labs={"SCORE","REORDERS","STOCKOUTS"};
  String[] vals={str(recapScore),str(recapReorders),str(recapStockouts)};
  color[] cs={color(55,155,255),color(55,210,95),color(255,80,80)};

  for(int i=0;i<3;i++){
    noStroke(); fill(22,28,48); rect(xs[i]-78,cy,156,80,8);
    fill(cs[i]); rect(xs[i]-78,cy,156,4,8,8,0,0);
    fill(95,115,175); textFont(MONO); textSize(10); textAlign(CENTER); text(labs[i],xs[i],cy+20);
    fill(cs[i]); textSize(28); text(vals[i],xs[i],cy+58);
  }

  fill(140,160,205); textFont(SANS); textSize(12); textAlign(CENTER);
  text("FINAL STOCK LEVELS  AT  SESSION  END",W/2,cy+110);
  for(int s=0;s<6;s++){
    float sx=W/2-255+s*88;
    float bh=max(2,d2_stock_target[s]*72);
    noStroke(); color bc=d2_stock_target[s]>0.5?color(55,185,95):d2_stock_target[s]>0.28?color(252,178,38):color(252,78,78);
    fill(28,36,58); rect(sx,cy+118,72,72,3);
    fill(bc); rect(sx,cy+118+72-bh,72,bh,3);
    fill(bc); textFont(MONO); textSize(11); textAlign(CENTER);
    text(nf(d2_stock_target[s]*100,1,0)+"%",sx+36,cy+116+72-bh-5 > cy+124 ? cy+116+72-bh-5 : cy+196);
    fill(95,110,165); textFont(SANS); textSize(9); text(d2_sku[s].split(" ")[0],sx+36,cy+200);
  }
}
