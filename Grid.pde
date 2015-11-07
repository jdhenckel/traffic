
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
  float gap2;
  float invGap;
  
  // The gap is the spacing between the grid lines
  
  Grid(float gap) {
    map = new HashMap<GridKey, ArrayList<Car>>();
    this.gap2 = gap * gap;
    this.invGap = 1.0f / gap;
  }

  void draw() {
    float g = gap2 * invGap;
    int m = 10;
    stroke(90);
    for (float i = -m+0.5; i < m; ++i) {
      line(i*g,-m*g,i*g,m*g);
      line(m*g,i*g,-m*g,i*g);
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
  ArrayList<Car>[] listlist;
  
  Neighborhood(Grid grid, Car car) { 
    this.grid = grid;
    this.car = car;
    reset();
  }
  
  void reset() {
    GridKey key = new GridKey(car.pos, grid.invGap);
    listlist = new ArrayList[9];
    listlist[0] = grid.map.get(key);
    listlist[1] = grid.map.get(key.next(0,1));
    listlist[2] = grid.map.get(key.next(0,-1));
    listlist[3] = grid.map.get(key.next(1,0));
    listlist[4] = grid.map.get(key.next(-1,0));
    listlist[5] = grid.map.get(key.next(1,1));
    listlist[6] = grid.map.get(key.next(-1,1));
    listlist[7] = grid.map.get(key.next(1,-1));
    listlist[8] = grid.map.get(key.next(-1,-1));
  }
  
  java.util.Iterator<Car> iterator() {
    return new NeighborhoodIterator(this);
  }
}    


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
    for (; i < n.listlist.length; ++i, j=-1) {
      if (n.listlist[i] != null) {
        for (++j; j < n.listlist[i].size(); ++j) {
          Car c = n.listlist[i].get(j);
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

//-------------------------
class GridKey {
  int x; int y;
  GridKey() {}
  GridKey(int x, int y) { 
    this.x = x; 
    this.y = y; 
  }
  
  GridKey(PVector v, float invGap) { 
    this.x = Math.round(v.x * invGap); 
    this.y = Math.round(v.y * invGap); 
  }

  // return a unique int for each x,y value
  int hashCode() {
    return quadrant(x, y) + 4 * elegant(Math.abs(x), Math.abs(y));
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
  
  