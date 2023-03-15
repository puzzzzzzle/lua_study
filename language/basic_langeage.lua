for i = 0, 10, 2 do
    print(":", i)
end
-- 数组
print("arr")
local arr1 = { 1, "hello", 3.14 }
for i, v in ipairs(arr1) do
    print(i, ":", v)
end
-- table
print("table")
local t1 = { kkk = "a", vvv = "v" }
for k, v in pairs(t1) do
    print(k, ":", v)
end

-- 混合
print("mix")
local t1 = { 1, 2, 2, kkk = "a", vvv = "v" }
t1.a = 43
t1[45] = 45
for k, v in pairs(t1) do
    print(k, ":", v)
end

local hello = "hello"
print("hello 1",string.byte(hello,1))

-- 作用域
x = 10                -- global variable
do                    -- new block
    local x = x         -- new 'x', with value 10
    print(x)            --> 10
    x = x+1
    do                  -- another block
        local x = x+1     -- another 'x'
        print(x)          --> 12
    end
    print(x)            --> 11
end
print(x)              --> 10  (the global one)

--local dump = require("dump")
--
--print(dump(package.loaded))