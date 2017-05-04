class Regiao {

  PImage img;
  PImage background;
  boolean pressed = false;
  
  int soundAdded = 0;
  int currentSound = 0;
  SoundFile[] sounds = new SoundFile[2];
  
  Main main;
  
  Regiao(Main main, String url) {
    this.main = main;
    img = loadImage(url);
    background = loadImage("background.jpg");
    background.mask(img);
  }
  
  void addSound(String path){
    if(soundAdded>=sounds.length){
      println("Max sound already added");
    }else{
      sounds[soundAdded] = new SoundFile(main, path);
      soundAdded++;
   }
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
    sounds[currentSound].play();
  }
  
  void onRelease(){
    pressed = false;
    sounds[currentSound].stop();
    currentSound++;
    if(currentSound>=sounds.length){
      currentSound = 0;
    }
  }
}