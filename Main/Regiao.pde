class Regiao {

  PImage img;
  PImage background;
  boolean pressed = false;
  boolean toggle = false;
  color col;
  
  int soundAdded = 0;
  int currentSound = 0;
  ArrayList<AudioPlayer> sounds = new ArrayList<AudioPlayer>();
  float amplitude;
  float maxAmplitude = 0;
  
  Main main;
  
  Regiao(Main main, String url, color col) {
    this.main = main;
    this.col = col;
    img = loadImage(url);
    background = loadImage("background.jpg");
    background.mask(img);
  }
  
  void update(){
    if(toggle) {
      amplitude = sounds.get(currentSound).left.level();
      maxAmplitude = max(maxAmplitude, amplitude);
      amplitude /= maxAmplitude;
    }
  }
  
  void addSound(String path){
    sounds.add(main.minim.loadFile(path));
    sounds.get(soundAdded).setGain(-60);
    sounds.get(soundAdded).loop();
    soundAdded++;
  }
  
  boolean tocouParticle(float x, float y) {
   return red(img.get((int)x, (int)y))>125;
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
    toggle = !toggle;
    if(toggle){
      sounds.get(currentSound).setGain(0);
    }else{
      maxAmplitude = 0;
      sounds.get(currentSound).setGain(-60);
      currentSound++;
      if(currentSound>=sounds.size()){
        currentSound = 0;
      }
    }
  }
  
  void onRelease(){
    pressed = false;
  }
}