
# usage:

```lua
local Partition = require("path.to.spacial_partition.partition")

-- cells of dimension:   100x, 120y.
local partition = Partition( 100, 120 )



-- Adds `obj` to spacial partition.
-- All objects must have an `x` and `y` attribute.
partition:add( obj )


-- Removes object from partition
partition:remove( obj )



-- Compulsory! must be called each frame
partition:update()




-- iterates over objects near `obj`, including `obj` itself.
-- (cells next to obj's cell will be included in the iteration.)
for object in partition:iter(obj) do
    ...
end


-- Equivalent to above; direct positions can also be used
for object in partition:iter( obj.x,  obj.y ) do
    ...
end
```


### *How do I determine the size of the cells for the partitioner?*
**The size of the cells for the spacial partitioner must be greater than or equal to the maximum velocity of any object.**
If an object moves past a whole cell in one frame, the spacial partitioner will not be able to find it, and an error will be raised.

However, the smaller the cells are in the spacial partitioner, the more efficient the spacial partitioner will be.
Thus, it is often a good idea to exclude fast moving objects from the spacial partitioner entirely so the cell size can be made smaller.
Remember, objects do not need to be inside the spacial partitioner to iterate over objects that are:
```lua
for slow_obj in partition:iter( fast_obj.x, fast_obj.y ) do
    maybe_collision( fast_obj, slow_obj )
end
```
Intuitively, it is also important to note that for object interactions,
the cell size should not be smaller than the maximum object interation distance.



### Optional functionality:


```lua
partition:frozen_add(objec)
-- Adds `objec` to spacial partition, but will not move `objec` to other cells.
-- Is an efficient way of dealing with unmoving objects.
```
