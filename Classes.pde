
interface Renderable {
  void draw();
  void update();
  boolean dead();
}

abstract class GameEntity implements Renderable {
  float x, y;
  color c;

  GameEntity(float _x, float _y, color _c) {
    x = _x;
    y = _y;
    c = _c;
  }

  // Subclasses must supply a concrete draw()
  abstract void draw();
  // Concrete update() — can be overridden
  void update() {}
  // Concrete dead() — can be overridden
  boolean dead() { return false; }
}

class UIMessage extends GameEntity {
  String msg;
  float  alpha;
  float  vy;       

  UIMessage(String m, float _x, float _y, color _c) {
    super(_x, _y, _c);
    msg   = m;
    alpha = 255;
    vy    = -1.1;
  }

  void update() {
    y    += vy;
    alpha -= 4;
  }

  boolean dead() { return alpha <= 0; }

  void draw() {
    if (mono == null) return;
    textFont(mono);
    textSize(12);
    textAlign(CENTER, CENTER);
    noStroke();
    fill(red(c), green(c), blue(c), alpha);
    text(msg, x, y);
  }
}


class Toast extends UIMessage {

  Toast(String m, float _x, float _y, color _c) {
    super(m, _x, _y, _c);
  }

  void draw() {
    if (mono == null) return;
    textFont(mono);
    textSize(13);
    textAlign(CENTER, CENTER);
    noStroke();
    // Drop shadow
    fill(0, 0, 0, alpha * 0.45);
    text(msg, x + 1, y + 1);
    // Main text
    fill(red(c), green(c), blue(c), alpha);
    text(msg, x, y);
  }
}


class SpoilAlert extends GameEntity {
  String msg;
  int    life = 360;

  SpoilAlert(String m) {
    super(0, 0, color(210, 60, 60));
    msg = m;
  }

  void update()      { life--; }
  boolean dead()     { return life <= 0; }
  void draw()        { /* rendered by drawSidebar() in DrawMap.pde */ }
}


class TransformStack {
  private float[][] stack;
  private int top;

  TransformStack(int capacity) {
    stack = new float[capacity][4];
    top   = 0;
  }

  void push(float tx, float ty, float sx, float sy) {
    if (top >= stack.length) return;   // overflow guard
    stack[top][0] = tx;
    stack[top][1] = ty;
    stack[top][2] = sx;
    stack[top][3] = sy;
    top++;
  }

  float[] pop() {
    if (top == 0) return new float[]{ 0, 0, 1, 1 };
    top--;
    return stack[top].clone();
  }

  float[] peek() {
    if (top == 0) return new float[]{ 0, 0, 1, 1 };
    return stack[top - 1].clone();
  }

  boolean empty()  { return top == 0; }
  int     size()   { return top; }
}

TransformStack txStack = new TransformStack(32);
