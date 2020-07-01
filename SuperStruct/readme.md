
# SuperStructs

SuperStructs are an experimental take on the common class data type seen in standard OOP.
Although they are very similar to classes, there are some differences:

Main differences:
- Superstructs are basically useless without composition (form of inheritance)
- Calling a superstruct method will call that same method in all attached superstructs, for that object
- Superstructs are mutable at runtime and will not break children/parents when modified
- Superstruct's object fields are defined on creation, and are static. (__newindex = error)
- There is no constructor function, structure fields are copied from template.
- Method overriding is not a thing; parent class functions are static

Example of use:
```lua
local SuperStruct = require '<path>.SuperStruct'



local ss1 = SuperStruct{ bah = 10 }
local ss2 = SuperStruct{ foo = "foo", qqq = 99, }

function ss2:blahblah()
  print("ss2 called")
end

function ss1:blahblah()
  print("ss1 now.")
  self.bah = self.bah + 1
end



local Combiner = SuperStruct()
Combiner:attach(ss2)
Combiner:attach(ss1) -- Note order.



local obj = Combiner()

obj:blahblah()
-- prints -->
--            "ss2 called"
--            "ss1 now."



obj.bah --> 11     (remember addition)
obj.foo = "foo"
obj.qqq = 99

```
