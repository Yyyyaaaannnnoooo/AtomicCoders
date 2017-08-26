import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.effects.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class atom_04 extends PApplet {



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
int vertices = 20, ellipses = 5;
float radius = 250;
float originX = w * 0.5f, originY = h * 0.5f; //defining the origin of the Atom
PImage man;
public void settings() {
  size(w, h, P3D);
}
public void setup() {
  surface.setTitle("THE RADIATION GAME");
  man = loadImage("man_01.png");
  minim = new Minim(this);
  paddle = new Paddle();
  //nucleus of the atom
  p = new Particle [atomicNum];
  for (int i = 0; i < atomicNum; i++) {
    float angle = map( i, 0, atomicNum, 0, TWO_PI);
    float x = originX + (cos(angle) * random(0, radius / 3));
    float y = originY + (sin(angle) * random(0, radius / 3));
    p[i] = new Particle(x, y, random(-100, 100), originX, originY, 0);
  }
  //electrons
  el = new Electron[20];
  for (int i = 0; i < el.length; i++) {
    float angle = map(i, 0, el.length, 0, TWO_PI);
    float x = originX + (cos(angle) * random(radius * .75f, radius));
    float y = originY + (sin(angle) * random(radius * .75f, radius));
    el[i] = new Electron(5.0f, x, y, random(-100, 100));
  }
  ///positioning the icons on a grid structure
  int i = 0;
  icon = new Icon[vertices * ellipses];
  for (int y = 0; y < vertices; y++) {
    for (int x = 0; x < ellipses; x++) {
      float angle = map(y, 0, vertices, 0, TWO_PI);
      float xx = (width * 0.5f) + cos(angle) * (radius + (x * 50));
      float yy = (height * 0.5f) + sin(angle) * (radius + (x * 50));
      icon[i] = new Icon(floor(random(1, 8)), xx, yy);
      i++;
    }
  }
  background(0);
}
public void draw() {
  ortho();
  background(0);
  if (gamestart) {
    textSize(72);
    textAlign(CENTER);
    text("PRESS ANY KEY TO START", width / 2, height / 2);
    if (keyPressed)gamestart = false;
  } else {
    ///PADDLE DEFEND THE LIVING///
    paddle.update(mouseY);
    paddle.show();
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
      ionized.add(new Particle(random(originX * 0.95f, originX), random(originY * 0.95f, originY), 0, originX, originY, 0));
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
      if (i.pos.x > paddle.x - 40 && i.pos.x < paddle.x - 30) {
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
    float prctg = map(hittedIcons, 0, vertices * ellipses, 0, 100);
    textAlign(CORNER);
    fill(255);
    textSize(72);
    text(prctg+" %", 500, height *  0.9f);
    textSize(36);
    text("DYING BY RADIATION EXPOSURE", 500, height * 0.95f);
    if (prctg > 75)gameOver();
  }
}
public void gameOver() {
  minim.stop();
  pushMatrix();
  translate(0, 0, 200);
  rectMode(CORNER);
  textAlign(CENTER);
  fill(0);
  rect(0, 0, width, height);
  fill(255);
  textSize(72);
  text("GAME OVER", width * 0.5f, height * 0.4f);
  textSize(18);
  text("PRESS SPACE BAR TO EXIT", width * 0.5f, height * 0.45f);
  popMatrix();
  gameover = true;
}

public void pixelCircle( float x, float y, int c) {
  pushMatrix();
  noStroke();
  fill(c);
  rectMode(CENTER);
  for ( int i = 0; i < 2; i++) {
    rect(x, y, 10 + (i * 10), 20 - (i * 10));
  }
  popMatrix();
}

public void keyPressed() {
  if (gameover) {
    if (key == ' ')exit();
  }
}
class Electron {

  // Basic physics model (position, velocity, acceleration, mass)
  PVector position;
  PVector velocity;
  PVector acceleration;
  float mass, G = .4f;
  int count = 0;
  PVector[] trail = new PVector[50];
  Electron(float m, float x, float y, float z) {
    mass = m;
    position = new PVector(x, y, z);
    velocity = new PVector(1, 0);   // Arbitrary starting velocity
    acceleration = new PVector(0, 0);
  }
  public PVector attract(Electron e) {
    PVector target = new PVector(originX, originY, 0);
    PVector force = PVector.sub(target, e.position);    // Calculate direction of force
    float d = force.mag();                              // Distance between objects
    d = constrain(d, 0, 2.0f);                                       // Limiting the distance to eliminate "extreme" results for very close or very far objects
    float strength = (G * mass * 2) / (d * d);      // Calculate gravitional force magnitude
    force.setMag(strength);                              // Get force vector --> magnitude * direction
    return force;
  }
  // Newton's 2nd Law (F = M*A) applied
  public void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  // Our motion algorithm (aka Euler Integration)
  public void update() {
    velocity.add(acceleration); // Velocity changes according to acceleration
    position.add(velocity);     // position changes according to velocity
    acceleration.mult(.1f);
    trail[count % trail.length] = new PVector(position.x, position.y, position.z);
    count++;
  }

  // Draw the Electron
  public void show() {
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
    int c = color(155, 155, 0); 
    pixelCircle(0, 0, c); 
    popMatrix();
  }
}
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
  public void update(Particle p) {
    float d = pos.dist(p.pos);
    if (d < 25) {
      hitted = true;
    }
  }
  public void show() {
    int alive = color(255);
    int dead = color(0, 255, 0);
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
class Paddle {
  int w = 20;
  int h = 100;
  float x = 520, y, angle = 0;
  PVector pos;
  Paddle() {
    rectMode(CENTER);
  }
  public void update(float mouse) {
    angle = map(mouse, 50, height - 50, 0, TWO_PI);
    float x = width / 2 + cos(angle) * 200;
    float y = height / 2 + sin(angle) * 200;
    pos = new PVector(x, y);
    println(pos);
    if (h <= 20)h = 20;
  }
  public void show() {
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    fill(255);
    rect(0, 0, w, h);
    popMatrix();
  }
}
class Particle {
  PVector pos, target, vel, acc;
  PVector[] trail = new PVector[5];
  float speed = 5, G = .4f, mass = 5.0f, sinFactor = 0, sinCounter = 0;
  int r = 7, ionizingFactor = 0, count = 0;
  int c;
  boolean removeParticle = false;
  PVector hitTarget = new PVector(-10, random(-200, height + 200));
  //position and target of the particle
  Particle(float posX, float posY, float posZ, float trX, float trY, float trZ) {
    c = color(0, 255, 255, 75);
    target = new PVector(trX, trY, trZ);
    pos = new PVector(posX, posY, posZ);
    vel = new PVector(0, 0, 0);
  }


  public void update() {
    PVector dir = PVector.sub(target, pos);
    dir.normalize();
    dir.mult(.25f);
    acc = dir;
    vel.add(acc);
    vel.limit(speed);
    pos.add(vel);
    ionizingFactor += 10;
    sinFactor += 0.07f;
  }

  public void show() {
    for (int i = 0; i < constrain(count, 0, trail.length); i++) {
      float sze = 10;
      pushMatrix();
      translate(trail[i].x, trail[i].y);
      int c2 = color(0, 255, 255, map(i, 0, trail.length, 255, 55));
      pixelCircle(0, 0, c2);
      popMatrix();
    }
    pushMatrix();
    pixelCircle(pos.x, pos.y, c);
    popMatrix();
  }
  //ionizing function the particle gets excited
  public void ionizing(Particle p) {
    float alphaSin = map(sin(sinFactor), -1, 1, 150, 255);
    p.c = color(255 - ionizingFactor % 255, 0, 0, alphaSin);
  }
  //the ionized particle is shot to a target
  public void radiation(Particle p, Paddle pad) {
    PVector dir = PVector.sub(hitTarget, p.pos);
    dir.normalize();
    dir.mult(1);
    p.acc = dir;
    p.vel.add(p.acc);
    p.vel.limit(5);
    p.pos.add(vel);
    trail[count % trail.length] = new PVector(p.pos.x, p.pos.y);
    count++;
    if (p.pos.x < pad.x + pad.w &&
        p.pos.x > pad.x - pad.w &&
        p.pos.y > pad.y - pad.h / 2 &&
        p.pos.y < pad.y + pad.h / 2) {
      p.removeParticle = true;
      pad.h -= 5;
      paddleHit = minim.loadFile("output_02.mp3");
      paddleHit.play();
    }
  }
  //animation when the target has been hitted
  public void targetIsHitted(PVector p, int radius) {
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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "atom_04" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
