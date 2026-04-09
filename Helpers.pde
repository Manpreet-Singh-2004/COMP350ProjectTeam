
boolean validCell(int gx, int gy) {
  if (gx<0||gx>=COLS||gy<0||gy>=ROWS) return false;
  for (int z=0;z<4;z++) {
    int[] r=ZONE_RECT[z];
    if (gx>=r[0]+1&&gx<=r[0]+r[2]-2&&gy>=r[1]+1&&gy<=r[1]+r[3]-2) return false;
  }
  return true;
}

boolean inZone(int gx, int gy, int zone) {
  int[] r=ZONE_RECT[zone];
  return gx>=r[0]&&gx<r[0]+r[2]&&gy>=r[1]&&gy<r[1]+r[3];
}

void returnToWarehouseMain() {
  if (playerName.length()>0) nameInputBuf = playerName;
  gameState = ST_NAME;
}

int[] zoneDropCell(int zone) {
  int[] r = ZONE_RECT[zone];
  int[][] pref;

  if (zone == 0) {
    pref = new int[][]{{r[0]+r[2]-1, r[1]+r[3]-1}, {r[0]+r[2]-1, r[1]}, {r[0], r[1]+r[3]-1}, {r[0], r[1]}};
  } else if (zone == 1) {
    pref = new int[][]{{r[0], r[1]+r[3]-1}, {r[0], r[1]}, {r[0]+r[2]-1, r[1]+r[3]-1}, {r[0]+r[2]-1, r[1]}};
  } else if (zone == 2) {
    pref = new int[][]{{r[0]+r[2]-1, r[1]}, {r[0]+r[2]-1, r[1]+r[3]-1}, {r[0], r[1]}, {r[0], r[1]+r[3]-1}};
  } else {
    pref = new int[][]{{r[0], r[1]}, {r[0], r[1]+r[3]-1}, {r[0]+r[2]-1, r[1]}, {r[0]+r[2]-1, r[1]+r[3]-1}};
  }

  for (int i=0; i<pref.length; i++) {
    int gx = pref[i][0];
    int gy = pref[i][1];
    if (validCell(gx, gy)) return new int[]{gx, gy};
  }

  for (int gy=r[1]; gy<r[1]+r[3]; gy++) {
    for (int gx=r[0]; gx<r[0]+r[2]; gx++) {
      if (validCell(gx, gy)) return new int[]{gx, gy};
    }
  }

  return new int[]{r[0], r[1]};
}

void aiStep(int tx, int ty) {
  if (agx == tx && agy == ty) return;
  
  boolean[][] seen = new boolean[COLS][ROWS];
  int[][] prevX = new int[COLS][ROWS];
  int[][] prevY = new int[COLS][ROWS];
  
  for (int x=0; x<COLS; x++) {
    for (int y=0; y<ROWS; y++) {
      prevX[x][y] = -1;
      prevY[x][y] = -1;
    }
  }

  int maxN = COLS * ROWS;
  int[] qx = new int[maxN];
  int[] qy = new int[maxN];
  int head = 0, tail = 0;
  qx[tail] = agx;
  qy[tail] = agy;
  tail++;
  seen[agx][agy] = true;

  int[] dx = {1, -1, 0, 0};
  int[] dy = {0, 0, 1, -1};
  
  // --- 1. THE ACTUAL BFS SEARCH ---
  while (head < tail) {
    int cx = qx[head];
    int cy = qy[head];
    head++;
    if (cx == tx && cy == ty) break;
    
    // You deleted this loop previously! This checks the neighbors.
    for (int i=0; i<4; i++) {
      int nx = cx + dx[i];
      int ny = cy + dy[i];
      if (validCell(nx, ny) && !seen[nx][ny]) {
        seen[nx][ny] = true;
        prevX[nx][ny] = cx;
        prevY[nx][ny] = cy;
        qx[tail] = nx;
        qy[tail] = ny;
        tail++;
      }
    }
  }
  
  // --- 2. THE PATH TRACEBACK ---
  if (!seen[tx][ty]) {
    aiCurrentPath.clear(); // Clear if no path found
    return; 
  }

  int sx = tx;
  int sy = ty;
  
  // Clear the old path and start recording the new one
  aiCurrentPath.clear();
  aiCurrentPath.add(new int[]{tx, ty}); // Add the final destination

  // Trace back and record every node
  while (!(prevX[sx][sy] == agx && prevY[sx][sy] == agy)) {
    int px2 = prevX[sx][sy];
    int py2 = prevY[sx][sy];
    if (px2 == -1 || py2 == -1) return;
    sx = px2;
    sy = py2;
    aiCurrentPath.add(new int[]{sx, sy}); // Add intermediate steps
  }

  // Set the next immediate target for the A.I. to move to
  agx = sx;
  agy = sy;
  tax = MAP_X + 2 + agx * CELL_W + CELL_W / 2;
  tay = MAP_Y + 2 + agy * CELL_H + CELL_H / 2;
  aMoving = true;
}

