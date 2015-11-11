
// This is for efficiently finding pairs of nearby cars in 2D space.
// Note: the gap (spacing of the grid lines) should be between 2 and 5 car lengths
// Note: this uses a "multimap" hash table, so there is no restriction on the size
// of the world. 
/*
benchmark: 
GRID 1400 cars, 104 ave pairs, 4.7 ms (macbook i7)
Brute 1400, 106, 9.0 ms
Neighborhood iterator: 1400, 206, 0.20 ms

*/

class Grid {
  HashMap<GridKey, ArrayList<Car>> map;
  float gap;
  float invGap;
  
  // The gap is the spacing between the grid lines
  
  Grid(float gap) {
    map = new HashMap<GridKey, ArrayList<Car>>();
    this.gap = gap;
    invGap = 1.0 / gap;
  }

  void draw() {
    int m = 10;
    stroke(90);
    for (float i = -m+0.5; i < m; ++i) {
      line(i*gap,-m*gap,i*gap,m*gap);
      line(m*gap,i*gap,-m*gap,i*gap);
    }
  }

  void clear() {
    for (GridKey key : map.keySet()) map.get(key).clear();
  }

  // Adds a car to the grid
  
  void add(Car car) {
    GridKey key = new GridKey(car.pos, invGap);
    ArrayList<Car> list = map.get(key);
    if (list == null) {
      list = new ArrayList<Car>(3);
      map.put(key, list);
    }
    list.add(car);
  }
  
  Neighborhood getNeighborhood(Car c) {
    return new Neighborhood(this, c);
  }
}  

// This class combines many lists into a single list using logic. No data is actually copied.
// It is used to make the nine grid cells look like a single list. Also it SKIPS over
// one of the cars.
class Neighborhood implements Iterable<Car> {
  Grid grid;
  Car car;
  ArrayList<ArrayList<Car>> listlist;
  ArrayList<PVector> debuglist;
  
  Neighborhood(Grid grid, Car car) { 
    this.grid = grid;
    this.car = car;
    listlist = new ArrayList();
    if (car.isDragging) debuglist = new ArrayList();
  }
  
  void draw()  // FOR DEBUG ONLY
  {
    if (debuglist != null) {
      stroke(200,200,0);
      noFill();
      for (PVector v : debuglist) 
        ellipse(v.x + random(1.2), v.y + random(1.2), 3, 3); 
      for (Car n : this) 
        line(car.pos.x, car.pos.y, n.pos.x, n.pos.y);
    }
  }
  
  int size() {
    int s = 0;
    if (listlist != null) 
      for (ArrayList a : listlist) 
        if (a != null) s += a.size();
    return s;
  }

  void reset() {
    listlist.clear();
    if (debuglist != null) debuglist.clear();
  }
  
  // Note: radius=4 can return up to 25 cells
  Neighborhood diamond(int radius) {
    reset();
    GridKey key = new GridKey(car.pos, grid.invGap);
    listlist.add(grid.map.get(key));
    for (int i = 1; i < radius; ++i) {
      for (int j = 0; j < i; ++j) {
        listlistAdd(key,i-j,j);
        listlistAdd(key,-i+j,-j);
        listlistAdd(key,j,-i+j);
        listlistAdd(key,-j,i-j);
      }
    }
    return this;
  }
  
  Neighborhood circle(int radius) {
    reset();
    GridKey key = new GridKey(car.pos, grid.invGap);
    listlist.add(grid.map.get(key));
    int r2 = radius * radius;
    for (int i = 1; i < radius; ++i) {
      int m = r2 - i * i;
      for (int j = 0; j * j < m; ++j) {
          listlistAdd(key,i,j);
          listlistAdd(key,-i,-j);
          listlistAdd(key,-j,i);
          listlistAdd(key,j,-i);
      }          
    }
    return this;
  }
  
