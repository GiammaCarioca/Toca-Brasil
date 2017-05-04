class Regiao {

  PImage img;
  PImage background;
  boolean pressed = false;
  
  Regiao(String url) {
    img = loadImage(url);
    background = loadImage("background.jpg");
    background.mask(img);

  }
  
  boolean jaTocou = false;
  boolean tocou(float x, float y) {
   float grey = red(img.get((int)x, (int)y));
   if(grey>125){
     if(jaTocou==false){
       jaTocou = true;
       onPress();
     }
     return true;
   }else{
     if(jaTocou==true){
       jaTocou = false;
       onRelease();
     }
     return false;
   }
  }
  
  void onPress(){
    pressed = true;
  }
  
  void onRelease(){
    pressed = false;
  }
}