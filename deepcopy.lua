-- if CLONE_USERDATA is false, lua userdata will not be copied, and will just be passed as a reference.
local CLONE_USERDATA = false


-- Don't use shove as an argument. 

local deepcopy

deepcopy = function( tabl, shove )
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
            if CLONE_USERDATA then
                if val.clone then
                    new[ke] = val:clone() -- love2d
                else
                    error "userdata cannot be deepcopied; requires a :clone() method"
                end
            else
                new[ke] = val 
            end
        else
            new[ke] = val
        end
    end

    return setmetatable(new, tabl)
end


return deepcopy


