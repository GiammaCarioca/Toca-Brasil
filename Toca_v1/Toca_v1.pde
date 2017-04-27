// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

import controlP5.*;
ControlP5 cp5;

Regiao sul;

void setup() {
  size(1024, 768);
  kinect = new Kinect(this);
  tracker = new KinectTracker();
  
  cp5 = new ControlP5(this);
  
  // name, minValue, maxValue, defaultValue, x, y, width, height
  cp5.addSlider("contraste", 0, 1000, 780, 100, 260, 300, 14);
  cp5.setAutoDraw(false);
  cp5.loadProperties(("default.json"));
  
  sul = new Regiao();
}

void draw() {
  background(255);
  // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the "lerped" location
  PVector v2 = tracker.getLerpedPos();
  if(v2.x>1 && v2.y>1){
    println(v2);
    v2.mult((float)width/(float)kinect.width);
    println(v2);
  }
  
  if(sul.tocou(v2.x, v2.y)){
    image(sul.img, 0, 0);
  }
  
  fill(100, 250, 50, 200);
  noStroke();
  ellipse(v2.x, v2.y, 20, 20);

  // Display some info
  int t = tracker.getThreshold();
  fill(0);
  text("threshold: " + t + "    " +  "framerate: " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 500);
  
  cp5.draw();
}

// Adjust the threshold with key presses
void keyPressed() {
  if(keyCode == 's'){
    println("oi");
      cp5.saveProperties("default", "default");
    }
}

// an event from slider sliderA will change the value of textfield textA here
public void contraste(int theValue) {
  
  tracker.setThreshold(theValue);
}