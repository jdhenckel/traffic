//---------------------------
// These are all the input related functions


IntList keyList = new IntList();


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
      case 'c': inputMode = inputMode == 1 ? 0 : 1; break;
      case 'v': inputMode = inputMode == 2 ? 0 : 2; break;
    }
  }
  viewCenter.add(move.rotate(viewAngle));
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
}

void mouseReleased() {
  
}

void mouseDragged() {
  
}