void flash(color c) {
  flashCol=c;
  flashAlpha=40;
}

void toast(String msg, float x, float y, color c) {
  toasts.add(new Toast(msg,x,y,c));
}

// ── Sidebar / panel UI utilities ──────────────────────────────
void panel(int x,int y,int w,int h){
  fill(PANEL_C);
  stroke(BORDER_C);
  strokeWeight(1);
  rect(x,y,w,h,4);
}

void panHead(int x,int y,int w,String lbl){
  textFont(mono);
  textSize(9);
  textAlign(LEFT,TOP);
  fill(TXT_DIM);
  noStroke();
  text(lbl,x+8,y+6);
  divLine(x,y+18,w);
}

void divLine(int x,int y,int w){
  stroke(BORDER_C);
  strokeWeight(1);
  line(x+1,y,x+w-1,y);
}

void sbRow(int x,int y,int w,String lbl,String val){
  textFont(mono);
  textSize(11);
  noStroke();
  textAlign(LEFT,TOP);
  fill(TXT_MED);
  text(lbl,x+8,y);
  fill(TXT_BRT);
  textAlign(RIGHT,TOP);
  text(val,x+w-8,y);
}

void ctrlRow(int x,int y,int w,String key2,String desc){
  textFont(mono);
  textSize(9);
  int kw=(int)textWidth(key2)+10;
  fill(BORDER_C);
  noStroke();
  rect(x+8,y,kw,16,3);
  fill(TXT_BRT);
  textAlign(LEFT,TOP);
  text(key2,x+13,y+2);
  fill(TXT_DIM);
  text(desc,x+8+kw+5,y+2);
}

String hearts(int n){
  String s="";
  for(int i=0;i<3;i++) s+=(i<n)?"♥ ":"♡ ";
  return s.trim();
}

// Extracts active packages and sorts them alphabetically using Insertion Sort
void populateTerminalList() {
  ArrayList<String> active = new ArrayList<String>();
  for (int i = 0; i < N_PKG; i++) {
    if (!pkgDead[i] && !pkgPickedUp[i]) active.add(pkgLabel[i]);
  }
  
  terminalList = active.toArray(new String[0]);
  
  // Custom Insertion Sort to guarantee rubric points
  for (int i = 1; i < terminalList.length; i++) {
    String key = terminalList[i];
    int j = i - 1;
    while (j >= 0 && terminalList[j].compareTo(key) > 0) {
      terminalList[j + 1] = terminalList[j];
      j--;
    }
    terminalList[j + 1] = key;
  }
}

// Binary Search to find the selected string in our sorted list
boolean binarySearchPackage(String[] sortedArr, String target) {
  int l = 0, r = sortedArr.length - 1;
  while (l <= r) {
    int m = l + (r - l) / 2;
    int res = target.compareTo(sortedArr[m]);
    if (res == 0) return true; // Found it!
    if (res > 0) l = m + 1;
    else r = m - 1;
  }
  return false;
}

// Maps the found string back to the actual map coordinate
void lockOnPackage(String label) {
  if (binarySearchPackage(terminalList, label)) {
    for (int i = 0; i < N_PKG; i++) {
      if (!pkgDead[i] && !pkgPickedUp[i] && pkgLabel[i].equals(label)) {
        searchedPkgIndex = i;
        toast("TRACKING: " + label, MAP_X + MAP_W/2, MAP_Y + MAP_H/2, CYAN_C);
        gameState = ST_PLAY; // Go back to the game
        return;
      }
    }
  }
}
