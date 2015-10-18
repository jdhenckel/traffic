
class Car {
  PVector pos;
  float angle;
  float speed;
  float damage;
  float age;
  PVector destination;
  float width, length;
  ArrayList<Car> neighbor;
  Road currentRoad;
  
  Car(float x, float y) {
    pos = new PVector(x, y);
    angle = 1;
    speed = 10;
    width = 5;
    length = 10;
    neighbor = new ArrayList<Car> ();
  }  
  
  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    rect(0, 0, length, width);
    popMatrix();
  }
  
  void steer() {
    // todo - add AI here
    if (random(20) < 1) angle += random(-.5, .5);
  }
  
  void stepTime(float dt) {
    PVector vel = new PVector(speed * cos(angle), speed * sin(angle));
    pos.add(vel.mult(dt));
  }
}