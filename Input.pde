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
      case 38 : viewZoom *= zoomRate; break;
      case 40 : viewZoom /= zoomRate; break;
      case 37 : viewAngle = sumAngles(viewAngle, turnRate); break;
      case 39 : viewAngle = sumAngles(viewAngle, -turnRate); break;
      case 'r': viewAngle = 0; viewCenter.set(0,0); viewZoom = 1; break;
    }
  }
  viewCenter.add(move.rotate(viewAngle));
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
  }
}

PVector viewToWorld(int x, int y) {
  // this takes a pixel on the window (origin top left) and maps it to world space
  PVector v = new PVector(x - .5 * width, y - .5 * height);
  v.rotate(-viewAngle);
  v.set(v.x / viewZoom, v.y / -viewZoom);
  v.sub(viewCenter);
  return v;
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
      carList.add(new Car(pos.x, pos.y));
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
      if (i >= 0) roadList.remove(i);
    }
  }
}

// Start dragging a road, or keep dragging it
void dragRoad() {
  PVector pos = viewToWorld(mouseX, mouseY);
  if (mouseDragCounter==1) {
    roadList.add(new Road(nearbyRoadEnd(mouseDown, 5), nearbyRoadStart(pos, 5)));
    drug = roadList.size() - 1;
  }
  else if (drug >= 0) {
    // drag the end of the road to the pos
    roadList.get(drug).end(nearbyRoadStart(pos, 5));
  }
}