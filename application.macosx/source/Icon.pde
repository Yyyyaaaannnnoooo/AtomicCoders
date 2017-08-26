class Icon {
  PImage[] dancingGuy = new PImage[2];
  boolean isDancing = false, hitted = false;
  PImage icon;
  int hitCounter = 0, step = 0;
  PVector pos;
  Icon(int i, float posX, float posY) {
    icon = loadImage("icon_"+i+".png");
    pos = new PVector(posX, posY);
    if (i == 2) {
      isDancing =true;
      ///need to correct this whan changing the icons name
      for (int j = 0; j < dancingGuy.length; j++) {
        int index = j + 2;
        dancingGuy[j] = loadImage("icon_"+index+".png");
      }
    }
  }
  void update(Particle p) {
    float d = pos.dist(p.pos);
    if (d < 25) {
      hitted = true;
    }
  }
  void show() {
    color alive = color(255);
    color dead = color(0, 255, 0);
    if (hitted) {
      tint(dead);
    } else {
      tint(alive);
    }
    imageMode(CENTER);
    if (isDancing) {
      image(dancingGuy[step % dancingGuy.length], pos.x, pos.y);
      if (frameCount % 15 == 0) {
        step++;
      }
    } else {
      image(icon, pos.x, pos.y);
    }
  }
}