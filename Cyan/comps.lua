


-- REWORK ALL OF THIS!!!
-- ADD BITOPS FOR COMPONENT MASKS, ADD SERIALIZATION SUPPORT ETC.
local Component = {
    comps         = {};
}

local Component_mt = {
    __metatable = "Protected"
}


local function newComponent(name)
    local new = {name = name}
    Component.comps[name] = new

    return setmetatable(new, Component_mt)
end



-- CALLBACK
function Component:serialize()

end
-- CALLBACK
function Component:deserialize()

end
-- CALLBACK
function Component:init(arg)
    return arg
end



Component.newComponent = newComponent




return Component






