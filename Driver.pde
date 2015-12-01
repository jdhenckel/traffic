
// The driver is the one that steers the car

class Driver implements Convertible {
  Car car;
  Road currentRoad;
  int offRoad;    // how long this driver has been off any road
  float maxAccel = 12;  // about .5g is typical (note 1g == 22 cubits/sec/sec)
  float maxDecel = 50;  // about 1g is max brake decel
  float maxVel = 60;    // cubits per sec (aka mph)
  float maxVelOffRoad = 25;
  float turnRate = .15;
  float followTime = 2;  // seconds
  float followDist = 16;  // cubits
  ArrayList<Car> awareList;
  PVector nextStart;

  // Driver cannot be created without a car
  Convertible create() { return null; }
  
  void convert(Target tar) {
    maxVel = tar.aFloat("maxVel", maxVel);
  }
  
  Driver(Car car) {
    this.car = car;
    awareList = new ArrayList<Car>();
  }

  
  // This is the MAIN function for the driver
  void steer() {
    followTheRoad();
    lookAhead();
    reduceAwareList();
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
    float d = v.dist(car.pos);
    if (d < 2) offRoad = 0;
    v.sub(car.pos);    
    if (d < 20) {
      d /= 20;
      v.mult(d).add(PVector.mult(currentRoad.direction, 1 - d));
    }
    turnToward(v);
  }
  
  
  // Add a car to the awareList, if it isn't already on the list
  void makeAware(Car c) {
    if (!awareList.contains(c))
      awareList.add(c);
  }


  // Pick a random direction and look for cars and add them to the awareList
  void lookAhead() {
    int radius = (int)(stoppingDistance() * 2 * grid.invGap);
    float angle = car.angle + random(-1, 1);
    Neighborhood nh = grid.getNeighborhood(car).ray(radius, angle);
    for (Car c : nh) {
      makeAware(c);
    }
  }
  
  
  void adjustMySpeed() {
    // Set my default target speed based on terrain conditions.
    float targetSpeed = maxVel;
    if (offRoad > 10) 
      targetSpeed = maxVelOffRoad;
    PVector vel = car.velocity();
    PVector cardir = car.direction();
    
    // Look at all the cars that I am aware of, and decrease my targetSpeed as required.
    for (Car c: awareList) {  
      PVector sep = PVector.sub(c.pos, car.pos);
      PVector cdir = c.direction();
      float d = sep.mag();
      // Test if the other car is in front of me, and going the same direction
      if (cdir.dot(cardir) > .95 && sep.dot(cardir) > 0.95 * d) {
        if (d < min(followTime * car.speed, followDist)) {
          targetSpeed = min(targetSpeed, c.speed - 2);
        }
        else {
          targetSpeed = min(targetSpeed, c.speed + 1);
        }
        continue;
      }
      // Test if other car is going to collide with me
      PVector relVel = c.velocity().sub(vel);
      float relSpeed = relVel.mag();
      if (relSpeed > 1) {
        PVector dir = PVector.div(relVel, relSpeed);
        float moveDist = -sep.dot(dir);
        float nearDist = PVector.mult(dir,moveDist).add(sep).mag();
        // Test if direction is near parallel
        if (abs(cdir.dot(cardir)) > .95 && nearDist > car.width + 1) {
          continue;
        }
        float minDist = 1 + car.width + abs(sin(sumAngles(car.angle, -c.angle)) * (car.length * 2 - car.width) * .5);
        if (nearDist < minDist) {
          // if the other car is closer to the point of impact than I am, then I should yeild.
          float a = PVector.add(cdir, cardir).dot(sep);
          if (a > 0)
            targetSpeed = 0;
        }
      }
    }       
    targetSpeed = max(targetSpeed, 0); // make sure not negative
    car.speed += max(-maxDecel / fps, min((targetSpeed - car.speed), maxAccel / fps));
  }
  
  
  // Only keep awareness of cars that are in front of me and within my stopping distance
  void reduceAwareList() {
    float d = max(stoppingDistance(), 20);
    PVector front = car.direction().mult(d*.9).add(car.pos);
    d *= d;
    for (int i = awareList.size(); i --> 0; ) {
      Car c = awareList.get(i);
      if (c.isDead || PVector.sub(c.pos, front).magSq() > d)
        awareList.remove(i);
    }
  }
  

  // Return the best case scenario for stopping distance, given current speed
  float stoppingDistance() {
    return car.speed*car.speed/(2*maxDecel);
  } //<>//


  void draw() {
    // For debugging stuff
    if (!car.isSpecial) return;    
    stroke(64,98,0);
    for (Car c:awareList) {
        line(car.pos.x, car.pos.y, c.pos.x, c.pos.y);
    }
    // draw circle
    float d = stoppingDistance();
    PVector front = car.direction().mult(d*.9).add(car.pos);
    noFill();
    ellipse(front.x, front.y, d*2, d*2);    
    int radius = (int)(d*2*grid.invGap);
    float angle = car.angle;
    Neighborhood nh = grid.getNeighborhood(car).ray(radius, angle);
    nh.draw();
  }


  void turnToward(PVector dir) {
    float a = dir.heading();   
    float da = sumAngles(a, -car.angle);
    car.angle = sumAngles(car.angle, max(-turnRate, min(da, turnRate)));
  }

  void pickAnotherRoad() {
    float best = 5;
    if (nextStart==null) {
      nextStart = car.pos;
      best = pow(2,offRoad);
    }
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
    nextStart = (nearest != null) ? nearest.end() : null;
    currentRoad = nearest;
  }  
 
}