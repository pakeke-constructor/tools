
setmetatable(_G, {
    __index = function(_,k)
        return setmetatable({k=k},{
            __index = function(te,ke)
                return setmetatable({k=ke, p=te},getmetatable(te))
            end;
            __tostring = function(te)
                if rawget(te,"p") then return(tostring(te.p)..te.k) end
                return te.k
            end
        })
    end
})

print(H.e.l.l.o._.W.o.r.ld)
