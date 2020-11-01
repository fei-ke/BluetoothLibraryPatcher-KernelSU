# BluetoothLibraryPatcher
# by 3arthur6

set_vars() {
  samsung=`grep -Eqw "androidboot.odin_download|androidboot.warranty_bit|sec_debug" /proc/cmdline && echo 'true' || echo 'false'`
  bootloader=`grep -o androidboot.bootloader=.* /proc/cmdline | cut -d ' ' -f1 | cut -d '=' -f2`
  qcom=`grep -qw androidboot.hardware=qcom /proc/cmdline && echo 'true' || echo 'false'`

  if $BOOTMODE ; then
    ui_print "- Magisk Manager installation"
    sys="/sbin/.magisk/mirror/system"
  else
    ui_print "- Recovery installation"
    sys=`find $ANDROID_ROOT -mindepth 1 -maxdepth 2 -path "*system/build.prop" | xargs dirname`
  fi
  if ! $samsung ; then
    ui_print "- Only for Samsung devices!"
    abort
  fi
  if ! grep -qw ro.build.type=user $sys/build.prop ; then
    ui_print "- Only for Samsung stock based roms!"
    ui_print "- Not relevant for aosp roms!"
    abort
  fi
  if [ ${#bootloader} == 12 ] ; then
    model=SM-${bootloader:0:4}
  elif [ ${#bootloader} == 13 ] ; then
    model=SM-${bootloader:0:5}
  elif [ ${#bootloader} == 14 ] ; then
    model=SM-${bootloader:0:6}
  else
    model="Model not found"
  fi
  ui_print "- Searching for the hex sequence"
  if [ $API == 30 ] ; then
    ui_print "- $model on Android 11 detected"
    mod_path="$MODPATH/system/lib64/libbluetooth.so"
    sys_path="$sys/lib64/libbluetooth.so"
    if $qcom && xxd -p $sys_path | tr -d '\n' | grep -iq 88000054691180522925C81A6900003720008052 ; then
      pre_hex="88000054691180522925C81A6900003720008052"
      post_hex="04000014691180522925C81A69000037E0031F2A"
    else
      pre_hex=`xxd -p $sys_path | tr -d '\n' | grep -io ........F3031F2AF4031F2A3E000014 | tr '[:lower:]' '[:upper:]'`
      if [ -z $pre_hex ] ; then
        pre_hex="not_found"
      fi
      post_hex="1F2003D5F3031F2AF4031F2A3E000014"
    fi
  elif [ $API == 29 ] ; then
    ui_print "- $model on Android 10 detected"
    mod_path="$MODPATH/system/lib64/libbluetooth.so"
    sys_path="$sys/lib64/libbluetooth.so"
    if ! $IS64BIT ; then
      mod_path=`echo $mod_path | tr -d '64'`
      sys_path=`echo $sys_path | tr -d '64'`
      pre_hex=`xxd -p $sys_path | tr -d '\n' | grep -io ..B100250120 | tr '[:lower:]' '[:upper:]'`
      if [ -z $pre_hex ] ; then
        pre_hex="not_found"
      fi
      post_hex="00BF00250020"
    elif $qcom && xxd -p $sys_path | tr -d '\n' | grep -iq 88000054691180522925C81A69000037E0030032 ; then
      pre_hex="88000054691180522925C81A69000037E0030032"
      post_hex="04000014691180522925C81A69000037E0031F2A"
    else
      pre_hex=`xxd -p $sys_path | tr -d '\n' | grep -io ........F4031F2AF3031F2AE8030032 | tr '[:lower:]' '[:upper:]'`
      if [ -z $pre_hex ] ; then
        pre_hex="not_found"
      fi
      post_hex="1F2003D5F4031F2AF3031F2AE8031F2A"
    fi
  elif [ $API == 28 ] ; then
    ui_print "- $model on Android Pie detected"
    mod_path="$MODPATH/system/lib64/libbluetooth.so"
    sys_path="$sys/lib64/libbluetooth.so"
    if ! $IS64BIT ; then
      mod_path=`echo $mod_path | tr -d '64'`
      sys_path=`echo $sys_path | tr -d '64'`
      pre_hex=`xxd -p $sys_path | tr -d '\n' | grep -io ..B101200028 | tr '[:lower:]' '[:upper:]'`
      if [ -z $pre_hex ] ; then
        pre_hex="not_found"
      fi
      post_hex="00BF00200028"
    elif $qcom && xxd -p $sys_path | tr -d '\n' | grep -iq 7F1D0071E91700F9E83C0054 ; then
      pre_hex="7F1D0071E91700F9E83C0054"
      post_hex="E0031F2AE91700F9E8010014"
    else
      pre_hex="88000034E803003248070035"
      post_hex="1F2003D5E8031F2A48070035"
    fi
  elif [ $API == 27 ] ; then
    ui_print "- $model on Android Oreo 8.1 detected"
    mod_path="$MODPATH/system/lib64/hw/bluetooth.default.so"
    sys_path="$sys/lib64/hw/bluetooth.default.so"
    if ! $IS64BIT ; then
      mod_path=`echo $mod_path | tr -d '64'`
      sys_path=`echo $sys_path | tr -d '64'`
      pre_hex="09B1012032E0"
      post_hex="00BF002032E0"
    else
      pre_hex="88000034E803003228050035"
      post_hex="1F2003D5E8031F2A28050035"
    fi
  elif [ $API == 26 ] ; then
    ui_print "- $model on Android Oreo 8.0 detected"
    mod_path="$MODPATH/system/lib64/hw/bluetooth.default.so"
    sys_path="$sys/lib64/hw/bluetooth.default.so"
    if ! $IS64BIT ; then
      mod_path=`echo $mod_path | tr -d '64'`
      sys_path=`echo $sys_path | tr -d '64'`
      pre_hex="08B1012031E0"
      post_hex="00BF002031E0"
    else
      pre_hex="88000034E803003228050035"
      post_hex="1F2003D5E8031F2A28050035"
    fi
  elif [ $API == 25 ] ; then
    ui_print "- $model on Android Nougat 7.1 detected"
    mod_path="$MODPATH/system/lib/hw/bluetooth.default.so"
    sys_path="$sys/lib/hw/bluetooth.default.so"
    pre_hex="087850BBB548"
    post_hex="0878BDE0B548"
  elif [ $API == 24 ] ; then
    ui_print "- $model on Android Nougat 7.0 detected"
    mod_path="$MODPATH/system/lib/hw/bluetooth.default.so"
    sys_path="$sys/lib/hw/bluetooth.default.so"
    pre_hex="007840BB6A48"
    post_hex="002028E06A48"
  else
    ui_print "- Only for Android 11, 10, Pie, Oreo and Nougat!"
    abort
  fi
  echo -e "model=$model\nBOOTMODE=$BOOTMODE\nsys=$sys\nAPI=$API\nIS64BIT=$IS64BIT\nqcom=$qcom\nmod_path=$mod_path\nsys_path=$sys_path\npre_hex=$pre_hex\npost_hex=$post_hex" > $TMPDIR/vars.txt
}

extract() {
  if [ ! -f $sys_path ] ; then
    ui_print "- Aborting! Library not found!"
    abort
  else
    ui_print "- Copying library from system to module"
    mkdir -p `echo $mod_path | xargs dirname`
    cp -af $sys_path $mod_path
  fi
}

patch_lib() {
  ui_print "- Applying patch"
  if /data/adb/magisk/magiskboot hexpatch $mod_path $pre_hex $post_hex 2>/dev/null ; then
    ui_print "- Successfully patched!"
  else
    if /data/adb/magisk/magiskboot hexpatch $mod_path $post_hex 0 2>/dev/null ; then
      ui_print "- Aborting! Library already (system-ly) patched!"
    else
      ui_print "- Aborting! Library not supported!"
      cp -f $sys_path $sys/build.prop /data/misc/bluedroiddump/subBuffer.log $TMPDIR
      cd $TMPDIR
      tar -cf /sdcard/BluetoothLibPatcher-files.tar *
      ui_print " "
      ui_print "- To get support upload BluetoothLibPatcher-files.tar"
      ui_print "  created in your internal storage to the XDA thread."
    fi
    rm -rf $MODPATH
    abort
  fi
}

set_vars

extract

patch_lib
