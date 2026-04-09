// Main.pde
void setup() {
  size(730, 580);
  frameRate(60);
  initWarehouseNavigator();
}

void draw() {
  drawWarehouseNavigator();
}

void keyPressed() {
  warehouseKeyPressed();
}

void keyReleased() {
  warehouseKeyReleased();
}

void mousePressed() {
  warehouseMousePressed();
}
