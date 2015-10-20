/*
  Traffic Simulator -- Started Oct 2015, John and Quinn Henckel

  Use keys WASD to pan, <> to zoom.
*/
ArrayList<Car> carList = new ArrayList<Car>();
ArrayList<Road> roadList = new ArrayList<Road>();
long prevTime = 0;
float fps = 60;
boolean debug = true;
PVector viewCenter = new PVector(0, 0);
float viewZoom = 1;
IntList keyList = new IntList();

void setup() {
  size(800, 600); 
  rectMode(CENTER);
  load();  
}

void load() {
  for (int i = 0; i < 10; ++i) carList.add(new Car(i*40-100, 70));
  roadList.add(new Road(0, 11, 150, 0));
  roadList.add(new Road(150, 0, 150, 150));
  roadList.add(new Road(150, 150, 0, 150));
  roadList.add(new Road(0, 150, 0, 0));
  roadList.add(new Road(0, 0, -100, 200));
  roadList.add(new Road(0, 0, 0, -150));
  roadList.add(new Road(-100, 200, 0, 150));
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
  for (int i : keyList) {
    switch (i) {
      case 'a': viewCenter.x -= panRate; break;
      case 's': viewCenter.y -= panRate; break;
      case 'd': viewCenter.x += panRate; break;
      case 'w': viewCenter.y += panRate; break;
      case ',': viewZoom /= zoomRate; break;
      case '.': viewZoom *= zoomRate; break;
    }
  }
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
  for (Car c : carList) c.steer();
}

void stepTime() {
  long t = System.nanoTime();
  float dt = (t - prevTime) / 1e9f;
  prevTime = t;
  fps = fps*.99 + .01/dt;
//  dt = max(0.01, min(dt, 0.1));     // clamp dt from 10 to 100 fps 
  for (Car c : carList) c.stepTime(1/60.f);  
}

// This converts float to string, and rounds it off 
String toStr(float x) {
  String s = String.valueOf(x);
  int i = s.indexOf('.');
  if (i < 0 || abs(x) < 0.9) return s;
  if (i > 5) return s.substring(0,i);
  return s.substring(0, min(s.length(), i + 2));
}

void beginRender() {
  background(180);
  scale(viewZoom, -viewZoom);   // flip y axis
  translate(viewCenter.x + .5*width/viewZoom, 
            viewCenter.y - .5*height/viewZoom);  // move origin to center
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
  fill(0);
  text("num cars = "+carList.size(), x, y+=dy);
  text("num roads = "+roadList.size(), x, y+=dy);
  text("fps = "+toStr(fps), x, y+=dy);
  text("zoom = "+viewZoom, x, y+=dy);
  text("center = ("+toStr(viewCenter.x)+", "+toStr(viewCenter.y)+")", x, y+=dy);
  text("key:"+keydump(), x, y+=dy);
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