#!/bin/bash

function is_in_path {
  s_prg=$1
  answer=$(which $s_prg)
  if [ "$answer" != "" ];
  then
    no_prg=$(which $s_prg | grep -c '^no')
    no_prg1=$(which $s_prg | grep -c "^no $s_prg")
    if [ "$no_prg" != "0" -o "$no_prg1" != "0" ];
    then 
      answer=""
    fi
  fi
  
  if [ "$answer" != "" ];
  then
    return 1
  else 
    return 0
  fi
}