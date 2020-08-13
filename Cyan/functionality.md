

ideas for functionality:


REMEMBER:::: KEEP MINIMALISTIC!!!



If you want all entities to automatically have an `active` component,
just make a new Entity function:

```lua
_G.Entity = function()

    local ent = Cyan.Entity()
        :rawadd("active", true)

    return ent
end
```

Another example:

Say you want a system that controls what entities are active, and what ones aren't with
a spacial partitioner.

Instead of making exclusion filters, have that System (that takes all entites with position)
remove that entity from all Cyan systems (EXCEPT ITSELF) if  ent.active == false.
when ent.active == true, add back to all systems.





TODO:

How to handle call order of systems?

Ideas::
- Just have call order in order they were created;
-  User should make system functions independent and irrelevant from each other.


How to have systems access the same data structures?
-  Define the systems in the same lua file, and have them access the same local.



Bitops for components.
(each bit 0-1 represents a component.)
This also requires a rework of component system. Do something like:
```lua
local hp = cyan.Component("hp")

function hp:init(hp, max_hp)
    local new = {}
    new.hp = hp
    new.max_hp = max_hp
    return new
end

-- serialization and deserialization will automatically
function hp:serialize(comp)
    ...
end

function hp:deserialize()
    ...
end
```
Have serialize and deserialize methods automatically pushed to a
different table, with keyworded "hp".


