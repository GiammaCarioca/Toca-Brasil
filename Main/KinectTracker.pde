// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

class KinectTracker {

  // Depth threshold
  int threshold = 745;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  // Depth data
  int[] depth;
  
  // What we'll show the user
  PImage display;
  
  float minZ = 9999999;
  float maxZ = 0;
  float intensity = 0;
  
  int cropX = 0;
  int cropY = 0;
  int cropWidth = 640;
  int cropHeight = 480;
  
  Boolean touching = false;
  
   
  KinectTracker() {
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    kinect.initDepth();
    kinect.enableMirror(true);
    // Make a blank image
    display = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;
    int sumZ = 0;

    for (int x = cropX; x < kinect.width && x < cropWidth; x++) {
      for (int y = cropY; y < kinect.height && y < cropHeight; y++) {
        
        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth < threshold) {
          sumX += x;
          sumY += y;
          sumZ += rawDepth;
          count++;
        }
      }
    }
    // As long as we found something
    if (count > 50) {
      loc = new PVector(sumX/count, sumY/count);
      minZ = min(sumZ/count, minZ);
      maxZ = max(sumZ/count, maxZ);
      intensity = map(sumZ/count, minZ, maxZ, 1, 0);
      touching = true;
    }else{
      loc = new PVector(0, 0);
      intensity = 0;
      touching = false;
    }
    if(maxZ>minZ+10) maxZ-=1;
    if(minZ<maxZ-10) minZ+=1;

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    PImage img = kinect.getDepthImage();

    // Being overly cautious here
    if (depth == null || img == null) return;

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for (int x = 0; x < kinect.width; x++) {
      for (int y = 0; y < kinect.height; y++) {

        int offset = x + y * kinect.width;
        // Raw depth
        int rawDepth = depth[offset];
        int pix = x + y * display.width;
        if (rawDepth < threshold) {
          // A red color instead
          display.pixels[pix] = color(150, 50, 50);
        } else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();

    // Draw the image
    image(display, 0, 0);
    
    println(cropX);
    println(cropY);
    println(cropWidth);
    println(cropHeight);
    println("-----");
    fill(0, 0, 0, 100);
    rect(0, 0, kinect.width, cropY);//top
    rect(0, cropY, cropX, cropHeight-cropY);//left
    rect(0, cropHeight, kinect.width, kinect.height-(cropHeight-cropY)-cropY);//bottom
    rect(cropWidth, cropY, kinect.width-cropWidth, cropHeight-cropY);//right
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
}