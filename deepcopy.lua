--[[
shove is optional argument.

If you have tables you don't want to be copied, place them in `shove`, in the form

shove   ::   {[dont_copy_me] = dont_copy_me}


]]
return function( tabl, shove )
    local new = {}
    shove = shove or {}

    for ke, val in pairs(tabl) do
        if type(val) == "table" then
            if shove[val] then
                new[ke] = val
            else
                shove[val] = val
                new[ke] = deepcopy(val, shove)
            end
        elseif type(val) == "userdata" then
            if val.clone then
                new[ke] = val:clone() -- love2d
            else
                error "userdata cannot be deepcopied; requires a :clone() method"
            end
        else
            new[ke] = val
        end
    end

    return setmetatable(new, tabl)
end
