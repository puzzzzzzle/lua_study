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

local function test_table_with_func_wrapper()
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
test_table_with_func_wrapper()

print("end")