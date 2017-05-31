import ddf.minim.*;
import ddf.minim.effects.*;
Minim minim;
AudioPlayer paddleHit, iconHit;
ArrayList <Particle> ionized = new ArrayList <Particle>();
Particle[] p; // change back normal object array
Electron[] el;
Icon[] icon;
Paddle paddle;
PVector hitPos = new PVector();
boolean isIonizing = false, hitted = false, gameover = false, gamestart = true;
int w = 1200, h = 900, nextNeutron = 3, atomicNum = 195, timer = 30, currentNeutron = 0;
int targetRadius = 5, hittedIcons;
///grid for the icons
int cell = 50;
int wGrid = 450, hGrid = 900;
int cols = wGrid / cell, rows = hGrid / cell;
float radius = 250;
float originX = w * 0.8, originY = h / 2; //defining the origin of the Atom
PImage man;
void settings() {
  size(w, h, P3D);
}
void setup() {
  surface.setTitle("THE RADIATION GAME");
  man = loadImage("man_01.png");
  minim = new Minim(this);
  paddle = new Paddle();
  //nucleus of the atom
  p = new Particle [atomicNum];
  for (int i = 0; i < p.length; i++) {
    float angle = map( i, 0, atomicNum, 0, TWO_PI);
    float x = originX + (cos(angle) * random(0, radius / 3));
    float y = originY + (sin(angle) * random(0, radius / 3));
    p[i] = new Particle(x, y, random(-100, 100), originX, originY, 0);
  }
  //electrons
  el = new Electron[20];
  for (int i = 0; i < el.length; i++) {
    float angle = map(i, 0, el.length, 0, TWO_PI);
    float x = originX + (cos(angle) * random(radius * .75, radius));
    float y = originY + (sin(angle) * random(radius * .75, radius));
    el[i] = new Electron(5.0, x, y, random(-100, 100));
  }
  ///positioning the icons on a grid structure
  icon = new Icon[cols * rows];
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      int i = x + cols * y;
      icon[i] = new Icon(floor(random(1, 8)), x * 50 + 50 / 2, y * 50 + 50 / 2);
    }
  }
  background(0);
}
void draw() {
  ortho();
  background(0);
  if (gamestart) {
    textSize(72);
    textAlign(CENTER);
    text("PRESS ANY KEY TO START", width / 2, height / 2);
    if (keyPressed)gamestart = false;
  } else {
    ///PADDLE DEFEND THE LIVING///
    paddle.show();
    paddle.update(mouseY);
    ///FROM HERE ON PARTICLE STUFF////
    for (Icon i : icon) {
      i.show();
    }
    for (Particle part : p) {
      part.update();
      part.show();
    }

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
      if (i.pos.x > paddle.x - 50 && i.pos.x < paddle.x - 30) {
        iconHit = minim.loadFile("output_01.mp3");
        iconHit.play();
      }
      if (i.removeParticle || i.pos.x < -10) {
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
    ///GAME OVER///
    hittedIcons = 0;
    for (int i = 0; i < icon.length; i++) {
      if (icon[i].hitted == true)hittedIcons++;
    }
    float prctg = map(hittedIcons, 0, cols * rows, 0, 100);
    textAlign(CORNER);
    fill(255);
    textSize(72);
    text(prctg+" %", 500, height *  0.9);
    textSize(36);
    text("DYING BY RADIATION EXPOSURE", 500, height * 0.95);
    if (prctg > 75)gameOver();
  }
}
void gameOver() {
  minim.stop();
  pushMatrix();
  translate(0, 0, 10);
  rectMode(CORNER);
  textAlign(CENTER);
  fill(0);
  rect(0, 0, width, height);
  fill(255);
  textSize(72);
  text("GAME OVER", width * 0.5, height * 0.4);
  textSize(18);
  text("PRESS SPACE BAR TO EXIT", width * 0.5, height * 0.45);
  popMatrix();
  gameover = true;
}

void keyPressed() {
  if (gameover) {
    if (key == ' ')exit();
  }
}