class Regiao {

  PImage img;
   
  Regiao() {
    img = loadImage("sul.png");
  }

  boolean tocou(float x, float y) {
   float grey = red(img.get(mouseX, mouseY));
   return grey<125;
  }
}