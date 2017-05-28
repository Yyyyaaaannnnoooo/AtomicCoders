ArrayList <Particle> p = new ArrayList <Particle>(); // change back normal object array
ArrayList <Particle> ionized = new ArrayList <Particle>();
Electron[] el;
PVector hitPos = new PVector();
boolean isIonizing = false, hitted = false;
int w = 1200, h = 900, nextNeutron = 3, atomicNum = 195, timer = 30, currentNeutron = 0;
int targetRadius = 5;
float radius = 250;
float originX = w * 0.8, originY = h / 2; //defining the origin of the Atom
void settings() {
  size(w, h, P3D);
}
void setup() {
  el = new Electron[20]; 
  for (int i = 0; i < atomicNum; i++) {
    float angle = map( i, 0, atomicNum, 0, TWO_PI);
    float x = originX + (cos(angle) * random(0, radius / 3));
    float y = originY + (sin(angle) * random(0, radius / 3));
    p.add(new Particle(x, y, random(-100, 100), originX, originY, 0));
  }
  for (int i = 0; i < el.length; i++) {
    float angle = map(i, 0, el.length, 0, TWO_PI);
    float x = originX + (cos(angle) * random(radius * .75, radius));
    float y = originY + (sin(angle) * random(radius * .75, radius));
    el[i] = new Electron(5.0, x, y, random(-100, 100));
  }
  background(0);
}
void draw() {
  ortho();
  background(0);
  for (Particle part : p) {
    part.update();
    part.show();
  }
  //adding the ions with limit of 40 units
  if (frameCount % timer == 0 && ionized.size() < 40) {
    ionized.add(new Particle(random(originX * 0.95, originX), random(originY * 0.95, originY), 0, originX, originY, 0));
  }
  for (int i = ionized.size() - 1; i >= 0; i--) {
    Particle ion = ionized.get(i);
    ion.update();
    ion.show();
    ion.ionizing(ion);
  }
  // maybe more time between the ions shooting
  if (frameCount % timer == 0)isIonizing = true;

  if (isIonizing) {
    Particle i = ionized.get(currentNeutron % ionized.size());
    i.radiation(i, mouseX, mouseY);
    if (i.removeParticle) {
      hitted = true;
      hitPos = i.pos;
      ionized.remove(currentNeutron % ionized.size());
      currentNeutron++;
      isIonizing = false;
    }
    if (hitted) {//correct this    
      i.targetIsHitted(hitPos, targetRadius);
      targetRadius += 2;
      if (targetRadius > 50) {
        hitted = false;
        targetRadius = 5;
      }
    }
  }

  for (Electron e : el) {
    PVector force = e.attract(e);
    e.applyForce(force);
    e.update();
    e.show();
  }
}