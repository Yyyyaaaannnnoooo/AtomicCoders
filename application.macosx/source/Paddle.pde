class Paddle {
  int w = 20;
  int h = 100;
  float x = 520, y, angle = 0;
  PVector pos;
  Paddle() {
    rectMode(CENTER);
  }
  void update(float mouse) {
    angle = map(mouse, 50, height - 50, 0, TWO_PI);
    float x = width / 2 + cos(angle) * 200;
    float y = height / 2 + sin(angle) * 200;
    pos = new PVector(x, y);
    println(pos);
    if (h <= 20)h = 20;
  }
  void show() {
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    fill(255);
    rect(0, 0, w, h);
    popMatrix();
  }
}