import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import deadpixel.keystone.*;
import ddf.minim.*;

Keystone ks;
CornerPinSurface surface;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

PGraphics offscreen;

import controlP5.*;
ControlP5 cp5;

Regiao norte;
Regiao nordeste;
Regiao sudeste;
Regiao centroeste;
Regiao sul;

Regiao[] regioes = new Regiao[5];

Particles particles = new Particles();

Boolean showKinect = false;
Boolean showCursor = false;
Boolean showUI = false;
PVector cursorTranslate = new PVector(0, 0);
PVector cursorScale = new PVector(1, 1);

PImage mask;
PImage contorno;

PVector cursor = new PVector();

Minim minim;

void setup() {
  size(1024, 768, P3D);
  
  minim = new Minim(this);
  
  particles.setup();

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  ks.load();
  
  offscreen = createGraphics(width, height, P3D);
  
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  
  cp5 = new ControlP5(this);
  
  cp5.addToggle("ShowKinect")
                .setPosition(100, 250)
                .setSize(40, 40);
  
  
  cp5.addToggle("ShowCursor")
                .setPosition(180, 250)
                .setSize(40, 40);
  
  
  cp5.addToggle("ShowMapping")
                .setPosition(260, 250)
                .setSize(40, 40);
  
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("contraste", 0, 1000, 780, 100, 350, 300, 14);
  
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("cursorX", -300, 300, 0, 100, 400, 300, 14);
  cp5.addSlider("cursorY", -300, 300, 0, 100, 420, 300, 14);
  cp5.addSlider("cursorScaleX", 0, 2, 1, 100, 440, 300, 14);
  cp5.addSlider("cursorScaleY", 0, 2, 1, 100, 460, 300, 14);
                
  cp5.setAutoDraw(false);
  cp5.loadProperties("default.json");
  
  norte = new Regiao(this, "norte.png", color(255, 0, 0));
  nordeste = new Regiao(this, "nordeste.png", color(255, 255, 0));
  sudeste = new Regiao(this, "sudeste.png", color(0, 255, 0));
  centroeste = new Regiao(this, "centroeste.png", color(0, 0, 255));
  sul = new Regiao(this, "sul.png", color(255, 0, 255));
  
  centroeste.addSound("musicas/centroeste/sertanejo.mp3");
  centroeste.addSound("musicas/centroeste/siriri.mp3");
  nordeste.addSound("musicas/nordeste/forro.mp3");
  nordeste.addSound("musicas/nordeste/frevo.mp3");
  norte.addSound("musicas/norte/carimbo.mp3");
  norte.addSound("musicas/norte/retumbao.mp3");
  sudeste.addSound("musicas/sudeste/funk.mp3");
  sudeste.addSound("musicas/sudeste/samba.mp3");
  sul.addSound("musicas/sul/chamarrita.mp3");
  sul.addSound("musicas/sul/fandango.mp3");
  
  regioes[0] = norte;
  regioes[1] = nordeste;
  regioes[2] = sudeste;
  regioes[3] = centroeste;
  regioes[4] = sul;
  
  mask = loadImage("mask.png");
  contorno = loadImage("contorno.png");
}

void draw() {
  background(0);
  
  //PVector surfaceMouse = surface.getTransformedMouse();
  
  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);
  
  // Run the tracking analysis
  tracker.track();

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  cursor = new PVector(v2.x, v2.y);
  if(cursor.x>1 && cursor.y>1){
    cursor.mult((float)width/(float)kinect.width);
  }
  
  //para debugar
  //cursor.x = mouseX;
  //cursor.y = mouseY;
  
  cursor.x *= cursorScale.x;
  cursor.y *= cursorScale.y;
  
  cursor.x += cursorTranslate.x;
  cursor.y += cursorTranslate.y;
  
  for (int i = 0; i < regioes.length; i++) {
    regioes[i].tocou(cursor.x, cursor.y);
    regioes[i].update();
    if(regioes[i].toggle){
      //offscreen.image(regioes[i].background, 0, 0);
    }
  }
  for(int j=0; j < particles.movers.length; j++){
    boolean tocou = false;
    particles.movers[j].col = color(255);
    particles.movers[j].sz = 5;
    for (int i = 0; i < regioes.length && !tocou; i++) {
      if(regioes[i].toggle){
        tocou = regioes[i].tocouParticle(particles.movers[j].location.x, particles.movers[j].location.y);
        if(tocou){
          particles.movers[j].sz = regioes[i].amplitude * 50 + 5;
          particles.movers[j].col = regioes[i].col;
        }
      }
    }
  }
  particles.draw(offscreen);
  
  offscreen.hint(DISABLE_DEPTH_TEST);
  offscreen.image(mask, 0, 0);
  offscreen.image(contorno, 0, 0);
  offscreen.hint(ENABLE_DEPTH_TEST);
  
  if(showCursor){
    offscreen.noStroke();
    offscreen.fill(250, 100, 50, 200);
    offscreen.ellipse(cursor.x, cursor.y, 20, 20);
  }
  
  offscreen.endDraw();
  
  surface.render(offscreen);
  
  
  if(showKinect) {
    pushMatrix();
      scale(0.5, 0.5);
      tracker.display();
      
      if(showCursor){
        noStroke();
        fill(100, 250, 50, 200);
        ellipse(v2.x, v2.y, 20, 20);
      }
    
    popMatrix();
    fill(0);
    text("threshold: " + tracker.getThreshold() + "    " +  "framerate: " + int(frameRate) + "    " + 
      "UP increase threshold, DOWN decrease threshold", 10, 500);
  }
  
  if(showUI) cp5.draw();
}

// Adjust the threshold with key presses
void keyPressed() {
  switch(key) {
  case 's':
    // saves the layout
    ks.save();
    cp5.saveProperties("default", "default");
    break;
  case ' ':
    showUI = !showUI;
  }
}

// an event from slider sliderA will change the value of textfield textA here
public void contraste(int theValue) {
  tracker.setThreshold(theValue);
}
public void cursorX(int theValue) {
  cursorTranslate.x = theValue;
}
public void cursorY(int theValue) {
  cursorTranslate.y = theValue;
}
public void cursorScaleX(float theValue) {
  cursorScale.x = theValue;
}
public void cursorScaleY(float theValue) {
  cursorScale.y = theValue;
}

void ShowKinect(boolean theFlag) {
  showKinect = theFlag;
}

void ShowCursor(boolean theFlag) {
  showCursor = theFlag;
}

void ShowMapping(boolean theFlag) {
  ks.toggleCalibration();
}



void mouseDragged(){
  particles.attract.x = cursor.x;
  particles.attract.y = cursor.y;
}

void mouseReleased(){
  particles.attract.x = -1;
  particles.attract.y = -1;
}