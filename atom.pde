ArrayList <Particle> p = new ArrayList <Particle>(); // changed to arrayList
ArrayList <Particle> ionized = new ArrayList <Particle>();
Electron[] el;
boolean isIonizing = true;
int w = 1200, h = 900, nextNeutron = 3, atomicNum = 195, timer = 30;
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
    //if (isIonizing) {
    //  if (frameCount % timer == 0) {
    //    println(nextNeutron);
    //    ionized.add(p.get(nextNeutron));
    //    for (int i = 0; i < ionized.size(); i++) {
    //      part.ionizing(ionized.get(i));
    //    }
    //  }
    //}
  }
  //adding the ions there should be a limit
  if (frameCount% timer == 0) {
    ionized.add(new Particle(random(originX * 0.8, originX), random(originY * 0.8, originY), 0, originX, originY, 0));
  }
  for (Particle ion : ionized) {
    ion.update();
    ion.show();
    ion.ionizing(ion);
    ion.radiation(ion, mouseX, mouseY);
  }
  if (ionized.size() > 40) {
    
  }
  for (Electron e : el) {
    PVector force = e.attract(e);
    e.applyForce(force);
    e.update();
    e.show();
  }
  // removing the extra neutron
  //if (frameCount % timer == 0) {
  //  if (isIonizing) p.remove(nextNeutron);
  //  nextNeutron ++;
  //}
  //if (nextNeutron > 40)isIonizing = false;
}