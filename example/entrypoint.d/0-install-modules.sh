#!/bin/bash

SERVER=https://modules.prosody.im/rocks/

install() {
  prosodyctl install --server="$SERVER" $1
}


install mod_http_upload
install mod_cloud_notify
install mod_vcard_muc
