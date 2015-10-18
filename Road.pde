
class Road {
  PVector start, end;
  float speedLimit;
  float damage;
  float usage;
  
  Road(float sx, float sy, float ex, float ey)  {
    start = new PVector(sx, sy);
    end = new PVector(ex, ey);
  }
  
  void draw() {
    line(start.x, start.y, end.x, end.y);
  }
}