#!/bin/bash

mkfifo .botfile
chan=$1
if [ $2 != '' ] && [ -f $2 ] ; then
  key=`cat $2`
fi

tail -f .botfile | openssl s_client -connect irc.cat.pdx.edu:6697 | while true; do
  if [[ -z $started ]] ; then
    echo "USER d2lbot d2lbot d2lbot :d2lbot" >> .botfile
    echo "NICK d2lminusminus" >> .botfile
    echo "JOIN #$chan $key" >> .botfile
    started="yes"
  fi
  read irc
  echo $irc
  if `echo $irc | cut -d ' ' -f 1 | grep PING > /dev/null`; then
    echo "PONG" >> .botfile
  elif `echo $irc | grep PRIVMSG | grep -i d2l > /dev/null` ; then
    nick="${irc%%!*}"; nick="${nick#:}"
    if [[ $nick != 'd2lminusminus' ]] ; then
      chan=`echo $irc | cut -d ' ' -f 3`
      echo "PRIVMSG $chan :d2l--" >> .botfile
    fi
  fi
done
