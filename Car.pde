
class Car {
  PVector pos;
  float angle;
  float speed;
  float damage;
  float age;
  boolean isDragging;
  color paint;
  PVector destination;
  float width, length;
  Driver driver;
  int neighborCount;
  
  Car(float x, float y) {
    pos = new PVector(x, y); //<>//
    angle = 1;
    speed = 50 + random(10);
    width = 4;
    length = 7;
    driver = new Driver(this);  
    paint = color(random(0, 255), random(0, 255), random(0, 255));
  }  
  
  void draw() {
    pushMatrix();
    noStroke();
    fill(paint);
    translate(pos.x, pos.y);
    rotate(angle);
    rect(0, 0, length, width);
    fill(0, 125, 255);  // color the wind shield
    rect(length/6, 0, length/5, width-2); // draw the ws
    popMatrix();
    
    driver.draw(); //<>//
    
    // draw lines to neighbors (for debugging)
    stroke(200,0,0);
    neighborCount = 0;
    for (Car n : grid.getNeighborhood(this)) {
     if (isDragging) line(pos.x, pos.y, n.pos.x, n.pos.y);
     if (PVector.sub(pos,n.pos).magSq() < 400)
      ++neighborCount;
    }
  }
  
  void stepTime(float dt) { //<>//
    if (isDragging) {
      angle += 2 * dt;    // slowly spin whilst being dragged
    }
    else {
      PVector vel = new PVector(speed * cos(angle), speed * sin(angle));
      pos.add(vel.mult(dt));
    }
  }
}