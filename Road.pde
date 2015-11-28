
class Road implements Convertible {
  PVector start;
  PVector direction;
  float len;
  float speedLimit;
  float damage;
  float usage;
  boolean isDead;

  void convert(Target tar) {
    start = tar.aV2("start", start);
    direction = tar.aV2("direction", direction);
    len = tar.aFloat("len", len);
    speedLimit = tar.aFloat("speedLimit", speedLimit);
    damage = tar.aFloat("damage", damage);
  }

  Road() {}
  
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
    if (inputMode == 2) {
      // in ROAD mode, draw arrows
      stroke(255,255,0);
      float d = min(20, len/2);
      PVector m = PVector.mult(direction, (len + d)/2).add(start);
      PVector n = PVector.mult(direction, 3);
      line(m.x, m.y, m.x - direction.x * d, m.y - direction.y * d);
      line(m.x, m.y, m.x - n.x - n.y, m.y - n.y + n.x);
      line(m.x, m.y, m.x - n.x + n.y, m.y - n.y - n.x);
    }
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
    if (len > 1e-6) 
      direction.div(len);
    else { 
      float a=random(6.28); 
      direction.set(cos(a),sin(a));
    }
    len = max(2, len);      // MINIMUM ROAD LEN
  }
  
}