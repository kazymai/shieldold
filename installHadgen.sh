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
  echo "Unexpected: rootcint not found in PATH. May be your installation of Fairsoft is not correct. Cannot build EGHadgen"
  exit
fi

# now we can compile everything
export WORKDIR=$(pwd)
echo "Current working directory is $WORKDIR"

if [ ! -d lib ];
then
  mkdir lib
fi

tar zxf hadgen.tar.gz
tar zxf THadgen.tar.gz

cd hadgen

case "$arch" in
    linux)
      . makeHadgen.linux
      ;;
    linuxx8664gcc)
      . makeHadgen.linuxx8664
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
ln  -s ../hadgen/lib/libHadgen2.so ../lib/libHadgen2.so

echo "Building libEGHadgen..."
# compile libEGHadgen
cd ../THadgen
ROOTDIR=$SIMPATH/tools/root
HADGENDIR=$WORKDIR

INCLUDE="-I$ROOTDIR/include -I$HADGENDIR/hadgen/inc -I$HADGENDIR/THadgen/inc -I$SIMPATH/include"
LIBDIR="-L$ROOTDIR/lib -L$HADGENDIR/lib -L$SIMPATH/lib"

LIBDEP="-lCore -lEG -lHadgen2"
echo Include directories $INCLUDE
#compile dictionaries to use in ROOT

rootcint -f G__Hadgen.cxx -c $INCLUDE ./inc/THadgen.h ./inc/LinkDef.h
g++ -fPIC -o G__Hadgen.o -c $INCLUDE `root-config --ldflags` G__Hadgen.cxx
g++ -fPIC -shared -Wl,-soname,libEGHadgen.so -o libEGHadgen.so $INCLUDE $LIBDIR $LIBDEP ./src/*.cxx G__Hadgen.o

cd ..
ln -s ../THadgen/libEGHadgen.so ./lib/libEGHadgen.so
# adding LD_LIBRARY_PATH to .bashrc

echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$HADGENDIR/lib" >> ~/.bashrc
echo 'export HADGEN_INSTALLED=true' >> ~/.bashrc
echo "DONE."
