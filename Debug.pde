
/*
This is a bunch of stuff useful to dump debug data to the screen
*/
int markStep = 0;
int markId = 0;
int[] markList = new int[2000];


void markBegin() {
  if (markStep == 0 && markId > 0) markStep = markId;
  if (markId == markList.length) markId = 0;
  mark();
}

void mark() {
  if (markId < markList.length) markList[markId++] = (int)System.nanoTime();
}

void drawMarks(boolean slow) {
  float[] ave = new float[markStep];
  if (markStep==0) return;
  float h = height / 3;
  int c = 0;
  float x = 0;
  float y = 0;
  float d = height;
  int t = markStep-1;
  int u = 0;
  for (int v : markList) {
    if (++t == markStep) {
      t = 0; x++; c=0; y=0;
    } else {
      float k = (v - u) / 1e6f;
      ave[t-1] += k;
      if (slow) {
        float y2 = k * h * 60 / 1000;
        stroke(rainbow(c++));
        line(x, d - y, x, d - (y + y2));
        y += y2;
      }
    }
    u = v;
  }
  u = markId / markStep;
  stroke(100);
  line(0,d - h,x,d-h);
  line(u,d,u,d-h);
  line(x,d,x,d-h);
  strokeWeight(5);
  fill(200);
  for (int i = 0; i < markStep-1; ++i) {
    stroke(rainbow(i));
    line(x,d-i*17-5,x+5,d-i*17-5);
    text(toStr(ave[i]/x),x+10,d-i*17);
  }
  strokeWeight(1);
}

void drawHUD() {
  drawDebugLines();
  resetMatrix();   // default window scale and origin
  if ((hud & 1)==1) drawMarks(hud==1);
  if ((hud & 2)==0) return;
  float x = 10;
  float y = 20;
  float dy = 15;
  fill(200);
  if (inputMode==1) text("CAR EDIT MODE", width*0.45, height*0.1);
  if (inputMode==2) text("ROAD EDIT MODE", width*0.44, height*0.1);
  text("num cars = "+carList.size(), x, y+=dy);
  text("ave neighbor count = "+toStr(aveNeighborSize()), x, y+=dy);
  text("num roads = "+roadList.size(), x, y+=dy);
  text("fps = "+toStr(fps)+(pause?" PAUSE":""), x, y+=dy);
  text("zoom = "+viewZoom, x, y+=dy);
  text("center = ("+toStr(viewCenter.x)+", "+toStr(viewCenter.y)+")", x, y+=dy);
  text("key:"+keydump(), x, y+=dy);
  text("pause = "+pause, x, y+=dy);
  String[] mode = {"normal","CAR","ROAD"};
  text("mode = "+mode[inputMode], x, y+=dy);
  text("click = ("+toStr(mouseDown.x)+", "+toStr(mouseDown.y)+")", x, y+=dy);
}

String keydump() {
  String s = "";
  for (int i : keyList) s += ", "+i;
  return s;
}

float aveNeighborSize() {
  float t =0;
  for (Car c: carList)
    t += c.neighborCount;
  return t==0 ? 0 : t / carList.size();
}

//=======================================================================
// This is for debug... 

ArrayList<PVector> debugLines = new ArrayList<PVector>();

void drawDebugLines() {
  stroke(0,0,255);
  for (int i = 0; i+1 < debugLines.size(); i += 2) {
    line(debugLines.get(i).x,debugLines.get(i).y,debugLines.get(i+1).x,debugLines.get(i+1).y);
  }
  debugLines.clear();
}

// anywhere in the program you can use this add lines (in world space)
void addDebugLine(PVector a, PVector b) {
  debugLines.add(a);
  debugLines.add(b);
}