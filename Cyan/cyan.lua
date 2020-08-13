


local PATH = (...):gsub('%.[^%.]+$', '')

local Cyan = {

}




local Entity = require(PATH..".ent")
local System = require(PATH..".system")
local Component = require(PATH..".comps")

local WorldControl = require(PATH..".world")






-- Cyan.Entity(); entity ctor
Cyan.Entity = Entity

--Cyan.System(...); system ctor
Cyan.System = System

-- Cyan.Component(name); comp ctor
Cyan.Component = Component




--[[
 core cyan management

Maybe remove `Cyan.flush()` and replace with automatic flushing in Cyan.call?

DEFINITELY REMOVE Cyan.flush(), replace w/
https://github.com/Tjakka5/Concord/blob/master/concord/world.lua,
line 249 - 260.
That way system flushing is done automatically upon every root Cyan.call(),
i.e. from every time it's called in `update`, or `draw`.

Also, you should have the option to keep Cyan.flush() for performance reasons.
Maybe something like Cyan.autoflush = false...?
]]
do
    -- Varargs are really slow in LuaJIT- so no varargs.
    function Cyan.call(func,   b,c,d,e,f,g,h,i)
        --[[
            Calls all systems with the given function. Alias: Cyan.emit

            @arg func @(
                The function name to be called
            )

            @arg ... @(
                Any other arguments sent in after will be passed to system.
                Max number of extra arguments is 8.
            )

            @return Cyan @
        ]]
        for _, sys in ipairs(System.func_backrefs[func]) do
            if sys.active then
                sys[func](sys, b,c,d,e,f,g,h,i)
            end
        end

        return Cyan
    end

    Cyan.emit = Cyan.call



    -- Flushes all entities that need to be deleted
    function Cyan.flush()
        --[[
            Removes all entities marked for deletion.

            @return Cyan@
        ]]
        local sys_list = System.system_list
        local sys
        for _, ent in ipairs(Entity.__remove_set.objects) do
            for index = 1, sys_list.len do
                sys = sys_list[index]
                sys:_remove(ent)
            end
        end
    end
end
--[[
]]





--[[
    World management
    NEEDS TESTING!!!
]]
do
    function Cyan.setWorld(name)
        assert(name, "Cyan.setWorld requires a world name as a string!")
        return WorldControl:setWorld(name, Cyan)
    end

    function Cyan.getWorld()
        return WorldControl:getWorld()
    end

    function Cyan.clearWorld(name)
        assert(name, "Cyan.clearWorld requires a world name as a string!")
        return WorldControl:clearWorld(name, Cyan)
    end

    function Cyan.newWorld(name)
        assert(name, "Cyan.newWorld requires a world name as a string!")
        return WorldControl:newWorld(name, Cyan)
    end
end
--[[
]]


-- Default world is `main`
Cyan.newWorld("main")
Cyan.setWorld("main")








return setmetatable(Cyan, {__metatable = "Defended metatable"})




