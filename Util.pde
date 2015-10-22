//-----------------------------
// some misc utilities

// This converts float to string, and rounds it off 
String toStr(float x) {
  String s = String.valueOf(x);
  int i = s.indexOf('.');
  if (i < 0 || abs(x) < 0.9) return s;
  if (i > 5) return s.substring(0,i);
  return s.substring(0, min(s.length(), i + 2));
}

// return a + b, modulus PI
float sumAngles(float a, float b) {
  float c = a + b;
  while (c > PI) c -= 2*PI;
  while (c < -PI) c += 2*PI;
  return c;
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

void setup2() {  
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

color randomColor() {
  return rainbow(int(random(12.1)));
}

color rainbow(int n) {
  // returns 12 colors of the rainbow, 0=red, 4=green, 8=blue
  float[] t = {51,0,0,0,51,102,153,204,255,204,153,102,51,0,0,0,51,102,153,204};
  if (n < 0 || n > 11) return color(255);
  return color(t[n+8],t[n+4],t[n]);
}