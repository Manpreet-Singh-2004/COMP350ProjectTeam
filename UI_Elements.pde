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
    this.vy = -1.5; 
    this.alpha = 255;
  }

  void update() {
    y += vy;
    alpha -= 3.5; 
  }

  void display() {
    if (alpha <= 0) return;
    
    fill(col, alpha);
    textFont(MONO);
    textSize(14);
    textAlign(CENTER);
    text(txt, x, y);
  }
}

void spawnMsg(float x, float y, String txt, color col) {
  messages.add(new FloatMsg(x, y, txt, col));
}

void updateAndDrawMessages() {
  for (int i = messages.size() - 1; i >= 0; i--) {
    FloatMsg m = messages.get(i);
    m.update();
    m.display();

    if (m.alpha <= 0) {
      messages.remove(i);
    }
  }
}
