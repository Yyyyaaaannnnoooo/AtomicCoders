class Particle {
  PVector pos, target, vel, acc;
  PVector[] trail = new PVector[10];
  float speed = 5, G = .4, mass = 5.0, sinFactor = 0, sinCounter = 0;
  int r = 7, ionizingFactor = 0, count = 0;
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
    for (int i = 0; i < constrain(count, 0, trail.length); i++) {
      float sze = 10;
      pushMatrix();
      translate(trail[i].x, trail[i].y);
      fill(255, map(i, 0, trail.length, 255, 55));
      ellipse(0, 0, sze, sze);
      popMatrix();
    }
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
    p.vel.limit(5);
    p.pos.add(vel);
    //PVector angle = PVector.fromAngle(sin(sinCounter), hitTarget);
    //angle.mult(2);
    //p.pos.add(angle);
    //sinCounter += .5;
    trail[count % trail.length] = new PVector(p.pos.x, p.pos.y);
    count++;
    removeParticle = hit(p, hitTarget);
  }
  //removing the particle who hitted the target
  boolean hit(Particle p, PVector hitted) {
    boolean isHit = false;
    float d = p.pos.dist(hitted);
    println(d);
    if (d < 5)isHit = true;
    return isHit;
  }
  //animation when the target has been hitted
  void targetIsHitted(PVector p, int radius) {
    noFill();
    stroke(0, 255, 0);
    strokeWeight(2);
    beginShape(POINTS);
    for (int i = 0; i < 8; i ++) {
      float angle = map ( i, 0, 8, 0, TWO_PI);
      float x = p.x + (cos(angle) * radius);
      float y = p.y + (sin(angle) * radius);
      vertex(x, y);
    }
    endShape();
  }
}