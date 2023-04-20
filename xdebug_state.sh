#!/bin/bash

read -p "Enable (1) or disable (0) XDebug ?" XDEBUG_ENABLE

if [ $XDEBUG_ENABLE -eq 1 ]; then

  read -p "Remote machine ($xdebugRemoteMachine si vide) : " XDEBUG_REMOTE_MACHINE
  if [ -z $XDEBUG_REMOTE_MACHINE ]; then
    XDEBUG_REMOTE_MACHINE="$xdebugRemoteMachine"
  fi

  read -p "Remote port machine (90$userPrefixPort si vide) : " XDEBUG_REMOTE_PORT_MACHINE
  if [ -z $XDEBUG_REMOTE_PORT_MACHINE ]; then
    XDEBUG_REMOTE_PORT_MACHINE="90$userPrefixPort"
  fi

  echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.idekey=PHPSTORM" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.client_host=$XDEBUG_REMOTE_MACHINE" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.client_port=$XDEBUG_REMOTE_PORT_MACHINE" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.log='/tmp/xdebug.log'" >> /usr/local/etc/php/conf.d/xdebug.ini \
      && echo "xdebug.log_level=3" >> /usr/local/etc/php/conf.d/xdebug.ini

  read -p "Avec debug en mode CLI (1) ou non (vide) ? : " XDEBUG_REMOTE_AVEC_CLI
  if [ -z $XDEBUG_REMOTE_AVEC_CLI ]; then
     unset XDEBUG_CONFIG
  else
     export XDEBUG_CONFIG=""
  fi

else
  echo "" > /usr/local/etc/php/conf.d/xdebug.ini
fi

/etc/init.d/apache2 reload
