ArrayList <Particle> ionized = new ArrayList <Particle>();
Particle[] p; // change back normal object array
Electron[] el;
Icon[] icon;
Paddle paddle;
PVector hitPos = new PVector();
boolean isIonizing = false, hitted = false;
int w = 1200, h = 900, nextNeutron = 3, atomicNum = 195, timer = 30, currentNeutron = 0;
int targetRadius = 5;
///loading icon made with icon maker
int cell = 50;
int wGrid = 450, hGrid = 900;
int cols = wGrid / cell, rows = hGrid / cell;
int[][] grid = new int[cols][rows];
float radius = 250;
float originX = w * 0.8, originY = h / 2; //defining the origin of the Atom
PImage man;
void settings() {
  size(w, h, P3D);
}
void setup() {
  //loadIcon();
  man = loadImage("man_01.png");
  paddle = new Paddle();
  icon = new Icon[cols * rows];
  el = new Electron[20];
  p = new Particle [atomicNum];
  for (int i = 0; i < p.length; i++) {
    float angle = map( i, 0, atomicNum, 0, TWO_PI);
    float x = originX + (cos(angle) * random(0, radius / 3));
    float y = originY + (sin(angle) * random(0, radius / 3));
    p[i] = new Particle(x, y, random(-100, 100), originX, originY, 0);
  }
  for (int i = 0; i < el.length; i++) {
    float angle = map(i, 0, el.length, 0, TWO_PI);
    float x = originX + (cos(angle) * random(radius * .75, radius));
    float y = originY + (sin(angle) * random(radius * .75, radius));
    el[i] = new Electron(5.0, x, y, random(-100, 100));
  }
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      float alive = random(100);
      int i = x + cols * y;
      icon[i] = new Icon(floor(random(1, 8)), x * 50 + 50 / 2, y * 50 + 50 / 2);
    }
  }
  background(0);
}
void draw() {
  ortho();
  background(0);
  //for (int x = 0; x < cols; x ++) {
  //  for (int y = 0; y < rows; y ++) {
  //    if (grid[x][y] == 0) {
  //      fill(255);
  //      rect(x * cell, y * cell, cell, cell);
  //    }
  //  }
  //}
  paddle.show();
  paddle.update(mouseY);
  for (Icon i : icon) {
    i.show();
  }
  for (Particle part : p) {
    part.update();
    part.show();
  }
  
  /// find why every second ion is not working....
  
  //adding the ions with limit of 40 units
  if (frameCount % timer == 0 && ionized.size() < 40) {
    ionized.add(new Particle(random(originX * 0.95, originX), random(originY * 0.95, originY), 0, originX, originY, 0));
  }
  for (Particle ion : ionized) {
    ion.update();
    ion.show();
    ion.ionizing(ion);
  }

  // ion shooting timer
  if (frameCount % timer * 3 == 0)isIonizing = true;
  //the radiation searches for the icons
  if (isIonizing) {
    Particle i = ionized.get(currentNeutron % ionized.size());
    for (Icon ic : icon) {
      ic.update(i);
    }
    i.radiation(i, paddle);
    if (i.removeParticle || i.pos.x < 0) {
      println("remove");
      hitted = true;
      hitPos = i.pos;
      ionized.remove(currentNeutron % ionized.size());
      currentNeutron++;
      isIonizing = false;
    }
    //is the icon hitted if yes remove particle and show animation
    if (hitted) {    
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
  //println(frameRate);
}
void loadIcon() {
  String[] loadedIcon = loadStrings("icon.txt");
  for (int x = 0; x < cols; x ++) {
    for (int y = 0; y < rows; y ++) {
      int index = x + cols * y;
      grid[x][y] = int(loadedIcon[index]);
    }
  }
}