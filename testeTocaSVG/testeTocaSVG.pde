PImage img;

void setup() {
  size(1024, 768);
  
  img = loadImage("sul.png");
  
}

void draw(){
  float grey = red(img.get(mouseX, mouseY));
  image(img, 0, 0);
  fill(0);
  if(grey<125){
    text("dentro", 100, 100);
  }else{
    text("fora", 100, 100);
  }
}