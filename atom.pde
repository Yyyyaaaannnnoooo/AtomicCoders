Particle[] p;
Electron[] el;
float rot = 0;
int elDist = 500, w = 1200, h = 900;
float radius = 250;
float originX = w * 0.8, originY = h / 2; //defining the origin of the Atom
void settings() {
  size(w, h, P3D);
}
void setup() {
  //size(w, h);
  el = new Electron[20]; 
  p = new Particle[195];
  for (int i = 0; i < p.length; i++) {
    float angle = map( i, 0, p.length, 0, TWO_PI);
    float x = originX + (cos(angle) * random(radius * .75, radius / 5));
    float y = originY + (sin(angle) * random(radius * .75, radius / 5));
    p[i] = new Particle(x, y, random(-100, 100));
  }
  for (int i = 0; i < el.length; i++) {
    float angle = map(i, 0, el.length, 0, TWO_PI);
    float x = originX + (cos(angle) * random(radius * .75, radius));
    float y = originY + (sin(angle) * random(radius * .75, radius));
    el[i] = new Electron(20.0, x, y, random(-100, 100));
  }
  background(0);
}
void draw() {
  ortho();
  background(0);
  for (int i = 0; i < p.length; i++) {
    p[i].update();
    p[i].show();
    p[3].ionizing(p[3]);
  }
  for (Electron e : el) {
    PVector force = p[0].attract(e);
    e.applyForce(force);
    e.update();
    e.show();
  }
}