
/*
This detects when two cars overlap, and pushes them apart to remove the overlap.
This uses neighbor list of each car.
*/
class Collision {
  float angle;
  PVector dir;
  float rate;
  
  Collision(float angle, float rate) {
    this.angle = angle; this.rate = rate;
  }
  
  void resolve() {
    dir = PVector.fromAngle(angle);
    java.util.PriorityQueue<Car> queue = new java.util.PriorityQueue<Car>(carList.size(), new SortByDir(dir));
    queue.addAll(carList);
    Car car;
    while ((car = queue.poll()) != null) {
      resolveCar(car);  
    }    
  }

  void resolveCar(Car c1) {
    PVector dir1 = PVector.fromAngle(c1.angle);
    for (Car c2: c1.neighbor) {
      PVector offset = PVector.sub(c2.pos, c1.pos);
      if (dir.dot(offset) > 0) {
        PVector dir2 = PVector.fromAngle(c1.angle);
        PVector sep = dir1;
        //float dist = 
      }
    }
  }
}

class SortByDir implements java.util.Comparator<Car> {
  PVector dir;
  SortByDir(PVector dir) { this.dir = dir; }
  int compare(Car a, Car b) { return 1; }
}