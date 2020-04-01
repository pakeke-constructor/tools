
--[[

There is no point in this.

]]

return function()
  return setmetatable( {}, {
  __index = function(t, k) 
    t[k] = setmetatable( {}, getmetatable(t) )
    return t[k]
  end
} )
end

