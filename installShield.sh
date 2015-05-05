#!/bin/bash

tar zxf scripts.tar.gz

source scripts/functions.sh

# FIRST OF ALL CHECK SIMPATH

if [ "$SIMPATH" != "" ];
then
  echo "Fairsoft installation found at $SIMPATH"
else
  echo "ERROR: Fairsoft installation not found, please provide SIMPATH first"
  exit
fi

arch=`uname -s | tr '[A-Z]' '[a-z]'`

# now check if g77 is avaliable
is_in_path g77
result=$?
if [ "$result" != "1" ];
then
  echo "g77 not found in PATH. Please install g77 first"
  exit
fi

# now check if gcc and g++ are available
is_in_path gcc
result=$?
if [ "$result" != "1" ];
then
  echo "gcc not found in PATH. Please install gcc first (how can live without it?)"
  exit
fi
is_in_path g++
result=$?
if [ "$result" != "1" ];
then
  echo "g++ not found in PATH. Please install g++ first"
  exit
fi
is_in_path rootcint
result=$?
if [ "$result" != "1" ];
then
  echo "Unexpected: rootcint not found in PATH. May be your installation of Fairsoft is not correct. Cannot build EGShield"
  exit
fi

# now we can compile everything
export WORKDIR=$(pwd)
echo "Current working directory is $WORKDIR"

if [ ! -d lib ];
then
  mkdir lib
fi

tar zxf shield.tar.gz
tar zxf TShield.tar.gz

cd shield

case "$arch" in
    linux)
      . makeShield.linux
      ;;
    linuxx8664gcc)
      . makeShield.linuxx8664
      ;;
# Next are MAC OS and solaris, not implemented yet
#    macosx)
#      if [ "$FC" = "g77" ];
#      then
#       echo
#        . makeHadgen.macosxg77
#      else
#        echo
#        . makeHadgen.macosx
#      fi 
#      ;;     
#    macosx64)
#      if [ ! -e makeHadgen.macosx64 ];
#      then
#        cp makeHadgen.macosx makeHadgen.macosx64
#        echo "*** Patching the hadgen Makefile to compile on 64bit Mac OS X" | tee -a $logfile
#        mysed '^gcc' 'gcc -m64' makeHadgen.macosx64 
#        mysed '^gfortran' 'gfortran -m64' makeHadgen.macosx64 
#        mysed 'libgfortran.a' 'x86_64/libgfortran.a' makeHadgen.macosx64 has_salsh_in_string
#      fi
#      echo "*** Start Compilation .........."
#      . makeHadgen.macosx64 
#      ;;
#    solarisCC5)
#      mysed 'gcc' 'cc' makeHadgen.solaris
#      mysed '/opt/SUNWspro/bin/f77' 'f77' makeHadgen.solaris yes
#
#      . makeHadgen.solaris
#      ;;     
#    solarisgcc)
#      mysed '/opt/SUNWspro/bin/f77' 'g77' makeHadgen.solaris yes
#
#      . makeHadgen.solaris
#      ;;     
    *)
      echo "No Makefile for the setting arch $arch and $compiler"
      echo "Stop the script at this point"
      exit
      ;;
  esac
  
# make a link to lib
ln  -s ../shield/lib/libShield.so ../lib/libShield.so

echo "Building libEGShield..."
# compile libEGShield
cd ../TShield
ROOTDIR=$SIMPATH/tools/root
SHIELDDIR=$WORKDIR

INCLUDE="-I$ROOTDIR/include -I$SHIELDDIR/shield/inc -I$SHIELDDIR/TShield/inc -I$WORKDIR/hadgen/inc -I$SIMPATH/include"
LIBDIR="-L$ROOTDIR/lib -L$SHIELDDIR/lib -L$SIMPATH/lib"

LIBDEP="-lCore -lEG -lShield -lHadgen2"

#compile dictionaries to use in ROOT

rootcint -f G__Shield.cxx -c $INCLUDE ./inc/TShield.h ./inc/LinkDef.h
g++ -fPIC -o G__Shield.o -c $INCLUDE `root-config --ldflags` G__Shield.cxx
g++ -fPIC -shared -Wl,-soname,libEGShield.so -o libEGShield.so $INCLUDE $LIBDIR $LIBDEP ./src/*.cxx G__Shield.o

cd ..
ln -s ../TShield/libEGShield.so ./lib/libEGShield.so
# adding LD_LIBRARY_PATH to .bashrc

echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$SHIELDDIR/lib" >> ~/.bashrc
echo 'export HADGEN_INSTALLED=true' >> ~/.bashrc
echo "DONE."
