/*
  Traffic Simulator -- Started Oct 2015, John and Quinn Henckel

  Use keys WASD to pan, 
  arrows to rotate and zoom. 
  R = reset, P = pause, o = step
  Esc = quit
  
*/
ArrayList<Car> carList = new ArrayList<Car>();
ArrayList<Road> roadList = new ArrayList<Road>();
long prevTime = 0;
float fps = 60;
boolean debug = true;
PVector viewCenter = new PVector(0, 0);
float viewZoom = 1;
float viewAngle = 0;
IntList keyList = new IntList();
boolean pause = false;
boolean singleStep = false;

//----------------------------
void setup() {
  size(800, 600); 
  rectMode(CENTER);
  load();  
}

void load() {
  // make a bunch of cars and roads
  for (int i = 0; i < 10; ++i) carList.add(new Car(i*40-100, 70));
  setup2();
}


void draw() {
  lookAtKeys();
  generatePairs();
  steerCars(); //<>//
  stepTime();
  beginRender();
  drawRoads();
  drawCars(); 
  endRender();
}


void lookAtKeys() {
  float panRate = -15/viewZoom;
  float zoomRate = 1.03;
  float turnRate = .04;
  PVector move = new PVector(0, 0);
  for (int i : keyList) {
    switch (i) {
      case 'a': move.x -= panRate; break;
      case 's': move.y -= panRate; break;
      case 'd': move.x += panRate; break;
      case 'w': move.y += panRate; break;
      case 38 : viewZoom *= zoomRate; break;
      case 40 : viewZoom /= zoomRate; break;
      case 37 : viewAngle = sumAngles(viewAngle, turnRate); break;
      case 39 : viewAngle = sumAngles(viewAngle, -turnRate); break;
      case 'r': viewAngle = 0; viewCenter.set(0,0); viewZoom = 1; break;
    }
  }
  viewCenter.add(move.rotate(viewAngle));
}

void generatePairs() {
  float NEARBY = 20;
  for (Car c : carList)
    c.neighbor.clear();
  // todo - replace this loop with something faster
  for (int i = 0; i < carList.size() - 1; ++i) {
    Car icar = carList.get(i);
    for (int j = i + 1; j < carList.size(); ++j) {
      Car jcar = carList.get(j);
      float dist = icar.pos.dist(jcar.pos);
      if (dist < NEARBY) {
        icar.neighbor.add(jcar);
        jcar.neighbor.add(icar);
      }
    }
  }
}

void steerCars() {
  if (!pause) for (Car c : carList) c.steer();
}

void stepTime() {
  long t = System.nanoTime();
  float dt = (t - prevTime) / 1e9f;
  prevTime = t;
  fps = fps*.99 + .01/dt;
  if (!pause) for (Car c : carList) c.stepTime(1/60.f);  
}

void beginRender() {
  background(43, 64, 0);       // COLOR OF THE GRASS
  translate(.5*width, .5*height); 
  rotate(viewAngle);
  scale(viewZoom, -viewZoom);   // flip y axis
  translate(viewCenter.x, viewCenter.y);
}

void drawRoads() {
  for (Road r : roadList) r.draw();
}

void drawCars() {
  for (Car c : carList) c.draw();
}

void endRender() {
  resetMatrix();   // default window scale and origin
  float x = 10;
  float y = 20;
  float dy = 15;
  fill(200);
  text("num cars = "+carList.size(), x, y+=dy);
  text("num roads = "+roadList.size(), x, y+=dy);
  text("fps = "+toStr(fps)+(pause?" PAUSE":""), x, y+=dy);
  text("zoom = "+viewZoom, x, y+=dy);
  text("center = ("+toStr(viewCenter.x)+", "+toStr(viewCenter.y)+")", x, y+=dy);
  text("key:"+keydump(), x, y+=dy);
  text("pause = "+pause, x, y+=dy);
  if (singleStep) pause = true;
}

String keydump() {
  String s = "";
  for (int i : keyList) s += ", "+i;
  return s;
}

void keyPressed() {
  int x = (key==CODED) ? keyCode : (int)key;
  if (!keyList.hasValue(x) && x != 0)
    keyList.push(x);
}

void keyReleased() {
  int x = (key==CODED) ? keyCode : (int)key;
  keyList.removeValue(x);
}

void keyTyped() {
  switch (key) {
    case 'p': singleStep = false; pause = !pause; break;
    case 'o': singleStep = true; pause = false; break;
  }
}
  
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