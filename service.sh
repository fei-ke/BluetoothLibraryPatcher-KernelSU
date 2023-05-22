# BluetoothLibraryPatcher
# ota survival script
# by 3arthur6

if $KSU ; then
  exit 0
fi

MODDIR=${0%/*}
previouslibmd5sum_tmp

if [[ $previouslibmd5sum != `md5sum $(find $(magisk --path)/.magisk/mirror/system/post_path)|cut -d " " -f1` ]] ; then
  magisk --install-module $MODDIR/module.zip
else
  exit
fi
