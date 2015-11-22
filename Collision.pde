
// This tests all pairs of cars, if they touch, increment damage and move apart

void resolveCollisions() {
  for (GridKey key : grid.map.keySet()) {
    ArrayList<Car> list = grid.map.get(key);
    if (list != null) {
      intraListCollision(list);
      interListCollision(list, grid.map.get(key.next(-1, 1)));
      interListCollision(list, grid.map.get(key.next(0, 1)));
      interListCollision(list, grid.map.get(key.next(1, 1)));
      interListCollision(list, grid.map.get(key.next(1, 0)));
    }
  }
}

void intraListCollision(ArrayList<Car> list) {
  for (int i = 0; i < list.size(); ++i) {
    for (int j = i + 1; j < list.size(); ++j) {
      testCollision(list.get(i), list.get(j));
    }
  }
}

void interListCollision(ArrayList<Car> list1, ArrayList<Car> list2) {
  if (list2 == null) return;
  for (Car a : list1) {
    for (Car b : list2) {
      testCollision(a, b);
    }
  }
}


void testCollision(Car a, Car b) {
  a.driver.makeAware(b);  
  b.driver.makeAware(a);
  PVector axis = new PVector();
  float dist = separatingAxis(axis, a, b);
  if (dist < 0) {
    
    // todo - push apart and assign damage
    
    ++a.damage;
    ++b.damage;
    float kick = 0.35;    // set to 0.5 for max correction
    a.pos.add(PVector.mult(axis, -dist * kick));
    b.pos.add(PVector.mult(axis, dist * kick));
  }
}



// Returns the distance between A and B, (negative, if overlap).
// NOTE:  the "axis" is OUTPUT unit vector (from B to A).
float separatingAxis(PVector axis, Car a, Car b) {  
  float s = abs(sin(a.angle - b.angle));
  float c = abs(cos(a.angle - b.angle));
  float da0 = 0.5 * (b.length * c + b.width * s + a.length);
  float da1 = 0.5 * (b.length * s + b.width * c + a.width);
  float db0 = 0.5 * (a.length * c + a.width * s + b.length);
  float db1 = 0.5 * (a.length * s + a.width * c + b.width);
  PVector a0 = a.direction();
  PVector a1 = new PVector(-a0.y, a0.x);
  PVector b0 = b.direction();
  PVector b1 = new PVector(-b0.y, b0.x);
  PVector sep = PVector.sub(a.pos, b.pos);
  
  float t = a0.dot(sep); //<>//
  float bestSep = t - da0;
  PVector bestAxis = a0;
  float sign = 1;
  if (bestSep < -t - da0) {
    bestSep = -t - da0;    bestAxis = a0;    sign = -1;
  }
  
  t = a1.dot(sep);   
  if (bestSep < t - da1) {
    bestSep = t - da1;    bestAxis = a1;    sign = 1;
  }
  if (bestSep < -t - da1) {
    bestSep = -t - da1;    bestAxis = a1;    sign = -1;
  }
  
  t = b0.dot(sep);   
  if (bestSep < t - db0) {
    bestSep = t - db0;    bestAxis = b0;    sign = 1;
  }  
  if (bestSep < -t - db0) {
    bestSep = -t - db0;    bestAxis = b0;    sign = -1;
  }
  
  t = b1.dot(sep);   
  if (bestSep < t - db1) {
    bestSep = t - db1;    bestAxis = b1;    sign = 1;
  }  
  if (bestSep < -t - db1) {
    bestSep = -t - db1;    bestAxis = b1;    sign = -1;
  }
  
  axis.set(bestAxis.x * sign, bestAxis.y * sign);
  return bestSep;
}