// Input.pde
void warehouseKeyPressed() {
  // T: Open Terminal
if ((key == 't' || key == 'T') && gameState == ST_PLAY) {
  populateTerminalList(); // Sort the list right before opening
  gameState = ST_TERMINAL;
}
  if (gameState == ST_NAME) {
    if (key == ENTER || key == RETURN) {
      if (nameInputBuf.length() > 0) {
        playerName = nameInputBuf;
        gameState = ST_DIFF;
      }
    } else if (key == BACKSPACE) {
      if (nameInputBuf.length() > 0) nameInputBuf = nameInputBuf.substring(0, nameInputBuf.length() - 1);
    } else if (key != CODED && nameInputBuf.length() < 14 && key >= ' ' && key <= '~') {
      nameInputBuf += key;
    }
    return;
  }

  // ESC: pause
  if (key == ESC) {
    key = 0;
    if (gameState == ST_PLAY) gameState = ST_PAUSE;
    return;
  }

  if (keyCode < KD.length) KD[keyCode] = true;
  if (key >= 'a' && key <= 'z') KD[key - 32] = true;
  if (key >= 'A' && key <= 'Z') KD[key] = true;

  if (key == ' ' && gameState == ST_PLAY) interact();
  
  // R: resume from pause
  if ((key == 'r' || key == 'R') && gameState == ST_PAUSE) {
    gameState = ST_PLAY;
  }
}

void warehouseKeyReleased() {
  if (gameState == ST_NAME) return;
  if (keyCode < KD.length) KD[keyCode] = false;
  if (key >= 'a' && key <= 'z') KD[key - 32] = false;
  if (key >= 'A' && key <= 'Z') KD[key] = false;
}

