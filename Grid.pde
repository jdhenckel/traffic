
// This is for efficiently finding pairs of nearby cars in 2D space.
// Note: the gap (spacing of the grid lines) should be between 2 and 5 car lengths
// Note: this uses a hash table, so there is no restriction on the size
// of the world. 

class Grid {
  HashMap<GridKey, Car> map;
  float invGap;
  
  // The gap is the spacing between the grid lines
  Grid(float gap) {
    map = new HashMap<GridKey, Car>();
    this.invGap = 1.0f / gap;
  }

  void add(Car car) {
    map.put(new GridKey(car.pos, invGap), car);
  }


  void computeAllNeighbors() {
    // do magic here
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
  public int hashCode() { // see http://szudzik.com/ElegantPairing.pdf
    return (x > y) ? x * x + x + y : y * y + x;
  }
}
  
  