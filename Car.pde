
class Car {
  PVector pos;
  float angle;
  float speed;
  float damage;
  float age;
  color paint;
  PVector destination;
  float width, length;
  ArrayList<Car> neighbor;
  Road currentRoad;
  
  Car(float x, float y) {
    pos = new PVector(x, y);
    angle = 1;
    speed = 50 + random(10);
    width = 5;
    length = 10;
    neighbor = new ArrayList<Car> ();
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
    
    if (debug) {
      // draw lines to neighbors
      stroke(200,0,0);
      for (Car n : neighbor)
        line(pos.x, pos.y, n.pos.x, n.pos.y);
      if (currentRoad != null) {
        PVector v = currentRoad.nearestPoint(pos);
        stroke(0,128,250);
        line(pos.x, pos.y, v.x, v.y);
      }
    }
  }
  
  void steer() {
    // follow a road to the end, and then pick a new road
    if (currentRoad == null || currentRoad.end().dist(pos) < 20) {
      pickAnotherRoad();
    }
    PVector v = currentRoad.nearestPoint(pos);
    float d = v.dist(pos);
    v.sub(pos);    
    if (d < 20) {
      d /= 20;
      v.mult(d).add(PVector.mult(currentRoad.direction, 1 - d));
    }
    turnToward(v);
  }

  void turnToward(PVector dir) { //<>//
    float turnRate = .3;
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
        float d2 = PVector.sub(pos, v).magSq();
        if (d2 + random(10) < best) {
          best = d2;
          nearest = r;
        }
      }
    }
    if (nearest != null) 
      currentRoad = nearest;
  }  
  
  void stepTime(float dt) {
    PVector vel = new PVector(speed * cos(angle), speed * sin(angle));
    pos.add(vel.mult(dt));
  }
}