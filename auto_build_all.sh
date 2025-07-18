echo "Starting auto build process..."
echo "Cleaning previous build directory..."
rm -rf x
echo "Setting up meson build with release configuration..."
meson setup x --buildtype=release --strip -Db_lto=true
echo "Starting ninja build..."
ninja -Cx
echo "Auto build completed successfully!"
