/*
  Traffic Simulator -- Started Oct 2015, John and Quinn Henckel

  Use keys WASD to pan, 
  arrows to rotate and zoom. 
  R = reset, space = pause, z = step, c/v = mode
  Esc = quit
  
  You can use any units you want, but recommend a cubit, which is 18 inches,
  because conveniently 60 cubits per second is about 61 miles per hour. 
*/
ArrayList<Car> carList = new ArrayList<Car>();
ArrayList<Road> roadList = new ArrayList<Road>();
long prevTime = 0;
float fps = 60;
boolean debug = true;
PVector viewCenter = new PVector(0, 0);
float viewZoom = 1;
float viewAngle = 0;
float viewTilt = PI/2;
boolean pause = false;
boolean singleStep = false;
boolean use3D;
int inputMode = 0;   // 1=car, 2=road
Grid grid;

//----------------------------
void setup() {
  // uncomment one of these two lines
  //size(1000, 750, P3D); use3D = true;
  size(1000,750);  use3D = false;
  rectMode(CENTER);
  load();  
}

void load() {
  randomSeed(4);
  // make a bunch of cars and roads
  for (int i = 0; i < 140; ++i) 
    carList.add(new Car(random(-100, 100), random(-100, 100), false));
  setup2();
}
 //<>//
void draw() {
  markBegin();
  lookAtKeys();      mark();
  generatePairs();   mark();
  steerCars();       mark();
  stepTime();        mark();
  beginRender();
  drawRoads();       mark();
  drawCars();        mark();
  endRender();       mark();
}
 //<>//

void generatePairs() {
  grid = new Grid(20);
  for (Car c : carList) 
    grid.add(c);
}

void steerCars() {
  if (!pause) for (Car c : carList) c.driver.steer();
}

void stepTime() {
  long t = System.nanoTime();
  float dt = (t - prevTime) / 1e9f;
  prevTime = t;
  // smooth out the fps
  fps = fps*.99 + .01/dt;
  if (!pause) {
    for (Car c : carList) 
      c.stepTime(1 / fps);  
  }
}

void beginRender() {
  background(43, 64, 0);       // COLOR OF THE GRASS
  if (use3D) {
    PVector tilt = PVector.fromAngle(viewTilt).mult(500 / viewZoom);
    println(" tilt " + tilt.x + ", " + tilt.y);
    PVector eye = PVector.fromAngle(viewAngle).mult(tilt.x);
    camera(eye.x, eye.y, tilt.y, // eyeX, eyeY, eyeZ
           viewCenter.x, viewCenter.y, 0.0, // centerX, centerY, centerZ
           0.0, 1.0, 0.0); // upX, upY, upZ
  }
  else {
    translate(.5*width, .5*height); 
    rotate(viewAngle);
    scale(viewZoom, -viewZoom);   // flip y axis
    translate(viewCenter.x, viewCenter.y);
  }
}

void drawRoads() {
  grid.draw();
  for (Road r : roadList) r.draw();
}

void drawCars() {
  PVector a = viewToWorld(0,0); // top left corner of the viewport
  PVector b = viewToWorld(width,0);
  PVector c = viewToWorld(width,height); //<>//
  PVector d = viewToWorld(0,height);
  for (Car car : carList) {
    if (isCW(a,b,car.pos) && isCW(b,c,car.pos) && isCW(c,d,car.pos) && isCW(d,a,car.pos))
      car.draw();
  }
}

void endRender() {
  drawHUD();
  if (singleStep) pause = true;
}