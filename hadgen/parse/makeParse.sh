#!/bin/bash
gcc -c -fPIC src/main.c
g77 -c -m64 -fPIC src/fparse.f
g77 -fPIC -o parse main.o fparse.o
rm -rf *.o
./parse tabnuc.h
