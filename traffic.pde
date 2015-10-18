

ArrayList<Car> carList = new ArrayList<Car>();
ArrayList<Road> roadList = new ArrayList<Road>();
long prevTime = 0;
boolean debug = true;

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
  generatePairs();
  steerCars(); //<>//
  stepTime();
  setupCamera();
  drawRoads();
  drawCars(); 
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
  dt = max(0.01, min(dt, 0.1));     // clamp dt from 10 to 100 fps 
  
  for (Car c : carList) c.stepTime(dt);  
}

void setupCamera() {
  scale(1, -1);   // flip y axis
  translate(width/2, -height/2);  // move origin to center
  background(180);
}

void drawRoads() {
  for (Road r : roadList) r.draw();
}

void drawCars() {
  for (Car c : carList) c.draw();
}