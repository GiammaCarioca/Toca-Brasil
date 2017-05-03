import org.openkinect.freenect.*;
import org.openkinect.processing.*;
import deadpixel.keystone.*;

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

Boolean showKinect = false;
Boolean showCursor = false;
Boolean showUI = false;

void setup() {
  size(1024, 768, P3D);

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
  
  norte = new Regiao("norte.png");
  nordeste = new Regiao("nordeste.png");
  sudeste = new Regiao("sudeste.png");
  centroeste = new Regiao("centroeste.png");
  sul = new Regiao("sul.png");
  
  regioes[0] = norte;
  regioes[1] = nordeste;
  regioes[2] = sudeste;
  regioes[3] = centroeste;
  regioes[4] = sul;
}

void draw() {
  background(255);
  
  
  PVector surfaceMouse = surface.getTransformedMouse();
  
  
  // Draw the scene, offscreen
  offscreen.beginDraw();
  offscreen.background(255);
  
  // Run the tracking analysis
  tracker.track();

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  PVector v3 = new PVector(v2.x, v2.y);
  if(v3.x>1 && v3.y>1){
    v3.mult((float)width/(float)kinect.width);
  }
  
  for (int i = 0; i < regioes.length; i++) {
    regioes[i].tocou(v3.x, v3.y);
    if(regioes[i].pressed){
      offscreen.image(regioes[i].background, 0, 0);
    }
  }
  
  if(showKinect) {
    tracker.display();

    fill(0);
    text("threshold: " + tracker.getThreshold() + "    " +  "framerate: " + int(frameRate) + "    " + 
      "UP increase threshold, DOWN decrease threshold", 10, 500);
  }
  
  if(showCursor){
    offscreen.noStroke();
    offscreen.fill(100, 250, 50, 200);
    offscreen.ellipse(v2.x, v2.y, 20, 20);
    offscreen.fill(250, 100, 50, 200);
    offscreen.ellipse(v3.x, v3.y, 20, 20);
  }
  
  offscreen.endDraw();
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