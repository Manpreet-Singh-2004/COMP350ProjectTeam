void drawMapBG() {
  fill(MAP_BG);
  stroke(BORDER_C);
  strokeWeight(1.5);
  rect(MAP_X, MAP_Y, MAP_W, MAP_H, 5);
  for (int z = 0; z < 4; z++) drawZone(z);
}

void drawZone(int z) {
  int[] r = ZONE_RECT[z];
  float x = MAP_X + 2 + r[0] * CELL_W, y = MAP_Y + 2 + r[1] * CELL_H;
  float w = r[2] * CELL_W, h = r[3] * CELL_H;
  fill(ZONE_BG[z]);
  stroke(ZONE_BDR[z]);
  strokeWeight(1.5);
  rect(x, y, w, h, 3);
  textFont(mono);
  textSize(10);
  textAlign(CENTER, TOP);
  fill(red(ZONE_BDR[z]), green(ZONE_BDR[z]), blue(ZONE_BDR[z]), 170);
  noStroke();
  text(ZONE_NAME[z], x + w / 2, y + 6);

  fill(SHELF_C);
  noStroke();
  int shX = (int)(x + 10), shW = (int)(w - 20);
  for (int i = 0; i < 4; i++) {
    int sy = (int)(y + 22 + i * ((h - 30) / 4));
    if (sy + 9 > y + h - 5) break;
    rect(shX, sy, shW, 9, 2);
  }
}

void drawPackages() {
  for (int i = 0; i < N_PKG; i++) {
    if (pkgDead[i] || pkgPickedUp[i]) continue;
    float px2 = MAP_X + 2 + pkgGX[i] * CELL_W + CELL_W / 2;
    float py2 = MAP_Y + 2 + pkgGY[i] * CELL_H + CELL_H / 2;
    color c   = ZONE_DOT[pkgZone[i]];
    float ratio = pkgTimer[i] / pkgMaxTimer[i];
    color ring  = ratio > 0.5 ? GRN : ratio > 0.25 ? YLW : RED_C;
    textFont(mono);
    textSize(10);
    int bw = (int)textWidth(pkgLabel[i]) + 14, bh = 18;
    fill(red(c) * 0.2, green(c) * 0.2, blue(c) * 0.2);
    stroke(c);
    strokeWeight(1.2);
    rect(px2 - bw / 2, py2 - bh / 2, bw, bh, 3);
    fill(c);
    noStroke();
    textAlign(CENTER, CENTER);
    text(pkgLabel[i], px2, py2);
    noFill();
    stroke(ring);
    strokeWeight(2);
    arc(px2, py2 + bh / 2 + 6, 10, 10, -HALF_PI, -HALF_PI + TWO_PI * ratio);
    
        // Draw massive GPS pulsing ring if this is the tracked package
    if (i == searchedPkgIndex) {
      noFill();
      stroke(CYAN_C, 150 + 100 * sin(frameCount * 0.15)); // Pulsing alpha
      strokeWeight(3);
      ellipse(px2, py2, 40 + 10 * sin(frameCount * 0.1), 40 + 10 * sin(frameCount * 0.1));
      
      // Draw a pointer line from the player to the package
      stroke(CYAN_C, 80);
      strokeWeight(1);
      line(px, py, px2, py2);
    }
  }
}

// ── Characters ───────────────────────────────────────────────
void drawBlueChar(float cx, float cy, boolean carrying, boolean sprint) {
  float r = 14;
  noStroke();
  fill(0, 50);
  ellipse(cx, cy + r + 3, r * 1.5, r * 0.5);

  if (sprint) {
    for (int g = 0; g < 3; g++) {
      noFill();
      stroke(YLW, 40 - g * 12);
      strokeWeight(5 - g * 1.5);
      ellipse(cx, cy, r * 2 + 6 + g * 4, r * 2 + 6 + g * 4);
    }
  }

  for (int g = 0; g < 3; g++) {
    noFill();
    stroke(PLAYER_COL, 30 - g * 8);
    strokeWeight(4 - g);
    ellipse(cx, cy, r * 2 + g * 3, r * 2 + g * 3);
  }

  fill(color(30, 70, 140));
  stroke(PLAYER_COL);
  strokeWeight(1.5);
  ellipse(cx, cy - r * 0.1, r * 2, r * 1.8);

  fill(color(100, 180, 255, 180));
  noStroke();
  arc(cx, cy - r * 0.2, r * 1.4, r * 1.1, PI + 0.4, TWO_PI - 0.4);

  fill(255, 255, 255, 80);
  noStroke();
  ellipse(cx - r * 0.15, cy - r * 0.45, r * 0.35, r * 0.2);

  stroke(PLAYER_COL);
  strokeWeight(1.5);
  noFill();
  line(cx, cy - r, cx + r * 0.3, cy - r * 1.4);
  fill(PLAYER_COL);
  noStroke();
  ellipse(cx + r * 0.3, cy - r * 1.4, r * 0.22, r * 0.22);

  fill(color(20, 50, 100));
  stroke(PLAYER_COL);
  strokeWeight(1);
  rect(cx - r - 3, cy - r * 0.3, 5, r * 0.6, 2);
  rect(cx + r - 2, cy - r * 0.3, 5, r * 0.6, 2);

  textFont(mono);
  textSize(7);
  textAlign(CENTER, CENTER);
  fill(color(100, 180, 255, 200));
  noStroke();
  String tag = playerName.length() > 0 ? playerName.substring(0, min(4, playerName.length())) : "YOU";
  text(tag.toUpperCase(), cx, cy + r * 0.35);
}

