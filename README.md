# traffic
traffic simulation using Processing3.  
Controls are:
- Move: 'w', 'a', 's', 'd'
- Pause: 'p'
- Step: 'o'
- Recenter: 'r'

## To Do:
- [ ] make random color generator, so each car can be a diff color  
- [ ] make spatial hash to quickly find neighbors  
- [ ] use clipping to avoid drawing things you can't see. (use the hash)  
- [ ] make more detail on cars (like windsheild etc. see pic) of course change the level of detail depending on the zoom   
- [ ] make a generic "brain" class, so each car can have a different brain (AI algorithm). e.g some cars are driving from a to b. and some are just randomly driving.  
- [ ] allow adding cars.  I was thinking you press 'c' to get "car mode" and you click left to add car, click right to delete car, drag left to move a car, etc.  
- [ ] allow adding roads.  similarly press 'b' to get "building roads mode"  
- [ ] save/load which can import/export game state to text file (json?)  
- [ ] add properties to roads, speed limit, grip factor (gravel vs pavement)  
- [ ] add properties to cars, acceleration, max speed, turn radius, tire grip factor, width, length, color, etc  
- [ ]  try porting to Android ?!  
*Just add an 'X' to the box to check it.*
