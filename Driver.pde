
// The driver is the one that steers the car

class Driver {
  Car car;
  Road currentRoad;
  int offRoad;    // how long this driver has been off any road
  float maxAccel = 10;  // about .5g is typical 
  float maxDecel = 20;  // about 1g is max brake decel
  float maxVel = 60;    // cubits per sec (aka mph)
  float maxVelOffRoad = 25;
  float turnRate = .15;
  ArrayList<Car> awareList;
  //  TODO - change to "awareList" that is many cars in a list that is maintained by sweeping cone.
  
  Driver(Car car) {
    this.car = car;
    offRoad = 0;
    awareList = new ArrayList<Car>();
  }
  
  void steer() {
    followTheRoad();
    adjustMySpeed();
  }

  void followTheRoad() {
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
  
  
  void makeAware(Car c) {
    if (!awareList.contains(c))
      awareList.add(c);
  }
  
  
  void adjustMySpeed() {
    float targetSpeed = maxVel;
    if (offRoad > 10) 
      targetSpeed = maxVelOffRoad;
    
    if (car.damage > 5) {
      car.accel = -maxDecel;
      car.damage = 0;
    }
    else if (offRoad > 10) {
      if (car.speed < maxVelOffRoad) car.accel = maxAccel;
    }
    else {
      if (car.speed < maxVel) car.accel = maxAccel;
    }    
  }
  
  
  
  
/*********************  
  void adjustMySpeed_OLDCODE() {
    // This does not change the speed, but it sets the 'accel' so the stepTime will do it
    float topSpeed = maxVel;
    if (offRoad > 10) 
      topSpeed = maxVelOffRoad;
    checkForDanger();
    if (dangerCar != null) {
      // safe speed = maxDecel * time.  But allow a little extra time
      //float stopat = car.speed * dangerTime;
      float safeSpeed = 0; 
      //sqrt(max(0, 2 * stopat * maxDecel));
      // max(0, maxDecel * (dangerTime - .25));
      topSpeed = min(topSpeed, safeSpeed);
    }
    car.accel = max(-maxDecel, min((topSpeed - car.speed) * fps, maxAccel));
    if (dangerCar != null && car.isSpecial)
      println("found danger " + stepCounter+ " p=" + dangerCar.paint + " a="+car.accel + 
      " toi="+toStr(dangerTime) + " top="+topSpeed+" speed="+car.speed +" d="+dangerDist);
  }
  
  Car dangerCar;   // a car that we might hit, or null if none
  float dangerDist;
  float dangerTime;
  
  // Sets the dangerCar, dangerDistance, etc
  void checkForDanger() {
    dangerCar = null;
    dangerDist = 100;
    dangerTime = 100;   // ????
    float range = 5 * stoppingDistance() * grid.invGap + 1;
    Neighborhood nh = grid.getNeighborhood(car).cone((int) range); //<>//
    float small = .00001;
    PVector vel = car.velocity();
    for (Car c : nh) {
      PVector sep = PVector.sub(c.pos, car.pos);
      if (sep.dot(vel) < 0) continue;  // ignore stuff behind me
      PVector relVel = c.velocity().sub(vel);
      float relSpeed = relVel.mag();
      if (relSpeed < small) {
        // check danger based on distance only, and response time
        // todo - also check when it isnt small??
      } 
      else {
        PVector dir = PVector.div(relVel, relSpeed);
        float moveDist = -sep.dot(dir);
        float base = PVector.mult(dir,moveDist).add(sep).mag();
        float minBase = car.width * 100;                    // ERROR ?>  
        // + abs(sin(sumAngles(car.angle, -c.angle)) * (car.length - car.width) * .5);
        if (base < minBase) {
          // found danger!
          float time = moveDist / relSpeed;
          if (time < dangerTime) {
            dangerTime = time;
            dangerDist = moveDist;       // hmm, this isn't really useful
            dangerCar = c;
            
            if (car.isSpecial) {
              addDebugLine(car.pos, car.velocity().mult(time).add(car.pos));
            }
          }
        }
      } 
    }
  }
  
  
  float stoppingDistance() {
    // return the best case scenario for stopping distance, given current speed
    return car.speed*car.speed/(2*maxDecel);
  }
  
  float timeToImpact(Car c) {
    // compute how many seconds it will be until we hit c.  Or return 1000 if never.
    return 1000;
  }
*****************/

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