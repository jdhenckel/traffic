
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
    angle = random(6);
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
    if (use3D) {
      box(length, width, width/2);
    }
    else {
      rect(0, 0, length, width);
      fill(0, 125, 255);  // color the wind shield
      rect(length/6, 0, length/5, width-2); // draw the ws
    }
    popMatrix();
    
    driver.draw(); //<>//
    
    // draw lines to neighbors (for debugging)
    stroke(0); PVector f = PVector.fromAngle(angle).mult(140/viewZoom).add(pos);
      if (isDragging) line(pos.x, pos.y, f.x, f.y);
    stroke(200,0,0);
    neighborCount = 0;
    Neighborhood nn = grid.getNeighborhood(this).cone((int)(7/viewZoom));
    for (Car n : nn) {
      ++neighborCount;
    }
    if (isDragging) nn.draw();
  }
  
  void stepTime(float dt) { //<>//
    if (isDragging) {
      angle += .5 * dt;    // slowly spin whilst being dragged
    }
    else {
      PVector vel = new PVector(speed * cos(angle), speed * sin(angle));
      pos.add(vel.mult(dt));
    }
  }
}