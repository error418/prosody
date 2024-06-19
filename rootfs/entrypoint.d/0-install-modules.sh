#!/bin/bash

SERVER=https://modules.prosody.im/rocks/

install() {
  prosodyctl install --server="$SERVER" $1
}

if [[ -z "${PROSODY_EXTRA_MODULES}" ]]; then
  echo "no extra modules to install"
else
  for i in $PROSODY_EXTRA_MODULES
  do
    install $1
  done
fi
