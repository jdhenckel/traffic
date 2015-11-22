//-----------------------------
// some misc utilities

// This converts float to string, and rounds it off to three significant digits 
String toStr(float x) {
  String s = String.valueOf(x);
  if (s.indexOf('e')>0) return s;
  if (s.indexOf('.')<0) return s;
  int i;
  for (i = 0; i < s.length(); ++i) {
    if (!(s.charAt(i)=='-' || s.charAt(i)=='0' || s.charAt(i)=='.')) break;
  }
  return s.substring(0, min(s.length(), max(s.indexOf('.') + 4, i + 3)));
}

// return a + b, modulus PI
float sumAngles(float a, float b) {
  float c = a + b;
  while (c > PI) c -= 2*PI;
  while (c < -PI) c += 2*PI;
  return c;
}


PVector viewToWorld(float x, float y) {
  // this takes a pixel on the window (origin top left) and maps it to world space
  PVector v = new PVector(x - .5 * width, y - .5 * height);
  v.rotate(-viewAngle);
  v.set(v.x / viewZoom, v.y / -viewZoom);
  v.sub(viewCenter);
  return v;
}


PVector worldToView(PVector pos) {
  PVector v = PVector.add(viewCenter, pos);
  v.set(v.x * viewZoom, v.y * -viewZoom);
  v.rotate(viewAngle);
  v.add(width * .5, height * .5);
  return v;
}


// Returns true if the triangle {a,b,c} is clockwise (right handed) 
boolean isCW(PVector a, PVector b, PVector c) {
  return (c.x-a.x)*(a.y-b.y)-(c.y-a.y)*(a.x-b.x) <= 0;
}

// return the car nearest to pos (and nearer than dist) or -1 if none are near
int nearbyCar(PVector pos, float dist) {
  int best = -1;
  for (int i = 0; i < carList.size(); ++i) {
    float d = carList.get(i).pos.dist(pos);
    if (d < dist) { dist = d; best = i; }
  }
  return best;
}

int nearbyRoad(PVector pos, float dist) {
  int best = -1;
  for (int i = 0; i < roadList.size(); ++i) {
    PVector p2 = roadList.get(i).nearestPoint(pos);
    float d = p2.dist(pos);
    if (d < dist) { dist = d; best = i; }
  }
  return best;
}

// snaps pos to any road start that is nearby
PVector nearbyRoadStart(PVector pos, float dist) {
  PVector best = pos;
  for (int i = 0; i < roadList.size(); ++i) {
    PVector p2 = roadList.get(i).start;
    float d = p2.dist(pos);
    if (d < dist) { dist = d; best = p2; }
  }
  return best;
}

// snaps pos to any road end point that is nearby
PVector nearbyRoadEnd(PVector pos, float dist) {
  PVector best = pos;
  for (int i = 0; i < roadList.size(); ++i) {
    PVector p2 = roadList.get(i).end();
    float d = p2.dist(pos);
    if (d < dist) { dist = d; best = p2; }
  }
  return best;
}

void setup1() {  
  roadList.add(new Road(0, 11, 150, 0));
  roadList.add(new Road(150, 0, 150, 150));
  roadList.add(new Road(150, 150, 0, 150));
  roadList.add(new Road(0, 150, 0, 0));
  roadList.add(new Road(0, 0, -100, 200));
  roadList.add(new Road(0, 0, 0, -150));
  roadList.add(new Road(-100, 200, 0, 150)); 
}

void setup4box() {  
  float w = 150;
  roadList.add(new Road(5, 5, -w, 5));
  roadList.add(new Road(-w, -5, 5, -5));
  roadList.add(new Road(w, 5, -5, 5));
  roadList.add(new Road(-5, -5, w, -5));
  roadList.add(new Road(5, -5, 5, w));
  roadList.add(new Road(-5, w, -5, -5));
  roadList.add(new Road(-5, 5, -5, -w));
  roadList.add(new Road(5, -w, 5, 5));
  roadList.add(new Road(w, -5, w, w));
  roadList.add(new Road(w, w, -5, w));
  roadList.add(new Road(5, w, -w, w));
  roadList.add(new Road(-w, w, -w, -5));
  roadList.add(new Road(-w, 5, -w, -w));
  roadList.add(new Road(-w, -w, 5, -w));
  roadList.add(new Road(-5, -w, w, -w));
  roadList.add(new Road(w, -w, w, 5));
}

void setup8() {
  float w = 150;
  roadList.add(new Road(-w, 0, w, 0));
  roadList.add(new Road(0, -w, 0, w));
  roadList.add(new Road(w, 0, 0, -w));
  roadList.add(new Road(0, w, -w, 0));
}  

void setupMerge() {
  float w = 150;
  float x = 2;
  roadList.add(new Road(x, x, -w, x));
  roadList.add(new Road(-w, -x, x, -x));
} 


color randomColor() {
  return rainbow(int(random(12.1)));
}

color rainbow(int n) {
  // returns 12 colors of the rainbow, 0=red, 4=green, 8=blue
  float[] t = {51,0,0,0,51,102,153,204,255,204,153,102,51,0,0,0,51,102,153,204};
  if (n == 12) return color(255);
  int m = Math.abs(n) % 12;
  return color(t[m+8],t[m+4],t[m]);
}