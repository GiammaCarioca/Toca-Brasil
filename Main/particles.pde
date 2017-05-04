class Particles {
  int numMov = 500;
  Mover[] movers = new Mover[numMov];
  PVector attract = new PVector(-1, -1);
  
  void setup() {
    for (int i=0; i<numMov; i++) {
      movers[i] = new Mover();
      movers[i].id = i;
    }
  }
  
  void draw(PGraphics canvas) {
    for (int i=0; i<numMov; i++) {
      movers[i].run(attract, canvas);
    }
    
    for (int i=0;i<numMov;i++) {
      for (int j=i+1;j<numMov;j++) {
        float dist = dist(movers[i].location.x,movers[i].location.y,movers[j].location.x,movers[j].location.y);
        
        if(i!=j&&dist<=100) {
          canvas.stroke(255,50);
          canvas.line(movers[i].location.x,movers[i].location.y, -1,movers[j].location.x,movers[j].location.y, -1);
        }
      }
    }
  }
}
class Mover {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float topSpeed, sz, d=0;
  int id;
  PVector dir = new PVector();
  Boolean changeDir = false;

  Mover() {
    sz = 5;
    location = new PVector(random(sz, width-sz), random(sz, height-sz));
    velocity = new PVector(random(-1, 1), random(-1, 1));
    acceleration = new PVector(random(-0.01, 0.01), random(-0.02, 0.02));
    topSpeed = 3;
  }

  void run(PVector pos, PGraphics canvas) {
    update(pos);
    checkEdges();
    display(canvas);
  }

  void update(PVector pos) {
    float distance = 101;
     if(pos.x!=-1){
      dir = PVector.sub(pos, location);
      dir.normalize();
      distance = pos.dist(location);
      if (distance<150) {
        d = map(distance, 0, 150, 0.2, 0.01);
      }
     }
    if (distance>100) {
      d = 0;
      if(velocity.x*velocity.x+velocity.y*velocity.y>1) velocity.mult(.99);;
    }
     if(pos.x!=-1){
      dir.mult(d);
      acceleration = dir;

      velocity.add(acceleration);
      velocity.limit(topSpeed);
     }
    location.add(velocity);
  }

  void display(PGraphics canvas) {
    canvas.stroke(255);
    canvas.point(location.x, location.y, -1);
    //ellipse(location.x, location.y, sz, sz);
  }

  void checkEdges() {
    if (location.x<sz/2 || location.x > width-sz/2) {
      velocity.x *= -1;
      acceleration.x *= -1;
    }
    if (location.y<sz/2 || location.y>height-sz/2) {
      velocity.y *= -1;
      acceleration.y *= -1;
    }
  }
}