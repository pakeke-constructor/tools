
-- Don't use shove as an argument. 

return function( tabl, shove )
    local new = {}
    shove = shove or {[tabl] = tabl}

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
