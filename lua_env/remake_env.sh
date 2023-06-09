#!/usr/bin/env sh
# clean
mkdir -p lua_download_temp
rm -vr lua_interpreter
# set env
lua_install_path=$(pwd)/lua_interpreter
script_base_path=$(pwd)

# open fail exit
set -e

# install lua, eg: install_lua 5.4 4
# para lua_version_major_minor(eg:5.4) lua_version_patch(eg:4)
install_lua() {
  echo $1 $2
  local lua_version_major=$1
  local lua_version_patch=$2
  local lua_version="lua-${lua_version_major}.${lua_version_patch}"
  local lua_tgz=${lua_version}.tar.gz

  cd "${script_base_path}"

  # download lua tgz
  cd lua_download_temp

  if [ ! -f "./${lua_tgz}" ];
  then
    echo "download lua tgz ${lua_version}"
    curl -R -O http://www.lua.org/ftp/${lua_version}.tar.gz
  fi

  # install lua
  mkdir -p ${lua_install_path}
  tar -zxf ${lua_tgz}
  cd ${lua_version}
  make -j
  make install INSTALL_TOP="${lua_install_path}/lua"
  cd "${script_base_path}"

  cat > lua_path.sh <<EOF
# lua with local env
export LUA_PATH="\
${lua_install_path}/luarocks/share/lua/${lua_version_major}/?.lua;\
${lua_install_path}/luarocks/share/lua/${lua_version_major}/?/init.lua;\
${lua_install_path}/lua/share/lua/${lua_version_major}/?.lua;\
${lua_install_path}/lua/share/lua/${lua_version_major}/?/init.lua;\
${lua_install_path}/lua/lib/lua/${lua_version_major}/?.lua;\
${lua_install_path}/lua/lib/lua/${lua_version_major}/?/init.lua;\
./?.lua;\
./?/init.lua"

export LUA_CPATH="\
${lua_install_path}/luarocks/lib/lua/${lua_version_major}/?.so;\
${lua_install_path}/lua/lib/lua/${lua_version_major}/?.so;\
${lua_install_path}/lua/lib/lua/${lua_version_major}/loadall.so;\
./?.so"
EOF
  chmod +x lua_path.sh

cat >lua_env.sh <<EOF
source "${script_base_path}/lua_path.sh"
export PATH="${lua_install_path}/lua/bin:${lua_install_path}/luarocks/bin:\${PATH}"
EOF
  chmod +x lua_env.sh

  cat > lua <<EOF
#!/usr/bin/env sh
source "${script_base_path}/lua_env.sh"
"${lua_install_path}/lua/bin/lua" "\$@"
EOF
  chmod +x lua

  cat >luac <<EOF
#!/usr/bin/env sh
source "${script_base_path}/lua_env.sh"
"${lua_install_path}/lua/bin/luac" "\$@"
EOF
  chmod +x luac


}
# install luarocks
# para: lua_version luarocks_version
install_luarocks() {
  cd "${script_base_path}"

  # clone luarocks
  cd lua_download_temp

  if [ ! -x "./luarocks" ];
  then
    git clone https://github.com/luarocks/luarocks.git
  fi

  # install luarocks
  cd luarocks
  git fetch --all
  git checkout "$2"
  ./configure --prefix="${lua_install_path}/luarocks" --lua-version="$1" --with-lua-bin="${lua_install_path}/lua/bin"  \
  --with-lua="${lua_install_path}/lua" --with-lua-include="${lua_install_path}/lua/include" --with-lua-lib="${lua_install_path}/lua/lib"
  make -j
  make install

  cd "${script_base_path}"
  ln -sf "${lua_install_path}"/luarocks/bin/luarocks .
}
# install luabridge
# para: branch/tag
install_luabridge(){
  cd "${script_base_path}"

  # clone luarocks
  cd lua_download_temp

  if [ ! -x "./LuaBridge" ];
  then
    git clone https://github.com/vinniefalco/LuaBridge.git
  fi

  cd LuaBridge
  git fetch --all
  git checkout "$1"
  cmake -DCMAKE_BUILD_TYPE=Release -DLUABRIDGE_TESTING=OFF -DCMAKE_INSTALL_PREFIX="${lua_install_path}/LuaBridge" -B build
  cd build
  make -j
  make install
  cd "${script_base_path}"
}
install_lua 5.4 4
install_luarocks 5.4 v3.9.2
install_luabridge master