set -e
make clean
make FINALPACKAGE=1
cp -Rv "./.theos/obj/AltList.framework" "$THEOS/lib"
echo "Successfully installed AltList"
