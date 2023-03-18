-- 标准方式
local Class1 = { type = "Class1" }
function Class1:new(o)
    o = o or {}
    self.__index = self
    setmetatable(o, self)
    return o
end
local Class1_inh = Class1:new { type = "Class1_inh" }
function Class1_inh:hello()
    print("hello " .. self.type)
end
local class_1_obj = Class1_inh:new()
class_1_obj:hello() -- hello Class1_inh




-- 提前申明__index
-- 这种方式在继承时， 如果不重写new方法， self 还是父类， 不是子类
-- 会导致子类在重写赋值__index前， 新加的方法不能访问
local Class2 = { type = "Class2" }
Class2.__index = Class2
function Class2:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end
local Class2_inh = Class2:new { type = "Class2_inh" }
function Class2_inh:hello()
    print("hello " .. self.type)
end

-- 这时候， class_2_obj 的index 还是 Class2， 里面没有 hello
local class_2_obj_1 = Class2_inh:new()
--class_2_obj_1:hello()  -- //error : attempt to call a nil value (method 'hello')

-- 更新 Class2_inh.__index 为正确的就可以了
Class2_inh.__index = Class2_inh
-- 现在可以正常访问了
local class_2_obj_2 = Class2_inh:new()
class_2_obj_2:hello() -- hello Class2_inh





-- Class2 的错误可以用下面方法修复 ， 但是耗时会更长， 因为本来只有matetable的子类现在多了一个__index成员
local Class3 = { type = "Class3" }
Class3.__index = Class3
function Class3:new(o)
    local o = o or {}
    setmetatable(o, self)
    -- 每个实例， 都是用自身作为 __index , 这样子类就能避免这个 Class2 中更新 __index 前对不上的问题了
    o.__index = o
    return o
end
local Class3_inh = Class3:new { type = "Class3_inh" }
function Class3_inh:hello()
    print("hello " .. self.type)
end

-- 这时候
local class_3_obj = Class3_inh:new()
class_3_obj:hello() -- hello Class3_inh