void drawRedChar(float cx, float cy, boolean carrying) {
  float r = 14;
  noStroke();
  fill(0, 50);
  ellipse(cx, cy + r + 3, r * 1.5, r * 0.5);

  for (int g = 0; g < 3; g++) {
    noFill();
    stroke(AI_COL, 30 - g * 8);
    strokeWeight(4 - g);
    ellipse(cx, cy, r * 2 + g * 3, r * 2 + g * 3);
  }

  fill(color(120, 25, 25));
  stroke(AI_COL);
  strokeWeight(1.5);
  ellipse(cx, cy, r * 2, r * 1.8);

  fill(color(255, 60, 60, 200));
  noStroke();
  rect(cx - r * 0.55, cy - r * 0.3, r * 1.1, r * 0.22, 3);

  fill(255, 80, 80, 60);
  noStroke();
  ellipse(cx - r * 0.1, cy - r * 0.22, r * 0.4, r * 0.12);

  stroke(AI_COL);
  strokeWeight(1.5);
  noFill();
  line(cx - r * 0.3, cy - r, cx - r * 0.6, cy - r * 1.5);
  line(cx + r * 0.3, cy - r, cx + r * 0.6, cy - r * 1.5);

  fill(AI_COL);
  noStroke();
  triangle(cx - r * 0.6, cy - r * 1.5, cx - r * 0.8, cy - r * 1.3, cx - r * 0.4, cy - r * 1.3);
  triangle(cx + r * 0.6, cy - r * 1.5, cx + r * 0.8, cy - r * 1.3, cx + r * 0.4, cy - r * 1.3);

  fill(color(100, 20, 20));
  stroke(AI_COL);
  strokeWeight(1);
  rect(cx - r - 4, cy - r * 0.5, 7, r * 0.8, 2);
  rect(cx + r - 3, cy - r * 0.5, 7, r * 0.8, 2);

  textFont(mono);
  textSize(7);
  textAlign(CENTER, CENTER);
  fill(color(255, 100, 100, 200));
  noStroke();
  text("A.I.", cx, cy + r * 0.35);
}

void drawPlayerChar() {
  txStack.push(px, py, 1.0, 1.0);

  drawBlueChar(px, py, pCarrying >= 0, sprinting);

  if (pCarrying >= 0) {
    float[] parent = txStack.peek();
    float childX   = parent[0];         
    float childY   = parent[1] - 36;     

    txStack.push(childX, childY, 1.0, 1.0);
    float[] child = txStack.peek();

    color zc = ZONE_DOT[pkgZone[pCarrying]];
    textFont(mono);
    textSize(9);
    int tw = (int)textWidth(pkgLabel[pCarrying]) + 10;

    fill(red(zc) * 0.3, green(zc) * 0.3, blue(zc) * 0.3);
    stroke(zc);
    strokeWeight(1);
    rect(child[0] - tw / 2, child[1], tw, 14, 3);
    fill(zc);
    noStroke();
    textAlign(CENTER, CENTER);
    text(pkgLabel[pCarrying], child[0], child[1] + 7);

    txStack.pop();  
  }

  txStack.pop();    
}

