

--@object Entity
--[[
    Entities in Cyan only hold data.  (commonly called "Components")
    The data that an entity holds will determine what systems it gets into.

    For example, an Entity with "pos", "blah", "image", and "health" components
    would get accepted into a system accepting Entities with ("pos", "health")
    components; because it has "pos" and "health".

    You do not need to worry about adding entities to systems; it is done
    automatically.
]]




local PATH = (...):gsub('%.[^%.]+$', '')
local set = require(PATH..".sets")
local array = require(PATH..".array")


local components = require (PATH..".comps")
-- keyed {comp.name -> component} table of components
local comps = components.comps

local System = require (PATH..".system")
local comp_backrefs = System.comp_backrefs






local Entity = {
    --[[
        ___component_check is a read only field that tells
        Cyan whether to do assertions of components;
        by default is set to false.

        To set it to true, call Cyan.setComponents, and pass
        in a table of keyed-components pointing to true.
    ]]
    ___remove_set = set()
    ;
    -- A list of user-defined types for fast entity construction.
    ___types = { }
}





local Entity_mt
local er_1
do
    er_1 = "Attempted to add uninitialized component to entity.\nPlease initialize components in Cyan.components before use."

    Entity_mt = {
        __index = Entity
        ;
        __newindex = function(t, k, v)
            t:add(k, v)
        end
        ;
        -- Defend metatable
        __metatable = "Defended Metatable!!"
    }
end





-- CTOR
function Entity:new(type)
    --[[
        Creates new Entity. Alias:  Entity( type )

        @arg string type @(
            OPTIONAL:
            If a template for this entity name has been created,
            the entity will be created as a copy of the template.
        )

        @return Entity entity@
    ]]
    if type then
        if Entity.___types[type] then
            return Entity.___types[type]()
        end
    end
    return setmetatable({}, Entity_mt)
end




function Entity:has( comp_name )
    --[[
        Gets whether the entity has a component or not.

        @arg string comp_name @(
            The component name, as a string
        )

        @return bool @ True if entity has component, else false
    ]]
    return self[comp_name] and true
end




-- Adds component to entity
function Entity:add( comp_name, ... )
    --[[
        Adds a component to an entity, adds to new systems, and calls component constructer if possible

        @arg string comp_name @ The name of the component
        @arg comp_value @ Value of the component, can be anything.

        @return self
    ]]
    assert(comps[comp_name], er_1)

    -- Constructs component
    local comp_value = comps[comp_name]:init(...)

    -- Checks if component is new, and not an overide. If so, will send to systems;
    if not self:has(comp_name) then
        self:_send_to_systems( comp_name )
    end

    rawset(self, comp_name, comp_value)

    return self
end





-- adds component to entity without invoking any system search.
function Entity:rawadd( comp_name, ... )
    --[[
        Adds a component to an entity and calls the component constructer WITHOUT adding to any systems

        @arg string comp_name @ The name of the component
        @arg comp_value @ Value of the component, can be anything.

        @return self
    ]]
    assert(comps[comp_name], er_1)

    -- Constructs component, if possible.
    local comp_value = comps[comp_name]:init(...)

    rawset(self, comp_name, comp_value)

    return self
end





-- Immediately destroys entity component and removes from systems.
-- (Does not account for whether it's safe or not.)
function Entity:remove( comp_name )
    --[[
        Immediately destroys entity component and removes from relevant systems.
        Does not account for whether it is safe.

        @arg string comp_name @ The name of the component to be removed

        @return self
    ]]
    self[comp_name] = nil

    for i=1, comp_backrefs[comp_name].len do
        local sys = comp_backrefs[comp_name][i]
        sys:remove(self)
    end

    return self
end




-- Deletes component without removing from systems
function Entity:rawremove( comp_name )
    --[[
        Immediately destroys entity component WITHOUT removing from systems.

        @arg string comp_name @ The name of the component to be removed

        @return self
    ]]
    self[comp_name] = nil

    return self
end





function Entity:delete()
    --[[
        Marks the entity for deletion
        Entity will be deleted the next time Cyan.flush() is called

        @return self
    ]]
    Entity.___remove_set:add(self)

    return self
end







-- VERY EXPENSIVE OPERATION, DO NOT USE IN :update(dt) !!!!
function Entity:template(name)
    --[[
        Creates an entity type.

        Returns a function that is extremely fast at creating entities, as it does not
        need to search potential systems.

        After creating an entity template, you can then create this type with:
            Entity(`name`)
        It will have the exact same components and values as it's template.

        Note that adding systems after an Entity type has been made will cause
        the entity type constructor to skip that system, even if the template
        has all the required components for that system.

        @param string name @ The name of the type

        @return function @ The constructor function
    ]]
    local types = Entity.___types

    -- This is the killer. O(n^2) time with O(n) space complexity!
    local systems = self:_get_all_systems()

    local template = self
    local function construct()
        local ent = Entity()

        for comp_name, comp_value in pairs(template) do
            ent:rawadd(comp_name, comp_value)
        end
        for _, sys in ipairs(systems) do
            sys:add(ent)
        end
    end

    if name then
        types[name] = construct
    end
    return construct
end
--Alias: typeDef
Entity.typeDef = Entity.template
-- Alias: type
Entity.type = Entity.template




--
-- SENDING ENT TO SYSTEMS
--
-- GETTING ENT SYSTEMS
--
do
    -- Gets all the systems the entity needs to be added to
    -- upon recieving given component
    function Entity:_get_systems( comp )

        local getted_systems = set()

        -- TODO: change this to bitops.
        for i=1, comp_backrefs[comp].len do
            local sys = comp_backrefs[comp][i]
            for _, requirement in ipairs(sys.___requirements) do
                -- If the system has all requirements,
                -- Add it to `getted_systems`
                if not self:has(requirement) then
                    -- Else, continue, and check next system
                    goto continue
                end
            end
            getted_systems:add(sys)

            ::continue::
        end

        return getted_systems.objects
    end




    -- Sends entity to all systems that it needs to be added to
    -- upon recieving given component
    function Entity:_send_to_systems( comp )

        -- TODO: Change to bitops
        for i=1, comp_backrefs[comp].len do
            local sys = comp_backrefs[comp][i]
            for _, requirement in ipairs(sys.___requirements) do
                -- If the system has all requirements,
                -- Add it to `getted_systems`
                if not self:has(requirement) then
                    goto continue
                end
            end
            -- Adds entity to system (passed all requirements)
            sys:add(self)
            -- Initializes, if has `init` method.
            if sys.init then
                sys:init(self)
            end

            -- Else, continue, and check next system
            ::continue::
        end
    end



    -- Gets all systems of Entity:
    -- VERY SLOW OPERATION! O(n^2)
    -- Also high space complexity; O(n) garbage-sets created.
    function Entity:_get_all_systems()

        -- TODO: change to bitops
        local systems = set()
        local comps = array()

        for comp, _ in pairs(self) do
            comps:add(comp)
        end

        for _, comp in ipairs(comps) do
            local sys_tabl = self:_get_systems(comp)
            for _, sys in ipairs(sys_tabl) do
                systems:add(sys)
            end
        end

        return systems.objects
    end
end





return setmetatable(Entity,
    {__call = Entity.new,
    __newindex = function()
        error("main table `Entity` is read-only")
    end,
    __metatable = "Defended metatable"}
)





