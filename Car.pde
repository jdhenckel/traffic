

class Car {
  PVector pos;
  float angle;
  float speed;
  float accel;
  float damage;
  float age;
  boolean isDragging;
  boolean isSpecial;
  int paint;
  PVector destination;
  float width, length;
  Driver driver;
  int neighborCount;
  
  Car(float x, float y, boolean spec) {
    pos = new PVector(x, y); //<>//
    angle = random(6.28);
    speed = 50 + random(10);
    width = 4;
    length = 9;
    isSpecial = spec;
    driver = new Driver(this);  
    paint = (int) random(6); 
  }  
  
  void draw() {
    pushMatrix();
    noStroke();
    fill(carColor[paint]);
    translate(pos.x, pos.y);
    rotate(angle);
    if (use3D) {
      box(length, width, width/2);
    }
    else {
      if (viewZoom < 5) {
        rect(0, 0, length, width);
        if (viewZoom > 2) {
          fill(0, 125, 255);  // color the wind shield
          rect(length/6, 0, length/5, width-2); // draw the ws
        }
      }
      else
        drawCarImage(paint,0,0,0.045);   
    }
    popMatrix();
    
    driver.draw(); //<>//
    
    // draw lines to neighbors (for debugging)
    if (isDragging || isSpecial) {
      stroke(0); 
      PVector f = direction().mult(140/viewZoom).add(pos);
      line(pos.x, pos.y, f.x, f.y);
      stroke(200,0,0);
      Neighborhood nn = grid.getNeighborhood(this).cone((int)(7/viewZoom));
      neighborCount = nn.size();
      nn.draw();
    }
  }
  
  PVector direction() {
    return PVector.fromAngle(angle);
  }
    
  PVector velocity() {
    return PVector.fromAngle(angle).mult(speed);
  }
  
  
  void stepTime(float dt) { //<>//
    if (isDragging) {
      angle += .5 * dt;    // slowly spin whilst being dragged
    }
    else {
      float vbar = speed + accel * dt * .5;
      speed += accel * dt;
      accel = 0;
      PVector vel = PVector.fromAngle(angle).mult(vbar);
      pos.add(vel.mult(dt));
    }
  }
}

//----------------------------------------

PImage allcars = null;

// Note: c = 0..5 { orange, red, gray blue, yellow, green }

void drawCarImage(int c, float x, float y, float scale) {
  if (allcars==null) {
    allcars = loadImage("cars.png");
  }  
  int a = (c % 2) * 280 + 40;
  int b = (c / 2) * 128 + 4;
  copy(allcars,a,b,240,128,(int)(x-120*scale),(int)(y-64*scale),(int)(240*scale),(int)(128*scale));
}

// these are the colors that match the cars in the image
color[] carColor = { color(255,127,0), color(188,16,35), color(166),
                    color(83,150,196), color(252,235,74), color(123,171,63) };
                    
                    