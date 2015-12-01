Car carTemplate = new Car();

class Car implements Convertible {
  PVector pos;
  float angle;
  float speed;
  float accel;
  float damage;
  boolean isDragging;
  boolean isSpecial;
  boolean isDead;
  int paint;
  float width, length;
  Driver driver;
  int neighborCount;
  
  Car() {}
  
  Car(float x, float y, boolean spec) {
    pos = new PVector(x, y); //<>//
    angle = random(6.28);
    speed = 50 + random(10);
    width = 3.8;
    length = 9;
    isSpecial = spec;
    driver = new Driver(this);  
    paint = (int) random(6); 
  }  
  
  Convertible create() { return (Convertible) new Car(); }
  
  // This is for save and load
  void convert(Target tar) {
    pos = tar.aV2("pos", pos);
    angle = tar.aFloat("angle", angle);
    speed = tar.aFloat("speed", speed);
    width = tar.aFloat("width", width);
    length = tar.aFloat("length", length);
    paint = tar.aInt("paint", paint);
    if (driver==null) driver = new Driver(this);
    driver = (Driver) tar.aObject("driver", driver, null);
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
        rect(0, 0, length, width, 1);
        if (viewZoom > 2) {
          fill(120);  // color the wind shield
          rect(length/6, 0, length/5, width-.5, .5); // draw the ws
          if (paint < 2)
            rect(-1.5, 0, length/3.5, width-1, 1); // draw the ws
        }
      }
      else
        drawCarImage(paint, 0, 0, 0.045);   
    }
    popMatrix();
    
    driver.draw(); //<>//
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
      float vbar = speed + accel * dt * 0.5f;
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
  copy(allcars, a, b, 240, 128, (int)(x-120*scale), (int)(y-64*scale), (int)(240*scale), (int)(128*scale));
}

// these are the colors that match the cars in the image
color[] carColor = { color(255, 127, 0), color(188, 16, 35), color(166), 
                    color(83, 150, 196), color(252, 235, 74), color(123, 171, 63) };
                    
                    