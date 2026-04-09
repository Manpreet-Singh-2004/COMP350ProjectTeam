
void updateGame() {
  if (shiftResolved) return;

  timeLeft -= 1.0 / 60.0;
  if (timeLeft <= 0) {
    timeLeft = 0;
    resolveShift("SHIFT TIMER ENDED");
    return;
  }

  sprinting = KD[SHIFT] && stamina > 0;
  stamina   = sprinting ? max(0, stamina - 0.55) : min(maxStam, stamina + 0.22);

  float spd = sprinting ? PSPEED * 1.9 : PSPEED;

  if (!pMoving) {
    int nx = pgx, ny = pgy;
    if      (KD['W'] || KD[UP])    ny--;
    else if (KD['S'] || KD[DOWN])  ny++;
    else if (KD['A'] || KD[LEFT])  nx--;
    else if (KD['D'] || KD[RIGHT]) nx++;

    if ((nx != pgx || ny != pgy) && validCell(nx, ny)) {
      pgx = nx;
      pgy = ny;
      tpx = MAP_X + 2 + pgx * CELL_W + CELL_W / 2;
      tpy = MAP_Y + 2 + pgy * CELL_H + CELL_H / 2;
      pMoving = true;
    }
  }

  if (pMoving) {
    px = lerp(px, tpx, spd / CELL_W);
    py = lerp(py, tpy, spd / CELL_H);
    if (dist(px, py, tpx, tpy) < 1.2) {
      px = tpx;
      py = tpy;
      pMoving = false;
    }
  }

  moveLogTimer++;
  if (moveLogTimer >= MOVE_LOG_INTERVAL) {
    moveLogTimer = 0;
    movementLog.add(new float[]{ pgx, pgy, px, py });
  }

  for (int i = 0; i < N_PKG; i++) {
    if (pkgDead[i] || pkgPickedUp[i]) continue;

    pkgTimer[i] -= 1.0 / 60.0;
    if (pkgTimer[i] <= 0) {
      pkgDead[i]    = true;
      pkgSpoiled[i] = true;
      combo = 0;
      lives--;
      flash(RED_C);
      toast("SPOILED: " + pkgLabel[i] + "!", MAP_X + pkgGX[i] * CELL_W, MAP_Y + pkgGY[i] * CELL_H, RED_C);
      alerts.add(new SpoilAlert(pkgLabel[i] + " spoiled!"));

      if (lives <= 0) {
        resolveShift("ALL LIVES LOST");
        return;
      }
    }
  }

  updateAI();

  for (int i = alerts.size() - 1; i >= 0; i--) {
    alerts.get(i).update();
    if (alerts.get(i).dead()) alerts.remove(i);
  }

  deliveries   = 0;
  aiDeliveries = 0;
  for (int z = 0; z < 4; z++) {
    deliveries   += zoneDeliveries[z];
    aiDeliveries += aiZoneDeliveries[z];
  }

  int resolvedPackages = deliveries + aiDeliveries;
  for (int i = 0; i < N_PKG; i++) {
    if (pkgSpoiled[i]) resolvedPackages++;
    else if (pkgPickedUp[i] && !pkgDead[i]) resolvedPackages++;
  }

  if (!shiftResolved && resolvedPackages >= N_PKG) {
    resolveShift("ALL PACKAGES RESOLVED");
  }
}


void updateAI() {
  aiTimer--;

  if (aiTimer > 0) {
    ax = lerp(ax, tax, ASPEED / CELL_W);
    ay = lerp(ay, tay, ASPEED / CELL_H);
    if (dist(ax, ay, tax, tay) < 1.2) {
      ax = tax;
      ay = tay;
      aMoving = false;
    }
    return;
  }

  aiTimer = DIFF_AI_INTERVAL[difficulty];

  if (!aMoving) {
    if (aCarrying >= 0) {
      int z          = pkgZone[aCarrying];
      int[] dropCell = zoneDropCell(z);
      aiStep(dropCell[0], dropCell[1]);

      if (inZone(agx, agy, z)) {
        int pts = 100;
        aiScore += pts;
        aiZoneDeliveries[z]++;
        aiDeliveries++;
        pkgDead[aCarrying]    = true;
        pkgPickedUp[aCarrying]= true;
        toast("RIVAL +" + pts + " : " + pkgLabel[aCarrying], ax, ay - 24, AI_COL);
        flash(color(130, 30, 30));
        aCarrying = -1;
      }
    } else {
      int   best = -1;
      float bd   = 9999;

      for (int i = 0; i < N_PKG; i++) {
        if (!pkgDead[i] && !pkgPickedUp[i]) {
          float d = dist(agx, agy, pkgGX[i], pkgGY[i]);
          if (d < bd) { bd = d; best = i; }
        }
      }

      if (best >= 0) {
        aiStep(pkgGX[best], pkgGY[best]);
        if (agx == pkgGX[best] && agy == pkgGY[best]) {
          aCarrying       = best;
          pkgPickedUp[best] = true;
        }
      }
    }
  }

  ax = lerp(ax, tax, ASPEED / CELL_W);
  ay = lerp(ay, tay, ASPEED / CELL_H);
  if (dist(ax, ay, tax, tay) < 1.2) {
    ax = tax;
    ay = tay;
    aMoving = false;
  }
}

void interact() {
  if (gameState != ST_PLAY || shiftResolved) return;

  if (pCarrying == -1) {
    for (int i = 0; i < N_PKG; i++) {
      if (!pkgDead[i] && !pkgPickedUp[i] && pgx == pkgGX[i] && pgy == pkgGY[i]) {
        pCarrying       = i;
        pkgPickedUp[i]  = true;
        toast("Picked: " + pkgLabel[i], px, py - 20, CYAN_C);
        return;
      }
    }

    for (int i = 0; i < N_PKG; i++) {
      if (!pkgDead[i] && !pkgPickedUp[i] && abs(pgx - pkgGX[i]) <= 1 && abs(pgy - pkgGY[i]) <= 1) {
        pCarrying       = i;
        pkgPickedUp[i]  = true;
        toast("Picked: " + pkgLabel[i], px, py - 20, CYAN_C);
        return;
      }
    }
  } else {
    int z = pkgZone[pCarrying];
    if (inZone(pgx, pgy, z)) {
      combo++;
      int pts = 100 + max(0, combo - 1) * 50;
      score += pts;
      zoneDeliveries[z]++;

      deliveries = 0;
      for (int i = 0; i < 4; i++) deliveries += zoneDeliveries[i];

      pkgDead[pCarrying]    = true;
      pkgPickedUp[pCarrying]= true;
      flash(GRN);
      toast("+" + pts + (combo > 1 ? " x" + combo + " COMBO!" : ""), px, py - 28, GRN);
      pCarrying = -1;
    } else {
      pkgGX[pCarrying]    = pgx;
      pkgGY[pCarrying]    = pgy;
      pkgPickedUp[pCarrying] = false;
      toast("Dropped", px, py - 20, TXT_DIM);
      pCarrying = -1;
    }
  }
}
