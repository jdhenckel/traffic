//---------------------------
// These are all the input related functions

// There are TWO ways to read keys: as keyTyped, and as keyPress/release.  We use both in this
// program. The "typed" are for switches, like mode, pause, etc.  While the Press/release is
// for smooth controls, like Zoom, pan.  We only use press/release for the mouse buttons.

// The keyPressed adds to this list, The keyRelease removes them from the list.
IntList keyList = new IntList();
PVector mouseDown = new PVector();
int mouseDragCounter = 0;
int drug = -1;    // which car or road is being dragged
int hud = 3;
Car chaseCar;

// This is called once per frame

void lookAtKeys() {
  float panRate = -5/viewZoom;
  float zoomRate = 1.01;
  float turnRate = .01;
  PVector move = new PVector(0, 0);
  for (int i : keyList) {
    switch (i) {
      case 'a': move.x -= panRate; break;
      case 's': move.y -= panRate; break;
      case 'd': move.x += panRate; break;
      case 'w': move.y += panRate; break;
      case 'e': if (viewTilt < 1.57) viewTilt += turnRate; break;
      case 'f': if (viewTilt > .1) viewTilt -= turnRate; break;
      case 38 : viewZoom *= zoomRate; break;
      case 40 : viewZoom /= zoomRate; break;
      case 37 : viewAngle = sumAngles(viewAngle, turnRate); break;
      case 39 : viewAngle = sumAngles(viewAngle, -turnRate); break;
      case 'r': viewAngle = 0; viewCenter.set(0,0); viewZoom = 1; viewTilt=PI/2; break;
    }
  }
  viewCenter.add(move.rotate(viewAngle));
  if (chaseCar != null) {
    chaseView(chaseCar.pos, sumAngles(chaseCar.angle, -PI/2));
  }
}

void keyPressed() {
  int x = (key==CODED) ? keyCode : key;
  if (!keyList.hasValue(x) && x != 0)
    keyList.push(x);
}

void keyReleased() {
  int x = (key==CODED) ? keyCode : key;
  keyList.removeValue(x);
}

void keyTyped() {
  switch (key) {
    case ' ': singleStep = false; pause = !pause; break;
    case 'z': singleStep = true; pause = false; break;
    case 'c': inputMode = inputMode == 1 ? 0 : 1; break;
    case 'v': inputMode = inputMode == 2 ? 0 : 2; break;
    case 'x': setChaseMode(); break;
    case 'h': hud = (hud + 1) & 3; break;
    case 'q': exit();
  }
}
  

void setChaseMode() {
  // TOGGLE the chase mode
  if (chaseCar!=null) 
    chaseCar = null;
  else {    
    PVector pos = viewToWorld(mouseX, mouseY);
    int i = nearbyCar(pos, 100);
    if (i >= 0) 
      chaseCar = carList.get(i);
      chaseCar.isSpecial = true;
  }
}


void chaseView(PVector pos, float angle) {
  // Gradually change the view center and angle to match inputs
  viewCenter.add(PVector.add(pos, viewCenter).mult(-.1));
  viewAngle += sumAngles(angle, -viewAngle) * viewZoom / 100;
}



void mouseWheel(MouseEvent e) {
  float zoomRate = 1.03;
  viewZoom *= pow(zoomRate, -e.getCount());
}
  
void mousePressed() {
  PVector pos = viewToWorld(mouseX, mouseY);
  mouseDown.set(pos);
  mouseDragCounter = 0;
}

void mouseReleased() {
  if (inputMode==1) dropCar();
  if (inputMode==2) dropRoad();
  drug = -1;
}

void mouseDragged() {
  ++mouseDragCounter;
  if (inputMode==1) dragCar();
  if (inputMode==2) dragRoad();        
}

// Depending on the situation this may add, del, or release a car
void dropCar() {
  PVector pos = viewToWorld(mouseX, mouseY);
  if (mouseDragCounter==0) {
    if (mouseButton==LEFT) {
      // add a new car
      carList.add(new Car(pos.x, pos.y, random(4)<1));
    }
    else if (mouseButton==RIGHT) {
      // delete nearby car
      int i = nearbyCar(pos, 30);
      if (i >= 0) carList.remove(i);
    }
  }
  else if (drug >= 0) {
    // stop dragging the car
    carList.get(drug).isDragging = false;
  }
}

// Start dragging a car, or keep dragging it
void dragCar() {
  PVector pos = viewToWorld(mouseX, mouseY);
  if (mouseDragCounter==1) {
    drug = nearbyCar(pos, 30);
    if (drug >= 0) {
      // set flag on car so it can be dragged
      carList.get(drug).isDragging = true;
      carList.get(drug).isSpecial = true;
    }
  }
  else if (drug >= 0) {
    // drag the car to the mouse (could use rubber band here)
    carList.get(drug).pos.set(pos);
  }
}

// Depending on the situation add or delete a road
void dropRoad() {
  PVector pos = viewToWorld(mouseX, mouseY);
  if (mouseDragCounter==0) {
    if (mouseButton==LEFT) {
      // make a new road connected to the end of the last one
      int i = roadList.size() - 1;
      if (i >= 0) {
        roadList.add(new Road(roadList.get(i).end(), nearbyRoadStart(pos, 5)));
      }
    }
    else if (mouseButton==RIGHT) {
      // delete nearby road
      int i = nearbyRoad(pos, 30);
      if (i >= 0) {
        roadList.get(i).isDead = true;
        roadList.remove(i);
      }
    }
  }
}

// Start dragging a road, or keep dragging it
void dragRoad() {
  PVector pos = viewToWorld(mouseX, mouseY);
  float snap = mouseButton==LEFT ? 5 : 0;
  if (mouseDragCounter==1) {
    roadList.add(new Road(nearbyRoadEnd(mouseDown, snap), nearbyRoadStart(pos, snap)));
    drug = roadList.size() - 1;
  }
  else if (drug >= 0) {
    // drag the end of the road to the pos
    roadList.get(drug).end(nearbyRoadStart(pos, snap));
  }
}