void warehouseMousePressed() {
  if (gameState == ST_TERMINAL) {
  int mw = 300, mh = 360;
  int mx = MAP_X + (MAP_W - mw) / 2;
  int my = MAP_Y + (MAP_H - mh) / 2;
  
  // Check List Clicks
  int startY = my + 80;
  for (int i = 0; i < terminalList.length; i++) {
    int btnY = startY + i * 32;
    if (mouseX >= mx + 20 && mouseX <= mx + mw - 20 && mouseY >= btnY && mouseY <= btnY + 26) {
      lockOnPackage(terminalList[i]); // Search and lock on
      return;
    }
  }
  
  // Check Close Button
  int cY = my + mh - 40;
  if (mouseX >= mx + mw/2 - 50 && mouseX <= mx + mw/2 + 50 && mouseY >= cY && mouseY <= cY + 26) {
    gameState = ST_PLAY;
    return;
  }
}
  if (gameState == ST_NAME) {
    int mw = 500;
    int mh = 360;
    int mx = (width - mw) / 2;
    int my = (height - mh) / 2;
    
    int btnY = my + 258, btnH = 42, btnW = 156, gap = 24;
    int totalBtnW = btnW * 2 + gap;
    int backX = mx + (mw - totalBtnW) / 2;
    int continueX = backX + btnW + gap;

    if (mouseX >= backX && mouseX <= backX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
      exit(); // Kills the standalone app instead of loading a dead menu
      return;
    }

    if (nameInputBuf.length() > 0) {
      if (mouseX >= continueX && mouseX <= continueX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
        playerName = nameInputBuf;
        gameState = ST_DIFF;
        return;
      }
    }
  }

  if (gameState == ST_DIFF) {
    int mw = 530, mh = 430, mx = (width - mw) / 2, my = (height - mh) / 2;
    
    // Back button
    int backW = 110, backH = 30, backX = mx + 16, backY = my + mh - 42;
    if (mouseX >= backX && mouseX <= backX + backW && mouseY >= backY && mouseY <= backY + backH) {
      gameState = ST_NAME;
      return;
    }

    int cardW = 148, cardH = 185, gap = 10, totalW = 3 * cardW + 2 * gap, startX = mx + (mw - totalW) / 2, cardY = my + 92;
    for (int d = 0; d < 3; d++) {
      int cx = startX + d * (cardW + gap);
      if (mouseX >= cx && mouseX <= cx + cardW && mouseY >= cardY && mouseY <= cardY + cardH) {
        difficulty = d;
        startFromShift1();
        return;
      }
    }
  }

  if (gameState == ST_PAUSE) {
    int btnW = 180, btnH = 36, btnX = (int)(MAP_X + MAP_W / 2) - btnW / 2;
    int r1y = (int)(MAP_Y + MAP_H / 2) - 12;
    int r2y = r1y + btnH + 10;
    int r3y = r2y + btnH + 10;
    int r4y = r3y + btnH + 10;

    // Resume
    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= r1y && mouseY <= r1y + btnH) {
      gameState = ST_PLAY; return;
    }
    // Restart
    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= r2y && mouseY <= r2y + btnH) {
      startFromShift1(); return;
    }
    // Change Difficulty
    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= r3y && mouseY <= r3y + btnH) {
      gameState = ST_DIFF; return;
    }
    // Main Menu
    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= r4y && mouseY <= r4y + btnH) {
      returnToWarehouseMain(); return;
    }
    
    // --- Toggle A.I. Path Click ---
    int r5y = r4y + btnH + 15;
    if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= r5y - 4 && mouseY <= r5y + 26) {
      showPath = !showPath; // Flip the boolean
      return;
    }
  }

  // Shift summary modal
  if (gameState == ST_SHIFTWIN) {
    int outcome = shiftOutcome[currentShift - 1];
    int mw = 340, mh = 290, mx = MAP_X + (MAP_W - mw) / 2 - 18, my = MAP_Y + (MAP_H - mh) / 2;

    if (outcome < 0) {
      int btnW = 96, btnH = 34, gap = 10;
      int totalW = btnW * 3 + gap * 2;
      int btnY = my + mh - 50;
      int btn1X = mx + (mw - totalW) / 2;
      int btn2X = btn1X + btnW + gap;
      int btn3X = btn2X + btnW + gap;
      
      // Try Again
      if (mouseX >= btn1X && mouseX <= btn1X + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
        startFromShift1();
        return;
      }
      // Change Difficulty
      if (mouseX >= btn2X && mouseX <= btn2X + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
        gameState = ST_DIFF;
        return;
      }
      // Main Menu
      if (mouseX >= btn3X && mouseX <= btn3X + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
        returnToWarehouseMain();
        return;
      }
    } else {
      int btnW = 210, btnH = 34, btnX = mx + (mw - btnW) / 2, btnY = my + mh - 88;
      if (mouseX >= btnX && mouseX <= btnX + btnW && mouseY >= btnY && mouseY <= btnY + btnH) {
        if (currentShift < TOTAL_SHIFTS) {
          currentShift++;
          initShift();
          gameState = ST_PLAY;
        } else {
          gameState = ST_RESULTS;
        }
        return;
      }
      int sbW = 96, sbH = 34, gap = 10;
      int totalSW = sbW * 3 + gap * 2;
      int sb1X = mx + (mw - totalSW) / 2;
      int sb2X = sb1X + sbW + gap;
      int sb3X = sb2X + sbW + gap;
      int sbY = my + mh - 50;
      
      if (mouseX >= sb1X && mouseX <= sb1X + sbW && mouseY >= sbY && mouseY <= sbY + sbH) {
        startFromShift1(); 
        return;
      }
      if (mouseX >= sb2X && mouseX <= sb2X + sbW && mouseY >= sbY && mouseY <= sbY + sbH) {
        gameState = ST_DIFF; 
        return;
      }
      if (mouseX >= sb3X && mouseX <= sb3X + sbW && mouseY >= sbY && mouseY <= sbY + sbH) {
        returnToWarehouseMain(); 
        return;
      }
    }
  }

  if (gameState == ST_RESULTS) {
    int mw = 570, mh = 480, mx = (WIN_W - mw) / 2, my = (WIN_H - mh) / 2, bh = 34, btnY = my + mh - 46;
    int b1w = 150, b2w = 170, b3w = 150, gap = 10;
    int totalBW = b1w + b2w + b3w + gap * 2;
    int b1x = mx + (mw - totalBW) / 2;
    int b2x = b1x + b1w + gap;
    int b3x = b2x + b2w + gap;

    // Play Again
    if (mouseX >= b1x && mouseX <= b1x + b1w && mouseY >= btnY && mouseY <= btnY + bh) {
      startFromShift1();
      return;
    }
    // Change Difficulty
    if (mouseX >= b2x && mouseX <= b2x + b2w && mouseY >= btnY && mouseY <= btnY + bh) {
      gameState = ST_DIFF;
      return;
    }
    // Main Menu
    if (mouseX >= b3x && mouseX <= b3x + b3w && mouseY >= btnY && mouseY <= btnY + bh) {
      returnToWarehouseMain();
      return;
    }
  }
}
