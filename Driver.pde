
// The driver is the one that steers the car

class Driver {
  Car car;
  Road currentRoad;
  int offRoad;    // how long this driver has been off any road

  Driver(Car car) {
    this.car = car;
    offRoad = 0;
  }

  void steer() {
    ++offRoad;
    if (car.isDragging) {
      currentRoad = null; 
      return;
    }
    // follow a road to the end, and then pick a new road
    if (currentRoad == null || currentRoad.isDead) {
      pickAnotherRoad();
    }
    if (currentRoad == null) {
      // no roads! drive in a circle
      car.angle = sumAngles(car.angle, random(0.01,0.02));
      return;
    }
    PVector v = currentRoad.nearestPoint(car.pos);
    if (currentRoad.end().dist(v) < min(currentRoad.len - 1, 20)) {
      currentRoad = null;
      return;
    }
    offRoad = 0;
    float d = v.dist(car.pos);
    v.sub(car.pos);    
    if (d < 20) {
      d /= 20;
      v.mult(d).add(PVector.mult(currentRoad.direction, 1 - d));
    }
    turnToward(v);
  }

  void draw() {
    // For debugging stuff
 /*  
     if (currentRoad != null) {
        PVector v = currentRoad.nearestPoint(pos);
        stroke(64,98,0);
        line(pos.x, pos.y, v.x, v.y);
      }  */
  }

  void turnToward(PVector dir) {
    float turnRate = .15;
    float a = dir.heading();   
    float da = sumAngles(a, -car.angle);
    car.angle = sumAngles(car.angle, max(-turnRate, min(da, turnRate)));
  }

  
  void pickAnotherRoad() {
    float best = offRoad > 10 ? 1e9f : 50;
    int seen = 0;
    Road nearest = null;
    for (int i = 0; i < roadList.size(); ++i) {
      Road r = roadList.get(i);
      if (r != currentRoad) {
        PVector v = r.start;
        float d = v.dist(car.pos);
        float dot = PVector.fromAngle(car.angle).dot(r.direction);
        if (d <= best + 10 && dot > -0.9 && random(seen + .99) < 1) {
          best = d;
          nearest = r;
          ++seen;
        }
      }
    }
    currentRoad = nearest;
  }  
 
}