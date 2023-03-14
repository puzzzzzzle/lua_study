# clean
mkdir -p lua_download_temp
rm -vr lua_interpreter
# set env
lua_install_path=$(pwd)/lua_interpreter
script_base_path=$(pwd)

# open fail exit
set -e

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
  else
    echo "lua file already exists"
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
cat > lua <<EOF
source ${script_base_path}/lua_path.sh
${lua_install_path}/lua/bin/lua "\$@"
EOF
  chmod +x lua

cat >luac <<EOF
source ${script_base_path}/lua_path.sh
${lua_install_path}/lua/bin/luac "\$@"
EOF

cat >lua
  chmod +x luac
}

install_luarocks() {
  cd "${script_base_path}"

  # clone luarocks
  cd lua_download_temp

  if [ ! -x "./luarocks" ];
  then
    echo "download luarocks"
    git clone https://github.com/luarocks/luarocks.git
  else
    echo "luarocks file already exists"
  fi

  # install luarocks
  cd luarocks
  ./configure --prefix="${lua_install_path}/luarocks" --lua-version="$1" --with-lua-bin="${lua_install_path}/lua/bin"  \
  --with-lua="${lua_install_path}/lua" --with-lua-include="${lua_install_path}/lua/include" --with-lua-lib="${lua_install_path}/lua/lib"
  make -j
  make install

  cd "${script_base_path}"
  ln -sf "${lua_install_path}"/luarocks/bin/** .
}

install_lua 5.4 4
install_luarocks 5.4
