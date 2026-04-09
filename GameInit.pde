
ArrayList<float[]> movementLog     = new ArrayList<float[]>();
int                moveLogTimer    = 0;
final int          MOVE_LOG_INTERVAL = 30;   

void initShift() {
  searchedPkgIndex = -1;
  shiftSecs  = DIFF_SHIFT_SECS[difficulty];
  timeLeft   = shiftSecs;
  score      = 0;
  aiScore    = 0;
  deliveries = 0;
  aiDeliveries = 0;
  combo      = 0;
  lives      = DIFF_LIVES[difficulty];
  stamina    = maxStam;
  pCarrying  = -1;
  aCarrying  = -1;
  lossReason = "";
  shiftEndReason = "";
  shiftResolved = false;
  ASPEED     = DIFF_AI_SPEED[difficulty] * SHIFT_AI_SCALE[currentShift-1];

  for (int i = 0; i < 4; i++) {
    zoneDeliveries[i]   = 0;
    aiZoneDeliveries[i] = 0;
  }

  toasts.clear();
  alerts.clear();
  flashAlpha = 0;

  pgx = 10; pgy = 8;
  agx = 11; agy = 8;
  snapPlayer();
  snapAI();

  for (int i = 0; i < N_PKG; i++) {
    pkgDead[i]    = false;
    pkgSpoiled[i] = false;
    pkgPickedUp[i]= false;
  }
  spawnPackages();

  // Reset movement log for this shift
  movementLog.clear();
  moveLogTimer = 0;
}

void spawnPackages() {
  ArrayList<Integer> pool = new ArrayList<Integer>();
  for (int i = 0; i < SPAWN.length; i++) pool.add(i);

  String[] names = {"Milk","IceC","Brea","Chee","Pizz","Lett","Yogu","Cake","Spin","Fish","Beet","Buttr"};
  float pMin = DIFF_PKG_MIN[difficulty], pMax = DIFF_PKG_MAX[difficulty];

  for (int i = 0; i < N_PKG; i++) {
    int idx     = (int)random(pool.size());
    pkgGX[i]   = SPAWN[pool.get(idx)][0];
    pkgGY[i]   = SPAWN[pool.get(idx)][1];
    pkgZone[i] = i % 4;
    pkgLabel[i]= names[(i*3 + int(random(3))) % names.length];
    pkgMaxTimer[i] = random(pMin, pMax);
    pkgTimer[i]    = pkgMaxTimer[i];
    pool.remove(idx);
  }
}

void snapPlayer() {
  px  = MAP_X + 2 + pgx * CELL_W + CELL_W / 2;
  py  = MAP_Y + 2 + pgy * CELL_H + CELL_H / 2;
  tpx = px;
  tpy = py;
}

void snapAI() {
  ax  = MAP_X + 2 + agx * CELL_W + CELL_W / 2;
  ay  = MAP_Y + 2 + agy * CELL_H + CELL_H / 2;
  tax = ax;
  tay = ay;
}

void resolveShift(String reason) {
  if (shiftResolved) return;

  shiftResolved  = true;
  shiftEndReason = reason;

  int idx = currentShift - 1;
  shiftPlayerScore[idx] = score;
  shiftPlayerDel[idx]   = deliveries;
  shiftAiScore[idx]     = aiScore;
  shiftAiDel[idx]       = aiDeliveries;

  if      (score > aiScore) shiftOutcome[idx] =  1;
  else if (score < aiScore) shiftOutcome[idx] = -1;
  else                       shiftOutcome[idx] =  0;

  // Sort movement log and export to file
  sortAndExportMovement(currentShift);

  gameState = ST_SHIFTWIN;
}

void startFromShift1() {
  currentShift = 1;
  for (int s = 0; s < TOTAL_SHIFTS; s++) {
    shiftPlayerScore[s] = 0;
    shiftPlayerDel[s]   = 0;
    shiftAiScore[s]     = 0;
    shiftAiDel[s]       = 0;
    shiftOutcome[s]     = 0;
  }
  initShift();
  gameState = ST_PLAY;
}

void sortAndExportMovement(int shiftNum) {
  int n = movementLog.size();
  if (n == 0) return;

  float[][] arr = new float[n][4];
  for (int i = 0; i < n; i++) arr[i] = movementLog.get(i).clone();

  float centerGX = COLS / 2.0;
  float centerGY = ROWS / 2.0;

  for (int i = 1; i < n; i++) {
    float[] key     = arr[i];
    float   keyDist = dist(key[0], key[1], centerGX, centerGY);
    int j = i - 1;
    while (j >= 0 && dist(arr[j][0], arr[j][1], centerGX, centerGY) > keyDist) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = key;
  }

  PrintWriter pw = createWriter("movement_shift" + shiftNum + ".txt");
  pw.println("=== Warehouse Navigator — Player Movement Log ===");
  pw.println("Player    : " + playerName);
  pw.println("Difficulty: " + DIFF_NAMES[difficulty]);
  pw.println("Shift     : " + shiftNum + " / " + TOTAL_SHIFTS);
  pw.println("Grid ctr  : (" + nf(centerGX, 0, 1) + ", " + nf(centerGY, 0, 1) + ")");
  pw.println("Sorted by : Euclidean distance from grid centre (asc)");
  pw.println("Total pts : " + n);
  pw.println("");
  pw.println("Rank\tGridX\tGridY\tWorldX\t\tWorldY\t\tDist");
  pw.println("----\t-----\t-----\t------\t\t------\t\t----");

  for (int i = 0; i < n; i++) {
    float d = dist(arr[i][0], arr[i][1], centerGX, centerGY);
    pw.println(
      (i + 1) + "\t" +
      nf(arr[i][0], 0, 0) + "\t" +
      nf(arr[i][1], 0, 0) + "\t" +
      nf(arr[i][2], 0, 1) + "\t\t" +
      nf(arr[i][3], 0, 1) + "\t\t" +
      nf(d, 0, 2)
    );
  }

  pw.println("");
  pw.println("=== End of log ===");
  pw.flush();
  pw.close();
}
