// =============================================================
// FILE 3: UI_Elements.pde (DYNAMIC FEEDBACK SYSTEM)
// =============================================================

// Global list to track active floating text
ArrayList<FloatMsg> messages = new ArrayList<FloatMsg>();

class FloatMsg {
  float x, y;
  float vy;
  float alpha;
  String txt;
  color col;

  FloatMsg(float x, float y, String txt, color col) {
    this.x = x; 
    this.y = y;
    this.txt = txt; 
    this.col = col;
    this.vy = -1.5; // Negative velocity so it drifts upwards
    this.alpha = 255;
  }

  void update() {
    y += vy;
    alpha -= 3.5; // Controls how fast the text fades out
  }

  void display() {
    if (alpha <= 0) return;
    
    // Draw text with the fading alpha channel
    fill(col, alpha);
    textFont(MONO);
    textSize(14);
    textAlign(CENTER);
    text(txt, x, y);
  }
}

// Helper function to easily trigger a new message from anywhere in the codebase
void spawnMsg(float x, float y, String txt, color col) {
  messages.add(new FloatMsg(x, y, txt, col));
}

// Called at the very end of your draw loop so text always renders ON TOP of the UI
void updateAndDrawMessages() {
  // MUST loop backwards to safely remove dead objects
  for (int i = messages.size() - 1; i >= 0; i--) {
    FloatMsg m = messages.get(i);
    m.update();
    m.display();
    
    // Memory management: purge objects once they are invisible
    if (m.alpha <= 0) {
      messages.remove(i);
    }
  }
}
