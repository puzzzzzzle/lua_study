local function test_table_with_func()
    -- acc table 有一个 函数 change
    local acc = { value = 0 }
    function acc.change(self, v)
        self.value = self.value - v
    end

    print(acc.value)
    acc.change(acc, 100)
    print(acc.value)

    -- 只是对同一个table的引用
    local another_acc = acc
    another_acc.change(acc, 100)
    assert(acc.value == another_acc.value)
    print(another_acc.value, acc.value)
end
test_table_with_func()

local function test_table_with_func_simple()
    -- 和上面的等价
    local acc = { value = 0 }
    function acc:change(v)
        self.value = self.value - v
    end
    -- 只是个语法糖 两种方式等价
    acc:change(100)
    acc.change(acc, 100)
    assert(acc.value == -200)
    print(acc.value)
end
test_table_with_func_simple()

local function test_object()
    -- 申明 类
    local Account = { type="Account",age = 10 }
    -- 作为meta的table ，必须有__index属性， 在派生类中找不到的属性， 会在元类的__index中找
    Account.__index = Account
    function Account:new(o)
        o = o or {}
        setmetatable(o, self)
        -- 实例中找不到的变量， 会在派元类的__index中找
        --self.__index = self
        return o
    end
    function Account:hello()
        print("hello " .. self.age)
    end
    local a1 = Account:new()
    -- 下面的等价
    a1:hello()
    Account.hello(a1)
    Account.__index.hello(a1)
    getmetatable(a1).__index.hello(a1)

    -- 下面两种等价
    local a2 = Account:new { world = "hello" }
    local a3 = Account:new({ world = "hello" })
    print(a3.age, a3.world)

    -- 继承
    -- 继承和实例化开始一样
    -- 只是创建了一个基类的对象
    local HumanAccount = Account:new({ type="HumanAccount",name = "default_name" })
    -- 然后覆盖new方法
    function HumanAccount:new(o, name)
        o = o or {}
        setmetatable(o, self)
        -- 递归的(循环实现)： 实例中找不到的变量， 会在派元类的metatable.__index中找
        -- 最上层的父类, 只有index 没有metatable, 会终止递归
        self.__index = self
        return o
    end
    -- 覆盖已有方法
    function HumanAccount:hello()
        print("HumanAccount hello " .. self.name .. " " .. self.age)
    end
    -- 添加新方法

    local hacc1 = HumanAccount:new()
    hacc1:hello()
end
test_object()

local function multiple_inherit()
    -- 在多个父类中查找字段k
    local function search(k, pList)
        for i = 1, #pList do
            local v = pList[i][k]
            if v then
                return v
            end
        end
    end

    local function createClass(...)
        local c = {} -- 新类
        local parents = { ... }

        -- 类在其元表中搜索方法
        setmetatable(c, { __index = function(t, k)
            return search(k, parents)
        end })

        -- 将c作为其实例的元表
        c.__index = c

        -- 为这个新类建立一个新的构造函数
        function c:new(o)
            o = o or {}
            setmetatable(o, self)

            -- self.__index = self 这里不用设置了，在上面已经设置了c.__index = c
            return o
        end

        -- 返回新的类（原型）
        return c
    end

    -- 一个简单的类CA
    local CA = {}
    function CA:new(o)
        o = o or {}
        setmetatable(o, { __index = self })
        self.__index = self
        return o
    end

    function CA:setName(strName)
        self.name = strName
    end

    -- 一个简单的类CB
    local CB = {}
    function CB:new(o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end

    function CB:getName()
        return self.name
    end

    -- 创建一个c类，它的父类是CA和CB
    local MultipleInheritClass = createClass(CA, CB)

    -- 使用c类创建一个实例对象
    local obj = MultipleInheritClass:new { name = "Paul" }

    -- 设置objectC对象一个新的名字
    obj:setName("John")
    local newName = obj:getName()
    print(newName)
end
multiple_inherit()

local function private_object_value()
    local function newObject(defaultName)
        local self = { name = defaultName }
        local setName = function(v)
            self.name = v
        end
        local getName = function()
            return self.name
        end
        return { setName = setName, getName = getName }
    end

    local objectA = newObject("John")
    objectA.setName("John") -- 这里没有使用冒号访问
    print(objectA.getName())
end
private_object_value()
print("end")