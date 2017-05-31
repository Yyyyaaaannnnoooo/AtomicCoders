class Paddle {
  int w = 20;
  int h = 100;
  float x = 520, y;
  Paddle() {
    rectMode(CENTER);
  }
  void update(float posY) {
    y = posY;
  }
  void show() {
    fill(255);
    rect(x, y, w, h);
  }
}