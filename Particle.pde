class Particle {
  PVector pos, target, vel, acc;
  float speed = 5, G = .4, mass = 5.0, sinFactor = 0;
  int r = 7, ionizingFactor = 0;
  color c;
  Particle(float posX, float posY, float posZ) {
    c = color(0, 255, 255, 75);
    target = new PVector(originX, originY, 0);
    pos = new PVector(posX, posY, posZ);
    vel = new PVector(0, 0, 0);
  }


  void update() {
    PVector dir = PVector.sub(target, pos);
    dir.normalize();
    dir.mult(.25);
    acc = dir;
    vel.add(acc);
    vel.limit(speed);
    pos.add(vel);
    if (frameCount > 200)ionizingFactor++;
    sinFactor += 0.1;
  }

  void show() {
    //stroke(0);
    strokeWeight(.3);
    fill(c);
    pushMatrix();
    ellipse(pos.x, pos.y, r * 2, r * 2);
    popMatrix();
  }
  //ionizing function the particle gets excited
  void ionizing(Particle p) {
    int colorReduction = constrain(ionizingFactor, 0, 255);
    float alphaSin = map(sin(sinFactor), -1, 1, 100, 255);
    p.c = color(0 + colorReduction, 255 - colorReduction, 255 - colorReduction, alphaSin);
    if (ionizingFactor > 300)radiation(p);
  }
  //the ionized particle is shot to a target
  void radiation(Particle p) {
    PVector hitTarget = new PVector(0, 0);
    PVector dir = PVector.sub(hitTarget, p.pos);
    dir.normalize();
    dir.mult(1);
    p.acc = dir;
    p.vel.add(p.acc);
    p.vel.limit(.05);
    p.pos.add(vel);
  }
}