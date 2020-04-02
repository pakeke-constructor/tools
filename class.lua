

local module = {}


-- Yes, this is required for max efficiency, ternary cannot continue across loops. :/
-- I am sure there is better way still but eh
module.class_case_table = {
    function(k,p) return p[1][k] end,
    function(k,p) return p[1][k] or p[2][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] or p[5][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] or p[5][k] or p[6][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] or p[5][k] or p[6][k] or p[7][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] or p[5][k] or p[6][k] or p[7][k]  or p[8][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] or p[5][k] or p[6][k] or p[7][k]  or p[8][k] or p[9][k] end,
    function(k,p) return p[1][k] or p[2][k] or p[3][k] or p[4][k] or p[5][k] or p[6][k] or p[7][k]  or p[8][k] or p[9][k] or p[10][k] end,
}
module.class_case_table[0] = function(t,k) return nil end


module.class = { default = _G }
setmetatable( module.class,  {__call = function(string)
    return function(tbl)
        return function(...)
            tbl.__parents = {...}
            tbl.__class = tbl
            tbl.__name = string

            local p = tbl.__parents
            local l = #tbl.__parents

            local case_table = module.class_case_table
            assert(tbl.__new, " Class "..string .." does not have a "..string..".__new  method."..
                "\n ")
            local mt_tbl

            local f = case_table[l]
            tbl = setmetatable(tbl, {
                __call = function(...)
                    local t_ = {...}
                    table.remove(t_,1)
                    local _ = setmetatable({}, mt_tbl)
                    tbl.__new(_,unpack(t_))
                    return _
                end,
                __index = function(t,k) return f(k,p) end
            })

            mt_tbl = {__index = tbl, __add = tbl.__add or f('__add',p), __mul = tbl.__mul or f('__mul',p), __div = tbl.__div or f("__div",p), __newindex = tbl.__newindex or f('__newindex',p),
                        __gc = tbl.__gc or f('__gc',p), __mode = tbl.__mode or f('__mode',p), __metatable = tbl.__metatable or f('__metatable',p), __len = tbl.__len or f('__len',p),
                    __call = tbl.__call or f('__call',p), __mod = tbl.__mod or f('__mod',p), __eq = tbl.__eq or f('__eq',p), __lt = tbl.__lt or f('__lt',p), __pow = tbl.__pow or f('__pow',p),
                    __unm = tbl.__unm or f('__unm',p), __concat = tbl.__concat or f('__concat',p), __sub = tbl.__sub or f('__sub',p)}
            
            module.class.default[string] = tbl
            
            return tbl
        end
    end
end })


return module.class


