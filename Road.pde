
class Road {
  PVector start;
  PVector direction;
  float len;
  float speedLimit;
  float damage;
  float usage;

  Road(float sx, float sy, float ex, float ey)  {
    start = new PVector(sx, sy);
    end(new PVector(ex, ey));
  }
  
  Road(PVector start, PVector end)  {
    this.start = new PVector(start.x, start.y);
    end(end);
  }
  
  void draw() {
    stroke(30);             // COLOR OF THE ROAD
    strokeWeight(9);        // WIDTH OF THE ROAD
    PVector end = end();
    line(start.x, start.y, end.x, end.y);
    strokeWeight(1);
  }
  
  // returns the nearest point on the road to given point
  PVector nearestPoint(PVector pos) {
    float d = PVector.dot(direction, PVector.sub(pos, start));
    float e = max(0, min(d, len));
    return PVector.mult(direction, e).add(start);    
  }
  
  // gets the road end
  PVector end() { 
    return PVector.add(start, PVector.mult(direction, len)); 
  }
  
  // sets the road end
  void end(PVector end) { 
    direction = PVector.sub(end, start);
    len = direction.mag();
    if (len > 0) direction.div(len);
  }
  
}