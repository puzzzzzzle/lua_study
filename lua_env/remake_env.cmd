@echo off
:: clean
mkdir lua_download_temp
rmdir /s /q lua_interpreter
:: set env
set lua_install_path=%cd%\lua_interpreter
set script_base_path=%cd%

:: open fail exit
set -e

:: install lua, eg: install_lua 5.4 4
:: para lua_version_major_minor(eg:5.4) lua_version_patch(eg:4)
install_lua() {
  echo %1 %2
  set lua_version_major=%1
  set lua_version_patch=%2
  set lua_version=lua-%lua_version_major%.%lua_version_patch%
  set lua_tgz=%lua_version%.tar.gz

  cd "%script_base_path%"

  :: download lua tgz
  cd lua_download_temp

  if not exist "%lua_tgz%" (
    echo download lua tgz %lua_version%
    curl -R -O http://www.lua.org/ftp/%lua_version%.tar.gz
  )

  :: install lua
  mkdir %lua_install_path%
  tar -zxf %lua_tgz%
  cd %lua_version%
  make -j
  make install INSTALL_TOP="%lua_install_path%\lua"
  cd "%script_base_path%"

  echo # lua with local env > lua_path.sh
  echo export LUA_PATH^="^
%lua_install_path%\luarocks\share\lua\%lua_version_major%\?.lua;^
%lua_install_path%\luarocks\share\lua\%lua_version_major%\?\/init.lua;^
%lua_install_path%\lua\share\lua\%lua_version_major%\?.lua;^
%lua_install_path%\lua\share\lua\%lua_version_major%\?\/init.lua;^
%lua_install_path%\lua\lib\lua\%lua_version_major%\?.lua;^
%lua_install_path%\lua\lib\lua\%lua_version_major%\?\/init.lua;^
.\?.lua;^
.\?\/init.lua"^
>> lua_path.sh

  echo export LUA_CPATH^="^
%lua_install_path%\luarocks\lib\lua\%lua_version_major%\?.so;^
%lua_install_path%\lua\lib\lua\%lua_version_major%\?.so;^
%lua_install_path%\lua\lib\lua\%lua_version_major%\loadall.so;^
.\?.so"^
>> lua_path.sh
  chmod +x lua_path.sh

  echo source "%script_base_path%\lua_path.sh" > lua_env.sh
  echo set PATH="%lua_install_path%\lua\bin;%lua_install_path%\luarocks\bin;%%PATH%%" >> lua_env.sh
  chmod +x lua_env.sh

  echo @echo off > lua.bat
  echo call "%script_base_path%\lua_env.sh" >> lua.bat
  echo "%lua_install_path%\lua\bin\lua" %%* >> lua.bat
  chmod +x lua.bat

  echo @echo off > luac.bat
  echo call "%script_base_path%\lua_env.sh" >> luac.bat
  echo "%lua_install_path%\lua\bin\luac" %%* >> luac.bat
  chmod +x luac.bat

}
:: install luarocks
:: para: lua_version luarocks_version
install_luarocks() {
  cd "%script_base_path%"

  :: clone luarocks
  cd lua_download_temp

  if not exist luarocks (
    git clone https://github.com/luarocks/luarocks.git
  )

  :: install luarocks
  cd luarocks
  git fetch --all
  git checkout %2
  call bootstrap.bat
  call "%lua_install_path%\lua.bat" configure --prefix="%lua_install_path%\luarocks" --lua-version="%1" --with-lua-bin="%lua_install_path%\lua\bin"  ^
  --with-lua="%lua_install_path%\lua" --with-lua-include="%lua_install_path%\lua\include" --with-lua-lib="%lua_install_path%\lua\lib"
  call make.bat
  call make.bat install

  cd "%script_base_path%"
  mklink /h luarocks "%lua_install_path%\luarocks\bin\luarocks.bat"
}
:: install luabridge
:: para: branch/tag
install_luabridge(){
  cd "%script_base_path%"

  :: clone luarocks
  cd lua_download_temp

  if not exist LuaBridge (
    git clone https://github.com/vinniefalco/LuaBridge.git
  )

  cd LuaBridge
  git fetch --all
  git checkout %1
  call cmake -DCMAKE_BUILD_TYPE=Release -DLUABRIDGE_TESTING=OFF -DCMAKE_INSTALL_PREFIX="%lua_install_path%\LuaBridge" -B build
  cd build
  call make.bat
  call make.bat install
  cd "%script_base_path%"
}
install_lua 5.4 4
install_luarocks 5.4 v3.7.0
install_luabridge master
