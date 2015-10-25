/*
  Traffic Simulator -- Started Oct 2015, John and Quinn Henckel

  Use keys WASD to pan, 
  arrows to rotate and zoom. 
  R = reset, space = pause, z = step, c/v = mode
  Esc = quit
  
  The unit of measure is a cubit, which is 18 inches. Conveniently
  60 cubits per second is about 61 miles per hour. 
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

//----------------------------
void setup() {
  size(800, 600); 
  rectMode(CENTER);
  load();  
}

void load() {
  // make a bunch of cars and roads
  for (int i = 0; i < 50; ++i) 
    carList.add(new Car(random(-100,100), random(-100,100)));
  setup1();
} //<>//


void draw() {
  lookAtKeys();
  generatePairs();
  steerCars();
  stepTime();
  beginRender();
  drawRoads();
  drawCars(); 
  endRender();
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
  if (inputMode==1) text("CAR EDIT MODE", width*0.45, height*0.1);
  if (inputMode==2) text("ROAD EDIT MODE", width*0.44, height*0.1);
  text("num cars = "+carList.size(), x, y+=dy);
  text("num roads = "+roadList.size(), x, y+=dy);
  text("fps = "+toStr(fps)+(pause?" PAUSE":""), x, y+=dy);
  text("zoom = "+viewZoom, x, y+=dy);
  text("center = ("+toStr(viewCenter.x)+", "+toStr(viewCenter.y)+")", x, y+=dy);
  text("key:"+keydump(), x, y+=dy);
  text("pause = "+pause, x, y+=dy);
  String[] mode = {"normal","CAR","ROAD"};
  text("mode = "+mode[inputMode], x, y+=dy);
  text("click = ("+toStr(mouseDown.x)+", "+toStr(mouseDown.y)+")", x, y+=dy);
  if (singleStep) pause = true;
}

String keydump() {
  String s = "";
  for (int i : keyList) s += ", "+i;
  return s;
}