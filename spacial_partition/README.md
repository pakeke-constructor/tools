

# spatial_partition
Spatial partitioners are data structures used to seperate and update objects depending on their position.

This allows us to reduce the time taken to check interactions between objects, as we only need to check for interactions within certain areas.

The biggest catch with this library is that the objects need to have `.x` and `.y` attributes. If this isn't the case, and the `x` and `y` is stored somewhere else, you'll have to use either `partition:set_getters(getx, gety)` to allow the spatial partitioner to read your object's position.


# usage:

```lua
local Partition = require("path.to.spatial_partition.partition")

-- cells of dimension:   100x, 120y.
local partition = Partition( 100, 120 )



-- Adds `obj` to spatial partition.
-- All objects must have `x` and `y` attributes.   (to change this, see below.)
partition:add( obj )


-- Removes object from partition
partition:remove( obj )



-- Compulsory! must be called each frame
partition:update()


partition:clear() --clears spatial partition


-- iterates over objects near `obj`, including `obj` itself.
-- (cells next to obj's cell will be included in the iteration.)
for object in partition:foreach(obj) do
    ...
end


-- Equivalent to above; direct positions can also be used
for object in partition:foreach( obj.x,  obj.y ) do
    ...
end
```


### *How do I determine the size of the cells for the partitioner?*
**The size of the cells for the spatial partitioner must be greater than or equal to the maximum velocity of any object in the partitioner.**
If an object moves past a whole cell in one frame, the spatial partitioner will not be able to find it, and an error will be raised.

However, the smaller the cells are in the spatial partitioner, the more efficient the spatial partitioner will be.
Thus, it is often a good idea to exclude fast moving objects from the spatial partitioner entirely so the cell size can be made smaller.
Remember, objects do not need to be inside the spatial partitioner to iterate over objects that are:
```lua
for slow_obj in partition:iter( fast_obj.x, fast_obj.y ) do
    maybe_collision( fast_obj, slow_obj )
end
```

Also, the cell size should not be smaller than the maximum object interation distance.

# !!!! BIG WARNING!!!!
Do NOT nest loops in this library. i.e this:
```lua
for obj1 in partition:iter(x1, y1) do
    for obj2 in partition:iter(x2, y2) do
        print("?")
    end
end 
```
This is totally undefined behaviour!!!
Since the iteration function is not anonymously created each time and instead uses local upvalues,
running another iterator whilst another is running will seriously mess things up.
(This may seem crappy, but this actually keeps the GC way happier.)

If you really do need nested iteration, run over the partition quickly and cache the entries in an array,
then loop over that array normally

### Optional functionality:


```lua
partition:frozen_add(objec)
-- Adds `objec` to spatial partition, but will not move `objec` to other cells.
-- Is an efficient way of dealing with unmoving objects.
```

If your objects do not have `.x` and `.y` fields:
```lua
local function getX(obj)
    return obj.position.x
end

local function getY(obj)
    return obj.position.y
end


partition:set_getters(getX, getY) -- Now the spatial partition will work with your objects!
```
