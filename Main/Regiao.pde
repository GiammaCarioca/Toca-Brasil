class Regiao {

  PImage img;
  PImage background;
  boolean pressed = false;
  color col;
  
  int soundAdded = 0;
  int currentSound = 0;
  //SoundFile[] sounds = new SoundFile[2];
  //Amplitude amp;
  float amplitude;
  
  Main main;
  
  Regiao(Main main, String url, color col) {
    this.main = main;
    this.col = col;
    img = loadImage(url);
    background = loadImage("background.jpg");
    background.mask(img);
    //amp = new Amplitude(main);
  }
  
  void update(){
    //if(pressed) amplitude = amp.analyze();
  }
  
  void addSound(String path){
    /*
    if(soundAdded>=sounds.length){
      println("Max sound already added");
    }else{
      sounds[soundAdded] = new SoundFile(main, path);
      sounds[soundAdded].loop();
      sounds[soundAdded].amp(0);
      soundAdded++;
   }
   */
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
    //sounds[currentSound].amp(1);
    //amp.input(sounds[currentSound]);
  }
  
  void onRelease(){
    pressed = false;
    /*
    sounds[currentSound].amp(0);
    currentSound++;
    if(currentSound>=sounds.length){
      currentSound = 0;
    }
    */
  }
}