  // this is a necktie shape in the direction the car is facing.
  Neighborhood cone(int radius) {
    reset();
    GridKey key = new GridKey(car.pos, grid.invGap);
    listlist.add(grid.map.get(key));
    if (radius < 2) 
      return this;
    PVector dir = PVector.fromAngle(car.angle);
    int dx, dy;
    float a;
    if (abs(dir.x) > abs(dir.y)) {
      dx = 0; dy = sign(dir.y); a = abs(dir.x);
    }
    else {
      dx = sign(dir.x); dy = 0; a = abs(dir.y);
    }    
    dir.mult(grid.gap / a);
    if (a < .95) listlistAdd(key,dx,dy);
    PVector axis = car.pos.copy();
    for (int i = 1; i < radius * a; ++i) {
      GridKey keyOnAxis = new GridKey(axis.add(dir), grid.invGap);
      int w = min(i/2 + 1, radius - i - 1);
      for (int j = -w; j <= w; ++j) {
        listlistAdd(keyOnAxis, j*dx, j*dy);
      }
    }
    return this;
  }
  
  int sign(float x) { 
    return x < 0 ? -1 : 1; 
  }
  
  void listlistAdd(ArrayList<Car> item) {
    if (item != null) listlist.add(item);
  }
  
  
  void listlistAdd(GridKey key, int i, int j) {
      if (debuglist != null) debuglist.add(new PVector(grid.gap*(key.x + i),grid.gap*(key.y+j)));
      listlistAdd(grid.map.get(key.next(i,j)));
   }
  
  
  
  java.util.Iterator<Car> iterator() {
    return new NeighborhoodIterator(this);
  }
}    

//-----------------------------------------------------------------
// This iterates over all the cars that are in the neighborhood 
class NeighborhoodIterator implements java.util.Iterator<Car> {
  Neighborhood n;
  int i, j;
  Car nextCar;
  
  NeighborhoodIterator(Neighborhood n) { 
    this.n = n; 
    reset();
  }
  
  void reset() { i=0; j=-1; nextCar=n.car; next(); }
  
  boolean hasNext() { return nextCar != null; }
  
  // return null if there are no more cars
  Car next() { 
    Car temp = nextCar;
    nextCar = null;
    for (; i < n.listlist.size(); ++i, j=-1) {
      ArrayList<Car> list = n.listlist.get(i);
      if (list != null) {
        for (++j; j < list.size(); ++j) {
          Car c = list.get(j);
          if (c != n.car) { 
            nextCar = c;
            return temp;
          }
        }
      }
    }
    return temp;
  }
  
  void remove() { throw new UnsupportedOperationException(); }
}

//------------------------------------------------------------------
class GridKey {
  int x; int y;
  GridKey() {}
  GridKey(int x, int y) { 
    this.x = x; 
    this.y = y; 
  }
  
  GridKey(PVector v, float invGap) { 
    this.x = round(v.x * invGap); 
    this.y = round(v.y * invGap); 
  }

  // return a unique int for each x,y value
  int hashCode() {
    return quadrant(x, y) + 4 * elegant(abs(x), abs(y));
  }
  
  boolean equals(Object other) {
    return other==this || other instanceof GridKey && x == ((GridKey)other).x && y == ((GridKey)other).y;
  }
  
  // return a number 0..3 based on quadrant
  int quadrant(int x, int y) {
    return (x < 0 ? 1 : 0) + (y < 0 ? 2 : 0);
  }
  
  // This returns a unique number for each (x,y) NON-negative.
  // see http://szudzik.com/ElegantPairing.pdf 
  int elegant(int x, int y) {
    return (x >= y) ? x * x + x + y : y * y + x;
  }
  
  // Returns a new key that is next to this key (to the left, below, etc)
  GridKey next(int dx, int dy) {
    return new GridKey(x + dx, y + dy);
  }
  
  String toString() {
    return "(" + x + ", " + y + ") " + hashCode();
  }
}
  
  