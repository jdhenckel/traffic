
// This is for efficiently finding pairs of nearby cars in 2D space.
// Note: the gap (spacing of the grid lines) should be between 2 and 5 car lengths
// Note: this uses a "multimap" hash table, so there is no restriction on the size
// of the world. 
/*
benchmark: 
GRID 1400 cars, 104 ave pairs, 4.7 ms (macbook i7)
Brute 1400, 106, 9.0 ms

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

  // Set the "neighbor" list of all cars

  void computeAllNeighbors() {
    for (GridKey key : map.keySet()) {
      setNeighbors(map.get(key));
    }
    for (GridKey key : map.keySet()) {
      addKeyNeighbors(key);
    }
  }

  // This sets the neighbor list of each car in the list to be all the other cars in the list.
  
  void setNeighbors(ArrayList<Car> list) {
    for (Car c : list) {
      c.neighbor.clear();
      for (Car c2 : list) if (c != c2) c.neighbor.add(c2);
    }
  }

  void addKeyNeighbors(GridKey key) {
    ArrayList<Car> list = map.get(key);
    for (Car c : list) {
      addPairsToNeighbors(c, key.next(-1, 1));
      addPairsToNeighbors(c, key.next(0, 1));
      addPairsToNeighbors(c, key.next(1, 1));
      addPairsToNeighbors(c, key.next(1, 0));
    }
  }
  
  
  void addPairsToNeighbors(Car c1, GridKey key) {
    ArrayList<Car> list = map.get(key);
    if (list == null) return;
    for (Car c2 : list) {
      if (PVector.sub(c1.pos, c2.pos).magSq() < gap2) {
        c1.neighbor.add(c2);
        c2.neighbor.add(c1);
      }
    }  
  }
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
  
  
  GridKey next(int dx, int dy) {
    return new GridKey(x + dx, y + dy);
  }
  
  String toString() {
    return "(" + x + ", " + y + ") " + hashCode();
  }
}
  
  