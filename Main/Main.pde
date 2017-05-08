import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import deadpixel.keystone.*;
import processing.sound.*;

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

PImage mask;
PImage contorno;

PVector cursor = new PVector();

void setup() {
  size(1024, 768, P3D);
  
  particles.setup();

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  ks.load();
  
  offscreen = createGraphics(width, height, P3D);
  
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  
  cp5 = new ControlP5(this);
  
  cp5.addCheckBox("onClickShowKinect")
                .setPosition(100, 200)
                .setSize(40, 40)
                .addItem("Show Kinect", 0);
  
  
  cp5.addCheckBox("onClickShowCursor")
                .setPosition(100, 250)
                .setSize(40, 40)
                .addItem("Show Cursor", 0);
  
  
  cp5.addCheckBox("onClickShowMapping")
                .setPosition(100, 300)
                .setSize(40, 40)
                .addItem("Show Mapping", 0);
  
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("contraste", 0, 1000, 780, 100, 350, 300, 14);
                
  cp5.setAutoDraw(false);
  //cp5.loadProperties(("default.json"));
  
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
  
  PVector surfaceMouse = surface.getTransformedMouse();
  
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
  cursor.x = mouseX;
  cursor.y = mouseY;
  
  for (int i = 0; i < regioes.length; i++) {
    regioes[i].tocou(cursor.x, cursor.y);
    if(regioes[i].pressed){
      //offscreen.image(regioes[i].background, 0, 0);
    }
  }
  for(int j=0; j < particles.movers.length; j++){
    boolean tocou = false;
    particles.movers[j].col = color(255);
    for (int i = 0; i < regioes.length && !tocou; i++) {
      if(regioes[i].pressed){
        tocou = regioes[i].tocouParticle(particles.movers[j].location.x, particles.movers[j].location.y);
        if(tocou){
          println(regioes[i].col);
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
    offscreen.fill(100, 250, 50, 200);
    offscreen.ellipse(v2.x, v2.y, 20, 20);
    offscreen.fill(250, 100, 50, 200);
    offscreen.ellipse(cursor.x, cursor.y, 20, 20);
  }
  
  offscreen.endDraw();
  
  
  if(showKinect) {
    tracker.display();

    fill(0);
    text("threshold: " + tracker.getThreshold() + "    " +  "framerate: " + int(frameRate) + "    " + 
      "UP increase threshold, DOWN decrease threshold", 10, 500);
  }
  
  surface.render(offscreen);
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

void onClickShowKinect(float[] a) {
  showKinect = a[0] == 1.0;
}

void onClickShowCursor(float[] a) {
  showCursor = a[0] == 1.0;
}

void onClickShowMapping(float[] a) {
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