void drawAIChar() {
  
  // --- Draw the FULL A.I. Target Path if toggled ON ---
  if (showPath && gameState == ST_PLAY && aiCurrentPath.size() > 0) {
    stroke(AI_COL, 120);
    strokeWeight(2);
    
    float startX = ax;
    float startY = ay;
    
    // The path list was built backwards (destination -> A.I.), 
    // so we iterate backwards to draw from A.I. -> destination
    for (int i = aiCurrentPath.size() - 1; i >= 0; i--) {
      int[] pt = aiCurrentPath.get(i);
      float nodeX = MAP_X + 2 + pt[0] * CELL_W + CELL_W / 2;
      float nodeY = MAP_Y + 2 + pt[1] * CELL_H + CELL_H / 2;
      
      line(startX, startY, nodeX, nodeY);
      startX = nodeX;
      startY = nodeY;
    }
    
    // Draw the pulse ring on the absolute final target
    int[] finalPt = aiCurrentPath.get(0); 
    float fx = MAP_X + 2 + finalPt[0] * CELL_W + CELL_W / 2;
    float fy = MAP_Y + 2 + finalPt[1] * CELL_H + CELL_H / 2;
    noFill();
    ellipse(fx, fy, 12 + 4 * sin(frameCount * 0.2), 12 + 4 * sin(frameCount * 0.2));
  }
  
  txStack.push(ax, ay, 1.0, 1.0);

  drawRedChar(ax, ay, aCarrying >= 0);

  if (aCarrying >= 0) {
    float[] parent = txStack.peek();
    float childX   = parent[0];
    float childY   = parent[1] - 36;

    txStack.push(childX, childY, 1.0, 1.0);
    float[] child = txStack.peek();

    color zc = ZONE_DOT[pkgZone[aCarrying]];
    textFont(mono);
    textSize(9);
    int tw = (int)textWidth(pkgLabel[aCarrying]) + 10;

    fill(red(zc) * 0.3, green(zc) * 0.3, blue(zc) * 0.3);
    stroke(zc);
    strokeWeight(1);
    rect(child[0] - tw / 2, child[1], tw, 14, 3);
    fill(zc);
    noStroke();
    textAlign(CENTER, CENTER);
    text(pkgLabel[aCarrying], child[0], child[1] + 7);

    txStack.pop();   
  }

  txStack.pop();    
}

void drawHUDBar() {
  int bx = MAP_X + 1, by = MAP_Y + MAP_H - HUD_H - 1, bw = MAP_W - 2, bh = HUD_H;
  fill(color(18, 25, 33));
  stroke(BORDER_C);
  strokeWeight(1);
  rect(bx, by, bw, bh, 0, 0, 4, 4);

  textFont(nameFont);
  textSize(11);
  textAlign(LEFT, CENTER);
  fill(PLAYER_COL, 200);
  noStroke();
  text("Hi, " + playerName + "!", bx + 8, by + bh / 2);

  textFont(mono);
  textSize(10);
  fill(TXT_DIM);
  text("WASD=Move",     bx + 130, by + bh / 2);
  text("SPACE=Pick/Drop", bx + 228, by + bh / 2);
  text("SHIFT=Sprint",  bx + 380, by + bh / 2);
  text("ESC=Pause",     bx + 474, by + bh / 2);

  if (timeLeft < 20 && gameState == ST_PLAY) {
    fill(RED_C, 100 + 80 * sin(frameCount * 0.2));
    textAlign(RIGHT, CENTER);
    text("⚠ " + nf((int)timeLeft, 2) + "s", bx + bw - 8, by + bh / 2);
  }
}

void drawFloatToasts() {
  for (int i = toasts.size() - 1; i >= 0; i--) {
    toasts.get(i).update();
    toasts.get(i).draw();
    if (toasts.get(i).dead()) toasts.remove(i);
  }
}

void drawFlash() {
  if (flashAlpha > 0) {
    noStroke();
    fill(red(flashCol), green(flashCol), blue(flashCol), flashAlpha);
    rect(MAP_X, MAP_Y, MAP_W, MAP_H);
    flashAlpha = max(0, flashAlpha - 1.8);
  }
}

