set -e
make clean
make FINALPACKAGE=1
cp -Rv "./.theos/obj/AltList.framework" "$THEOS/lib"

make clean
make FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
mkdir -p "$THEOS/lib/iphone/rootless/lib"
cp -Rv "./.theos/obj/AltList.framework" "$THEOS/lib/iphone/rootless"

echo "Successfully installed AltList"
