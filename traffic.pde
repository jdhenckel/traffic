/*
  Traffic Simulator -- Started Oct 2015, John and Quinn Henckel

  Use keys WASD to pan, 
  arrows to rotate and zoom. 
  R = reset, space = pause, z = step, c/v = mode
  Esc = quit
  
  You can use any units you want, but I recommend a cubit, which is 18 inches,
  because conveniently 60 cubits per second is about 61 miles per hour. 
*/
ArrayList<Car> carList = new ArrayList<Car>();
ArrayList<Road> roadList = new ArrayList<Road>();
long prevTime = 0;
float fps = 60;
boolean debug = true;
PVector viewCenter = new PVector(0, 0);
float viewZoom = 2;
float viewAngle = 0;
float viewTilt = PI/2;
boolean pause = false;
boolean singleStep = false;
boolean use3D;
int inputMode = 0;   // 1=car, 2=road
Grid grid;
int stepCounter = 0;


void World_convert(Target tar) {  
  fps = tar.aFloat("fps", fps);
  viewCenter = tar.aV2("viewCenter", viewCenter);
  viewAngle = tar.aFloat("viewAngle", viewAngle);
  use3D = tar.aBool("use3D", use3D);
  viewTilt = tar.aFloat("viewTilt", viewTilt);
  viewZoom = tar.aFloat("viewZoom", viewZoom);
  carList = tar.aObjectList("carList", carList, carTemplate);
  roadList = tar.aObjectList("roadList", roadList, roadTemplate);
}

//----------------------------
void setup() {
  // uncomment one of these two lines
  //size(1000, 750, P3D); use3D = true;
  size(1000,750);  use3D = false;
  rectMode(CENTER);
  load();  
  grid = new Grid(20);
}

void load() {
  randomSeed(5);
  // make a bunch of cars and roads
  for (int i = 0; i < 30; ++i)     carList.add(new Car(random(-200, 200), random(-200, 200), false));
  setup8();
//  carList.add(new Car(150, 0, false));  carList.add(new Car(0, 150, false));
//  carList.add(new Car(-150, 0, false));  carList.add(new Car(0, -150, true));
}

void draw() {
  if (!pause) ++stepCounter;
  markBegin();
  lookAtKeys();    
  populateGrid();       mark(); 
  resolveCollisions();  mark(); //<>//
  steerCars();       mark();
  stepTime();        mark();
  beginRender();
  drawRoads();       mark();
  drawCars();        mark();
  endRender();       
}


void populateGrid() {
  grid.clear();
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
  float e = 6 * viewZoom;  // radius of a typical car in pixels
  PVector a = viewToWorld(-e,-e); // top left corner of the viewport
  PVector b = viewToWorld(width+e,-e);
  PVector c = viewToWorld(width+e,height+e);
  PVector d = viewToWorld(-e,height+e);
  for (Car car : carList) {
    if (isInsideRectangle(car.pos,a,b,c,d))
      car.draw();
  }
}

void endRender() {
  drawHUD();
  if (singleStep) pause = true;
}