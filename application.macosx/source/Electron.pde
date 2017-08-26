class Electron {

  // Basic physics model (position, velocity, acceleration, mass)
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass, G = .4;
  int count = 0;
  PVector[] trail = new PVector[50];
  Electron(float m, float x, float y, float z) {
    mass = m;
    position = new PVector(x, y, z);
    velocity = new PVector(1, 0);   // Arbitrary starting velocity
    acceleration = new PVector(0, 0);
  }
  PVector attract(Electron e) {
    PVector target = new PVector(originX, originY, 0);
    PVector force = PVector.sub(target, e.position);    // Calculate direction of force
    float d = force.mag();                              // Distance between objects
    d = constrain(d, 0, 2.0);                                       // Limiting the distance to eliminate "extreme" results for very close or very far objects
    float strength = (G * mass * 2) / (d * d);      // Calculate gravitional force magnitude
    force.setMag(strength);                              // Get force vector --> magnitude * direction
    return force;
  }
  // Newton's 2nd Law (F = M*A) applied
  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  // Our motion algorithm (aka Euler Integration)
  void update() {
    velocity.add(acceleration); // Velocity changes according to acceleration
    position.add(velocity);     // position changes according to velocity
    acceleration.mult(.1);
    trail[count % trail.length] = new PVector(position.x, position.y, position.z);
    count++;
  }

  // Draw the Electron
  void show() {
    noStroke(); 
    pushMatrix(); 
    noFill(); 
    strokeWeight(2); 
    stroke(155, 155, 0);
    for (int i = 0; i < constrain(count, 0, trail.length); i++) {
      point(trail[i].x, trail[i].y, trail[i].z);
    }
    translate(position.x, position.y, position.z); 
    noStroke(); 
    color c = color(155, 155, 0); 
    pixelCircle(0, 0, c); 
    popMatrix();
  }
}