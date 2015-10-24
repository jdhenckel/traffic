
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
  ArrayList<Car> neighbor;
  Road currentRoad;
  
  Car(float x, float y) {
    pos = new PVector(x, y); //<>//
    angle = 1;
    speed = 50 + random(10);
    width = 4;
    length = 7;
    paint = randomColor();
    neighbor = new ArrayList<Car> ();
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
    
    if (debug) {
      // draw lines to neighbors
      stroke(200,0,0);
      // for (Car n : neighbor) line(pos.x, pos.y, n.pos.x, n.pos.y);
      if (currentRoad != null) {
        PVector v = currentRoad.nearestPoint(pos);
        stroke(64,98,0);
        line(pos.x, pos.y, v.x, v.y);
      }
    }
  }
  
  void steer() {
    if (isDragging) {
      currentRoad = null; return;
    }
    // follow a road to the end, and then pick a new road
    if (currentRoad == null || currentRoad.isDead) { //<>//
      pickAnotherRoad();
    }
    if (currentRoad == null) {
      // no roads! drive in a circle
      angle = sumAngles(angle, random(0.01,0.02));
      return;
    }
    PVector v = currentRoad.nearestPoint(pos);
    if (currentRoad.end().dist(v) < min(currentRoad.len - 1, 25)) {
      currentRoad = null;
      return;
    }    
    float d = v.dist(pos);
    v.sub(pos);    
    if (d < 20) {
      d /= 20;
      v.mult(d).add(PVector.mult(currentRoad.direction, 1 - d));
    }
    turnToward(v);
  }

  void turnToward(PVector dir) { //<>//
    float turnRate = .1;
    float a = dir.heading();   
    float da = sumAngles(a, -angle);
    angle = sumAngles(angle, max(-turnRate, min(da, turnRate)));
  }
  
  void pickAnotherRoad() {
    float best = 1e9f;
    Road nearest = null;
    for (int i = 0; i < roadList.size(); ++i) {
      Road r = roadList.get(i);
      if (r != currentRoad) {
        PVector v = r.nearestPoint(pos);
        float d = v.dist(pos);
        if (d < best && v.dist(r.end()) > min(r.len - 1, 25)) {
          best = d;
          nearest = r;
        }
      }
    }
    currentRoad = nearest;
  }  
  
  void stepTime(float dt) {
    if (isDragging) {
      angle += 2 * dt;    // slowly spin whilst being dragged
    }
    else {
      PVector vel = new PVector(speed * cos(angle), speed * sin(angle));
      pos.add(vel.mult(dt));
    }
  }
}