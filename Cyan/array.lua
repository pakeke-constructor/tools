

local Array

Array = {
    __newindex = function(t, _, v)
        local len = t.len + 1
        t[len] = v
        t.size = len
    end
    ;
    add = function(t, v)
        local len = t.len + 1
        t[len] = v
        t.size = len
    end
}
Array.__index = Array


return function()
    return setmetatable({len = 0}, Array)
end



