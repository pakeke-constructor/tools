# tools
bunch of tools for lua
```lua
local tools = require"init"     --Must be in same dir
```
# complex
```lua
local complex = tools.complex

my_c_num = complex(3, 7)    -- 3 + 7j
--[[
all operators supported except
power. You can do complex^number, but not complex^complex
modulus is complx:mod()
]]
```

# class
usage: 
```lua
local class = tools.class

-- <class>.__new is constructer function. Automatically will return self, but you can return other if you want.
-- <obj>.__class is reference to the parent class of any object created.
-- <class>.__name is string name of class.

class "par"
{
    __new = function(self,...) end, -- object constructer function

    __add = function(self,b)
        -- __class allows access to parent class from object.
        return (self.__class(self.name..b.name))
    end
}  (    ) -- <<<< empty inheritance args; does not inherit.




class "pah"
{
    __new = 1, -- this class can't create objects; is just for example.

    __sub = function(self,b)
        return self.__class(b.name..self.name)
    end

}    (     )  -- <<<< empty inheritance args; does not inherit.




-- __new is constructer function.
-- can set a local at current location.

-- To disable automatic global creation, do:
tools.no_globals = true

local child_class = class "child_class"
{
    objects = {},

    __new = function(self,name,...)
        self.name = name
        self.some_var = {...}

        table.insert(child_class.objects, self) -- Class can access itself.
    end,

}   (  par, pah  ) -- Inherits ALL methods from par and pah.
                -- Multiple inheritance is allowed, but capped at 10.
                -- NOTE: methods will be searched for first in class <par>,
                -- and secondly in class <pah>. order matters


local obj = child_class("obj 1") --pythonic object construction
local obj_2 = child_class("object 2")

local obj_3 = obj+obj_2 -- __add called from class <par>

local blah = (obj_3 + obj) - obj_2 --  __sub called from class <pah>, __add called from class <par>

print("number of <child_class> objects:    "..#obj.__class.objects)
-- Should get 3.
```

# smart_iter
```lua
local smart_iter = tools.smart_iter

local max_time = nil        -- optional argument. By default is 0.01
update(dt)
    smart_iter(array, func, max_time)
end
```
If goes over allocated time limit, pauses execution and waits until second update loop.
