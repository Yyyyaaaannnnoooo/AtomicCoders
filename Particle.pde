class Particle {
  PVector pos, target, vel, acc;
  float speed = 5, G = .4, mass = 5.0, sinFactor = 0;
  int r = 7, ionizingFactor = 0;
  color c;
  boolean removeParticle = false;
  //position and target of the particle
  Particle(float posX, float posY, float posZ, float trX, float trY, float trZ) {
    c = color(0, 255, 255, 75);
    target = new PVector(trX, trY, trZ);
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
    ionizingFactor += 10;
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
  }
  //the ionized particle is shot to a target
  void radiation(Particle p, float targetX, float targetY) {
    PVector hitTarget = new PVector(targetX, targetY);
    PVector dir = PVector.sub(hitTarget, p.pos);
    dir.normalize();
    dir.mult(1);
    p.acc = dir;
    p.vel.add(p.acc);
    p.vel.limit(50);
    p.pos.add(vel);
    removeParticle = hit(p, hitTarget);
  }
  //removing the particle who hitted the target
  boolean hit(Particle p, PVector hitted) {
    boolean isHit = false;
    float d = p.pos.dist(hitted);
    if (d < 2)isHit = true;
    return isHit;
  }
}