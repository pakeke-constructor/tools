

--@object System
--[[
    "Systems" in Cyan are objects that automatically take entities
    and apply functions to them.
    A system will only take an entity if it has all of the required
    components.
    Systems can be created using  cyan.System(...)
    Where ... is the set of components that the system will check in
    an entity before accepting it.

    Access an array of Entities in a system with System.group;
    iterate over with:

    for _, entity in ipairs(mySystem.group) do
    end
]]


local PATH = (...):gsub('%.[^%.]+$', '')

local set = require(PATH..'.sets')
local array = require(PATH..".array")

local System = {}


do
    -- 2d hasher that holds references to all systems (by component keyword.)
    System.comp_backrefs = setmetatable({},
        {__index = function(t,k) t[k] = array() return t[k] end}
    )

    -- 2d hasher that holds references to all systems that contain given function
    -- (same as System.backrefs, but for functions, not components)
    System.func_backrefs = setmetatable({},
        {__index = function(t,k) t[k] = array() return t[k] end}
    )


    -- Array that holds all systems   (  arr[-1] = val to add stuff )
    System.systems = array()
end




local System_mt = {
    --[[
    __newindex will be called whenever user does:

    function mySys:draw( ent )
        <blah yada>
    end
    ]]
    __index = System
    ;
    __newindex = function(sys, name, func)
        if type(func) == "function" then
            sys[name] = func
            System.func_backrefs[ name ] = sys
        else
            error("Systems can only have functions added to them.")
        end
    end
    ;
    -- Defend metatable
    __metatable = "Defended metatable"
}


local backrefs = System.backrefs

--[[

local draw_sys = System( "position", "image" )

function draw_sys:draw( )
    for _,ent  in  ipairs(self.group) do
        lg.draw( ent.image, ent.x, ent.y )
    end
end

]]



function System:new( ... )--@ALIAS@ System( ... )
    --[[
        Creates a new system
        ( Same as System(...)  )

        @param string ... @(
            A set of component-strings denoting which entities to accept into system's group
        )

        @ return System system @
    ]]
    local requirement_table = {...}

    local new_sys = {
        ___requirements = requirement_table
        ;
        -- Backend group for this system.
        -- front-end access is done through ___group.objects  (thru sys.group)
        ___group = set()
        ;
        active = true
        ;
        added = System.added ;
        removed = System.removed
    }
    new_sys.group = new_sys.___group.objects

    -- Adds system to required component-sets in backrefs.
    -- (for easy future access)
    for _, v in pairs(requirement_table) do
        local backref_set = backrefs[v]
        backref_set:add(new_sys)
    end

    -- Adds to system list
    System.systems[-1] = new_sys

    return setmetatable(new_sys, System_mt)
end




-- Callback for entity added to system
function System.added()
end
-- Callback for entity removed from system
function System.removed()
end





function System:has( ent )
    --[[
        Returns whether the system has an entity, or not.

        @arg Entity ent @ The entity to check if it's in the system

        @return bool @ True if system has the entity, false otherwise
    ]]
    return self.___group:has(ent)
end




function System:add( ent )
    --[[
        Adds an entity to a system

        @arg Entity ent @ The entity to be added

        @return self
    ]]
    if self:has(ent) then
        return self
    end
    self:added(ent)
    self.__group:add(ent)
    return self
end


function System:remove( ent )
    --[[
        Immediately removes an entity from a system

        @arg Entity ent @ The entity to be removed

        @return self
    ]]
    if self:has(ent) then
        self:removed(ent)
        self.__group:remove(ent)
    end
    return self
end


-- Activates system
function System:activate( )
    --[[
        Activates a system

        @return self
    ]]
    self.active = true
    return self
end



function System:deactivate( )
    --[[
        Deactivates a system

        @return self
    ]]
    self.active = false
    return self
end





return setmetatable(System,
    {__call = System.new,
    __newindex = function()
        error("main table `System` is read-only")
    end,
    __metatable = "Defended Metatable"}
)












