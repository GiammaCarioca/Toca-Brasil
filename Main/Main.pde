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
Slider2D cropInSlider;
Slider2D cropOutSlider;

Regiao norte;
Regiao nordeste;
Regiao sudeste;
Regiao centroeste;
Regiao sul;

Regiao[] regioes = new Regiao[5];

Particles particles = new Particles();

AudioPlayer screensaverSound;
int millisToStartScreensaver = 0;

Boolean showKinect = false;
Boolean showCursor = false;
Boolean showUI = false;
PVector cursorTranslate = new PVector(0, 0);
PVector cursorScale = new PVector(1, 1);

PImage mask;
PImage contorno;

PVector cursor = new PVector();

Minim minim;

ExplosionSystem explosions;

void setup() {
  size(1024, 768, P3D);
  //fullScreen(P3D);
  
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
  cp5.addSlider("cursorX", -1000, 1000, 0, 100, 400, 300, 14);
  cp5.addSlider("cursorY", -1000, 1000, 0, 100, 420, 300, 14);
  cp5.addSlider("cursorScaleX", 0, 4, 1, 100, 440, 300, 14);
  cp5.addSlider("cursorScaleY", 0, 4, 1, 100, 460, 300, 14);
  
  cropInSlider = cp5.addSlider2D("cropIn")
         .setPosition(100,520)
         .setSize(100,100)
         .setMinMax(0, 0, 640, 480)
         .setArrayValue(new float[] {0, 0});
         
  cropOutSlider = cp5.addSlider2D("cropOut")
         .setPosition(250,520)
         .setSize(100,100)
         .setMinMax(0, 0, 640, 480)
         .setArrayValue(new float[] {640, 480});
                
  cp5.setAutoDraw(false);
  cp5.loadProperties("default.json");
  
  norte = new Regiao(this, "norte.png", color(219, 25, 6));
  nordeste = new Regiao(this, "nordeste.png", color(255, 120, 7));
  sudeste = new Regiao(this, "sudeste.png", color(210, 30, 87));
  centroeste = new Regiao(this, "centroeste.png", color(255, 225, 0));
  sul = new Regiao(this, "sul.png", color(245, 175, 10));
  
  centroeste.addSound("musicas/centroeste/sertanejo.mp3");
  centroeste.addSound("musicas/centroeste/siriri.mp3");
  centroeste.addSound("musicas/centroeste/catira.mp3");
  nordeste.addSound("musicas/nordeste/forro.mp3");
  nordeste.addSound("musicas/nordeste/frevo.mp3");
  nordeste.addSound("musicas/nordeste/maracatu.mp3");
  norte.addSound("musicas/norte/carimbo.mp3");
  norte.addSound("musicas/norte/lundu.mp3");
  norte.addSound("musicas/norte/retumbao.mp3");
  sudeste.addSound("musicas/sudeste/funk.mp3");
  sudeste.addSound("musicas/sudeste/caterete.mp3");
  sudeste.addSound("musicas/sudeste/samba.mp3");
  sul.addSound("musicas/sul/chamarrita.mp3");
  sul.addSound("musicas/sul/fandango.mp3");
  sul.addSound("musicas/sul/milonga.mp3");
  
  regioes[0] = norte;
  regioes[1] = nordeste;
  regioes[2] = sudeste;
  regioes[3] = centroeste;
  regioes[4] = sul;
  
  screensaverSound = minim.loadFile("musicas/base.mp3");
  screensaverSound.setGain(0);
  screensaverSound.loop();
  
  mask = loadImage("mask.png");
  contorno = loadImage("contorno.png");
  
  explosions = new ExplosionSystem(new PVector());
}

void draw() {
  background(0);
  
  //PVector surfaceMouse = surface.getTransformedMouse();
  
  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(0);
  
  // Run the tracking analysis
  tracker.cropX = (int)cropInSlider.getArrayValue()[0];
  tracker.cropY = (int)cropInSlider.getArrayValue()[1];
  tracker.cropWidth = (int)cropOutSlider.getArrayValue()[0];
  tracker.cropHeight = (int)cropOutSlider.getArrayValue()[1];
  tracker.track();

  // Let's draw the "lerped" location
  PVector v2 = tracker.getPos();
  cursor = new PVector(v2.x, v2.y);
  if(cursor.x>1 && cursor.y>1){
    cursor.mult((float)width/(float)kinect.width);
  }
  
  //para debugar
  //cursor.x = mouseX;
  //cursor.y = mouseY;
  
  if(tracker.touching){
    particles.attract.x = cursor.x;
    particles.attract.y = cursor.y; 
  
    cursor.x *= cursorScale.x;
    cursor.y *= cursorScale.y;
    
    cursor.x += cursorTranslate.x;
    cursor.y += cursorTranslate.y;
  }else{
    particles.attract.x = -1;
    particles.attract.y = -1;
  
    cursor.x = 0;
    cursor.y = 0;
  }
  
  for (int i = 0; i < regioes.length; i++) {
    boolean tocou = regioes[i].tocou(cursor.x, cursor.y);
    regioes[i].update();
    
    if (tocou) {
      millisToStartScreensaver = millis() + 5 * 1000; // 5 segundos * 1000 milisegundos
    }
  }
  
  if (millis() > millisToStartScreensaver) {
    screensaverSound.setGain(0);
    for (int i = 0; i < regioes.length; i++) {
      if (regioes[i].toggle) {
        regioes[i].onPress();
      }
    }
  } else {
    screensaverSound.setGain(-60);
  }
  
  for(int j=0; j < particles.movers.length; j++){
    boolean tocou = false;
    particles.movers[j].col = color(255);
    particles.movers[j].sz = 5;
    for (int i = 0; i < regioes.length && !tocou; i++) {
      if(regioes[i].toggle){
        tocou = regioes[i].tocouParticle(particles.movers[j].location.x, particles.movers[j].location.y);
        if(tocou){
          particles.movers[j].sz = (regioes[i].amplitude * tracker.intensity) * 50 + 5;
          particles.movers[j].col = color(red(regioes[i].col), green(regioes[i].col), blue(regioes[i].col), 0);
          if(regioes[i].amplitude>0.8 && random(1.0)>0.5){
            explosions.origin.set(particles.movers[j].location.x,particles.movers[j].location.y,0);
            explosions.addParticle(regioes[i].col);
          }
        }
      }
    }
  }
  particles.draw(offscreen);
  
  offscreen.hint(DISABLE_DEPTH_TEST);
  offscreen.image(mask, 0, 0);
  offscreen.image(contorno, 0, 0);
  offscreen.hint(ENABLE_DEPTH_TEST);
  
  
  explosions.run(offscreen);
  
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
    break;
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

public void cropIn(float[] theArray) {
  println(theArray[0]);
}
public void cropOut(float[] theArray) {
  println(theArray[0]);
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