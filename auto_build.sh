rm -rf x
meson setup x --buildtype=release --strip -Db_lto=true -Dprebuilt_server=scrcpy-server-v3.3.1
ninja -Cx