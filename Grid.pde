
// This is for efficiently finding pairs of nearby cars in 2D space.
// Note: the gap (spacing of the grid lines) should be between 2 and 5 car lengths
// Note: this uses a "multimap" hash table, so there is no restriction on the size
// of the world. 

class Grid {
  HashMap<GridKey, ArrayList<Car>> map;
  float invGap;
  
  // The gap is the spacing between the grid lines
  
  Grid(float gap) {
    map = new HashMap<GridKey, ArrayList<Car>>();
    this.invGap = 1.0f / gap;
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
    for (int i = 0; i < list.size(); ++i) {
      list.get(i).neighbor = (ArrayList<Car>) list.clone();
      list.get(i).neighbor.remove(i);
    }
  }

  void addKeyNeighbors(GridKey key) {
    // as an optmization we could loop over "list1" just once!
    addPairsToNeighbors(map.get(key), map.get(key.next(-1, 1)));
    addPairsToNeighbors(map.get(key), map.get(key.next(0, 1)));
    addPairsToNeighbors(map.get(key), map.get(key.next(1, 1)));
    addPairsToNeighbors(map.get(key), map.get(key.next(1, 0)));    
  }
  
  // Adds each car in list1 to the neighbor list of all cars in list2, and vice versa.
  
  void addPairsToNeighbors(ArrayList<Car> list1, ArrayList<Car> list2) {
    if (list1 == null || list2 == null) return;
    for (Car c1 : list1) {
      for (Car c2 : list2) {
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
  
  int hashCode() { // see http://szudzik.com/ElegantPairing.pdf
    return (x > y) ? x * x + x + y : y * y + x;
  }
  
  GridKey next(int dx, int dy) {
    return new GridKey(x + dx, y + dy);
  }
}
  
  