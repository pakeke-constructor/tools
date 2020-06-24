



local remove = function(tabl, item)
    for i, v in ipairs(tabl) do
        if v == item then
            table.remove(tabl, i)
        end
    end
end

local is_in = function(tabl, item)
    for _, v in ipairs(tabl) do
        if v == item then
            return true
        end
    end
end

local add = function(tabl, item)
    tabl[#tabl + 1] = item
end


local function call_all(t, k, ...)
    if type(t[k]) == "function" then
        t[k](t, ...)
    end
    for _, func in ipairs(t.___attached) do
        if type(func) == "function" then
            func(t, ...)
        end
    end
end





local PATH = (...):gsub('%.[^%.]+$', '')

local deepcopy = require(PATH .. ".deepcopy")


local SuperStruct = {}

local SuperClass_mt = {
    __index = SuperStruct;
    __call = function(struct)
        return struct:___new()
    end
}


--[[
    Superclass is a struct module that works with classes in a unique way.
    It is designed to make inheritance intuitive and spagetti-free.


    PLANNING :::

    Construction is the hard bit. How do you construct something when it relies on
    8 layers of ctor funcs???? Do you just force constructers to have no arguments ???

    Maybe there is no constructor; instead, when you create a struct, you specify what fields the object has.
    i.e:  local Position  =  SuperStruct { x=0, y=0 }        <-- this is probably best idea.

    The only immutable part of classes will be the initial template object!!
    ALL other struct fields must be fully mutable
]]

local MT = {__index = call_all, __metatable = "DEFENDED"}
local function newSuperStruct( template )
    --[[
        @param template The template object this struct will be based off
        @return SuperStruct The struct that
    ]]
    local struct = {}
    struct.___attached = { } -- list of attached classes (parents)
    struct.___mt       =  MT-- metatable for objects

    struct.___template = setmetatable(template, struct.___mt) -- template object

    struct.___children = { } -- list of children classes

    return setmetatable(struct, SuperClass_mt)
end



function SuperStruct:___new()
    return deepcopy( self.___template )
end



function SuperStruct:___modify_template(otherStruct)
    local template = self.___template
    for k,v in pairs(otherStruct.___template) do
        if is_in(template, k) then
            error("This SuperStruct already has a key value called " .. k .. ". Duplicate keys are not allowed!")
        else
            template[k] = v
        end
    end
end



function SuperStruct:___demodify_template(otherStruct)
    local template = self.___template
    for k,_ in pairs(otherStruct.___template) do
        template[k] = nil
    end
end



function SuperStruct:attach( otherStruct )
    if self == otherStruct then
        error "No... this won't work... sorry"
    end
    if is_in(otherStruct.___attached, self) then
        error "Attempted to add SuperStruct that had `self` attached to it.\nNo circular references sorry!"
    end

    add(self.___attached, otherStruct)
    add(otherStruct.___children, self)

    -- Modifying template.
    self:___modify_template(otherStruct)
    return self
end



function SuperStruct:detach( otherStruct )
    remove(self.___attached, otherStruct)
    remove(otherStruct.___children, self)

    self:___demodify_template(otherStruct)
    return self
end




return newSuperStruct

