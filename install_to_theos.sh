set -e
make clean
make FINALPACKAGE=1
cp -Rv "./.theos/obj/AltList.framework" "$THEOS/lib"

mkdir -p "$THEOS/include/AltList"
find . -maxdepth 1 -name "ATL*.h" -exec cp -v {} "$THEOS/include/AltList" \; 
cp -v AltList.h "$THEOS/include/AltList"
echo "Successfully installed AltList"
