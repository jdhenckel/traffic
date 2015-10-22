
class Road {
  PVector start;
  PVector direction;
  float len;
  float speedLimit;
  float damage;
  float usage;
  
  Road(float sx, float sy, float ex, float ey)  {
    start = new PVector(sx, sy);
    direction = new PVector(ex - sx, ey - sy);
    len = direction.mag();
    if (len > 0) direction.div(len);
  }
  
  void draw() {
    stroke(30);             // COLOR OF THE ROAD
    PVector end = end();
    strokeWeight(9);
    line(start.x, start.y, end.x, end.y);
    strokeWeight(1);
  }
  
  // returns the nearest point on the road to given point
  PVector nearestPoint(PVector pos) {
    float d = PVector.dot(direction, PVector.sub(pos, start));
    float e = max(0, min(d, len));
    return PVector.mult(direction, e).add(start);    
  }

  
  PVector end() { 
    return PVector.add(start, PVector.mult(direction, len)); 
  }
  
}