class Explosion {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  color col;

  Explosion(PVector l, color col) {
    this.col = col;
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-1,1));
    location = l.get();
    lifespan = random(20,40);
  }

  void run(PGraphics canvas) {
    update();
    display(canvas);
  }

  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan -= random(0.1,0.6);
  }

  void display(PGraphics canvas) {
    canvas.stroke(col);
    canvas.strokeWeight(2-lifespan/50);
    canvas.noFill();
    canvas.ellipse(location.x,location.y,lifespan,lifespan);
  }
  
  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}
class ExplosionSystem {
  ArrayList<Explosion> particles;
  PVector origin;

  ExplosionSystem(PVector location) {
    origin = location.get();
    particles = new ArrayList<Explosion>();
  }

  void addParticle(color col) {
    particles.add(new Explosion(origin, col));
  }

  void addParticle(float x, float y, color col) {
    particles.add(new Explosion(new PVector(x, y), col));
  }

  void run(PGraphics canvas) {
    for (int i = particles.size()-1; i >= 0; i--) {
      Explosion p = particles.get(i);
      p.run(canvas);
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}