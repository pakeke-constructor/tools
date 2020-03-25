
local tan = math.tan
local atan = math.atan
local pi = math.pi
local cos = math.cos
local sin = math.sin

local setmeta = setmetatable

local conj = function(a) a.i = -a.i; return a end

local mod = function(a) return (a.r^2 + a.i^2)^0.5 end

local arg = function(a) 
    local th = atan(a.i/a.r)
    if a.r == 0 then
        if a.i > 0 then return pi/2
        else return -pi/2 end end
    if a.r < 0 then return th + pi
    else return th end
end


local COMPLEX


local polar_to_rect = function(mod,arg)
    return setmeta({r=cos(arg)*mod, i=sin(arg)*mod}, COMPLEX)
end

COMPLEX = { -- Where r is real, and i is imag component
    r=0, i=0,
    __index = COMPLEX,
    __add = function(a, b)
        if type(b) == "table" then
        return setmeta({r=a.r+b.r, i=a.i+b.i}, COMPLEX)
        else return setmeta({r=a.r+b, i=a.i}, COMPLEX) end
    end,
    __sub = function(a, b)
        if type(b) == "table" then
        return setmeta({r= a.r-b.r, i=a.i-b.i }, COMPLEX)
        else return setmeta({r=a.r-b, i=a.i}, COMPLEX) end
    end,
    __mul = function(a, b)
        if type(b) == "table" then
        return setmeta({
            r = (a.r*b.r) - (a.i*b.i),
            i = (a.r*b.i) + (a.i*b.r)
        }, COMPLEX)
        else return setmeta({r=a.r*b, i=a.i*b}, COMPLEX) end
    end,
    __div = function(a, b)
        if type(b) == "table" then
        local d = conj(b)
        local c = setmeta({
            r = (a.r*d.r) - (a.i*d.i),
            i = (a.r*d.i) + (a.i*d.r)
        }, COMPLEX)
        c.r = c.r/(b.r^2 + b.i^2)
        c.i = c.i/(b.r^2 + b.i^2)
        return c
        else return setmeta({r=a.r/b, i=a.i/b},COMPLEX) end
    end,
    __pow = function(a, b) -- Atm you can't do power of complexes, as there are infinite solns :/
        local mod = mod(a)^b
        local arg = arg(a)*b
        return polar_to_rect(mod,arg)
    end,
}

function COMPLEX.new(_,real, imag)
    return setmeta({r=real, i=imag}, COMPLEX)
end


COMPLEX.show = function(c)
    print(c.r..",  "..c.i.."i")
end


require( (...):gsub('%.[^%.]+$', '')..".init" ).complex = setmetatable(COMPLEX, {__call = COMPLEX.new})