void drawSidebar() {
  int x = SB_X, w = SB_W, y = SB_Y + 2;

  int p1h = 216;
  panel(x, y, w, p1h);
  textFont(mono);
  textSize(9);
  textAlign(LEFT, TOP);
  fill(TXT_DIM);
  noStroke();
  text("WAREHOUSE NAVIGATOR", x + 8, y + 6);
  divLine(x, y + 20, w);

  textFont(nameFont);
  textSize(11);
  textAlign(LEFT, TOP);
  fill(PLAYER_COL);
  noStroke();
  text("Hi, " + playerName + "!", x + 8, y + 26);
  divLine(x, y + 44, w);

  sbRow(x, y + 50,  w, "Shift", currentShift + "/" + TOTAL_SHIFTS);
  sbRow(x, y + 68,  w, "Score", score + " / AI " + aiScore);
  sbRow(x, y + 86,  w, "Lives", hearts(lives));
  sbRow(x, y + 104, w, "Time",  nf((int)timeLeft, 3) + "s");
  sbRow(x, y + 122, w, "Del",   deliveries + " / AI " + aiDeliveries);

  textFont(mono);
  textSize(11);
  textAlign(LEFT, TOP);
  fill(TXT_MED);
  noStroke();
  text("Combo", x + 8, y + 142);
  if (combo > 0) {
    fill(YLW);
    textAlign(RIGHT, TOP);
    text("x" + combo, x + w - 8, y + 142);
  }

  float tr = timeLeft / shiftSecs;
  color tc  = tr > 0.5 ? GRN : tr > 0.25 ? YLW : RED_C;
  fill(BORDER_C);
  noStroke();
  rect(x + 8, y + 160, w - 16, 8, 3);
  fill(tc);
  rect(x + 8, y + 160, (w - 16) * tr, 8, 3);

  textFont(mono);
  textSize(9);
  textAlign(LEFT, TOP);
  fill(TXT_DIM);
  noStroke();
  text("SHIFTS", x + 8, y + 180);

  for (int s = 0; s < TOTAL_SHIFTS; s++) {
    color sc2;
    if (s + 1 < currentShift)       sc2 = shiftOutcome[s] > 0 ? GRN : (shiftOutcome[s] < 0 ? RED_C : YLW);
    else if (s + 1 == currentShift) sc2 = YLW;
    else                             sc2 = BORDER_C;

    fill(sc2);
    noStroke();
    ellipse(x + 42 + s * 22, y + 190, 12, 12);
    textFont(mono);
    textSize(8);
    textAlign(CENTER, CENTER);
    fill(BG);
    noStroke();
    text(str(s + 1), x + 42 + s * 22, y + 190);
  }

  int p2y = y + p1h + 6, p2h = 56;
  panel(x, p2y, w, p2h);
  panHead(x, p2y, w, "CARRYING");
  textFont(mono);
  textSize(11);
  textAlign(LEFT, TOP);
  if (pCarrying >= 0) {
    fill(ZONE_DOT[pkgZone[pCarrying]]);
    noStroke();
    text(pkgLabel[pCarrying] + " → " + ZONE_NAME[pkgZone[pCarrying]], x + 8, p2y + 30);
  } else {
    fill(TXT_DIM);
    noStroke();
    text("— empty —", x + 8, p2y + 30);
  }

  int p3y = p2y + p2h + 6, p3h = 108;
  panel(x, p3y, w, p3h);
  panHead(x, p3y, w, "AISLE ZONES");
  for (int z = 0; z < 4; z++) {
    fill(ZONE_DOT[z]);
    noStroke();
    rect(x + 8, p3y + 26 + z * 20 + 3, 10, 10, 2);
    textFont(mono);
    textSize(11);
    textAlign(LEFT, TOP);
    fill(TXT_MED);
    text(ZONE_NAME[z], x + 22, p3y + 26 + z * 20);
  }

  int p4y = p3y + p3h + 6, p4h = 106;
  panel(x, p4y, w, p4h);
  panHead(x, p4y, w, "CONTROLS");
  ctrlRow(x, p4y + 26, w, "W A S D", "or Arrow keys");
  ctrlRow(x, p4y + 46, w, "SPACE",   "Pick up / Drop");
  ctrlRow(x, p4y + 66, w, "SHIFT",   "Sprint (limited)");
  ctrlRow(x, p4y + 86, w, "ESC / R", "Pause / Resume");

  int p5y = p4y + p4h + 6, p5h = 58;
  panel(x, p5y, w, p5h);
  panHead(x, p5y, w, "SPRINT");
  textFont(mono);
  textSize(11);
  textAlign(LEFT, TOP);
  fill(TXT_MED);
  noStroke();
  text("Stamina: " + nf(stamina, 0, 0) + "%", x + 8, p5y + 26);

  fill(color(20, 30, 45));
  noStroke();
  rect(x + 8, p5y + 42, w - 16, 8, 3);
  color sc3 = stamina > 50 ? BLUE_B : stamina > 25 ? YLW : RED_C;
  fill(sc3);
  rect(x + 8, p5y + 42, (w - 16) * (stamina / maxStam), 8, 3);

  if (alerts.size() > 0) {
    int p6y = p5y + p5h + 6, p6h = 50;
    SpoilAlert al = alerts.get(alerts.size() - 1);
    fill(color(42, 10, 10));
    stroke(RED_C);
    strokeWeight(1.2);
    rect(x, p6y, w, p6h, 4);
    textFont(mono);
    textSize(9);
    textAlign(LEFT, TOP);
    fill(RED_C);
    noStroke();
    text("⚠ SPOILAGE", x + 8, p6y + 6);
    divLine(x, p6y + 18, w);
    textSize(10);
    fill(ORG);
    text(al.msg, x + 8, p6y + 26);
  }
}
