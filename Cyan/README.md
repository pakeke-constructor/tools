


# Cyan

Cyan is a lightweight ECS library built for LOVE.

I mainly built this for personal use. Check out Concord, Nata, or HOOECS if you
want a more feature-complete ECS lib!


# Usage:

```lua

-- importing:
local cyan = require "(path to cyan folder).Cyan.cyan"

```

This tutorial assumes you know the basics of ECS.
If you don't, there are plenty of great online resources.

### Entities:

```lua
local cyan = require "(path to cyan folder).Cyan.cyan"


-- Creating entities:
local ent = cyan.Entity()


-- adding components:
ent:add("position", { x=10, y=10 } )
-- OR, equivalently:
ent.position = { x=10, y=10 }


--[[
In cyan, you do not have to create any actual components;
You simply add the component name to the entity, along with a value.

Note that a table does not have to be added; it can be any value.
Example:
]]

ent:add("strength",  12)
-- Now `ent` has component <strength>, with value "12"



-- removing components:
ent:remove("strength")
-- `ent` no longer has component <strength>.
-- It will be removed from all systems that require <strength> component.

-- Note that ent.strength = nil will not remove the strength component;
--   it will just set the component value to nil.



-- Marks entity for deletion, is removed when Cyan:flush() called
ent:delete()

```
.
.
.
### Systems:
.
```lua
local cyan = require "(path to cyan folder).Cyan.cyan"



--  A system that takes all entities with `image` and `position` component
local DrawSys = cyan.System( "image", "position" )




-- Access all entities that are bound to a system:
-- (Use Sys.group)
local draw_entities  =  DrawSys.group





-- Here is an example of a standard function:
function DrawSys:draw()
    for _, ent in ipairs(self.group) do
        love.graphics.draw(ent.image, ent.position.x, ent.position.y)
    end
end
-- To learn how this function will be called, see next section



-- Another example
function DrawSys:update(dt)
    for _, ent in ipairs(self.group) do
        -- Do something to do with entity Z indexing or something, idk
    end
end



```
.
.
.
###  Calling functions
.
```lua
--[[
To call functions in Cyan systems, use
" Cyan.call ". 

example:
]]


function love.update(dt)

    cyan.call("update", dt)
    -- Calls ALL systems with an `update` function, 
    -- passing in `dt` as first argument.

    cyan.flush()
    -- Deletes all entities that need to be deleted.
end


function love.draw(dt)

    cyan.call("draw")
    -- Calls ALL systems with a `draw` function, passing in 0 arguments.
end


```

# Optional ease of use:
Here are some tips that provide extra functionality, but are
entirely optional.
.
.
```lua

-- Cyan.setComponents  allows you more control over what components
-- are allowed, and what ones aren't.
cyan.setComponents(
    {
        health = true,
        position = true,
        inventory = true,
        image = "In lua, strings evaluate to true!"
    }
)
-- If an entity is given a component that is NOT in the table,
-- then an error will then be raised.
-- (By default, Cyan doesn't check, but if you call this function,
-- it will automatically turn checking on.)





-- To create component constructors, use Cyan:setInits.

-- This allows us to automatically make changes to components upon
-- addition to entities.
-- See example:
cyan.setInits(
    {
        image = function( image )
            local width, height = image:getDimensions()
            -- This table becomes the new component.
            return { image = image, width = width, height = height}
        end,
    }
)
--[[
    Now whenever we do
    ent:add("image", image)

    it will automatically be converted to:

    ent:add("image", 
    {image = image, width = <image width>, height = <image height>}
    )
]]



-- Low level entity functions:

local ent = cyan.Entity()

-- Adds component `q` without adding to any systems.
ent:rawadd("q", 1)


-- Removes component `q` without removing from any systems.
ent:rawremove("q")
--              Generally, you shouldn't use this method.




-- Low level System functions:

-- removes `entity` from `Sys`
Sys:remove(entity)

-- adds `entity` to `Sys`
Sys:add(entity)

-- This is done automatically, so it doesn't really need to be done.


```

# *Final notes*

This library is not meant to be used as a barebones-library. 

The user is expected to add the functionality they want through extra functions,
and extra helper tables that they see necessary; minimalism comes at a cost!

For example, if you wanted all entities to come with an `is_active` component
automatically, you could do:





Just make sure to stick to YOUR conventions, and keep it
as minimalistic and strict as possible to avoid spagetti.
No edge cases!


