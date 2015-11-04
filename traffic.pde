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
float viewZoom = 1.75;
float viewAngle = 0;
boolean pause = false;
boolean singleStep = false;
int inputMode = 0;   // 1=car, 2=road
Grid grid;

//----------------------------
void setup() {
  size(800, 600); 
  rectMode(CENTER);
  load();  
}

void load() {
  randomSeed(4);
  // make a bunch of cars and roads
  for (int i = 0; i < 1400; ++i) 
    carList.add(new Car(random(-100,100), random(-100,100)));
  setup3();
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
  grid.draw();
  for (Road r : roadList) r.draw();
}

void drawCars() {
  for (Car c : carList) c.draw();
}

void endRender() {
  drawHUD();
  if (singleStep) pause = true;
}

String keydump() {
  String s = "";
  for (int i : keyList) s += ", "+i;
  return s;
}