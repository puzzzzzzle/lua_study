## 初始化环境
### 安装/重置虚拟机
- `cd lua_env && ./remake_env.sh`

### 安装/更新依赖
- `cd lua_env && ./lua load_dependencies.lua`

## 使用环境
### 命令行
- `source lua_env/lua_env.sh`

## debug
- 一般情况下使用IDE自带的lua调试器就行
- 解释器指定为 `./lua_env/lua`(是个shell) 会自动设置好环境变量
- 也可以手动设置环境变量, 这时候解释器要用lua_interpreter下的二进制
  - 参考 `./lua_env/lua_env.sh`

### emmy lua debug
- 先通过IDE启动debug server
  - debug connect IDE 模式
- 用 emmy debug server 提示代码, 写一个lua连接debug server脚本
  - eg: `lua_dbg.lua`
```
package.cpath = package.cpath .. ';/path/to/EmmyLua/debugger/emmy/mac/arm64/?.dylib'
local dbg = require('emmy_core')
dbg.tcpConnect('localhost', 9966)
```
- 重写一个lua执行脚本
  - eg: `dbg`
```
./lua_env/lua -l lua_dbg "$@"
```
- 为 dbg 添加可执行权限后, 就可以用它来启动lua脚本了, 启动后会自动连接到lua dbg server
- 这种方式也适用于嵌入c/c++的lua脚本调试