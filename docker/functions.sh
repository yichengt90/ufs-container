#!/bin/bash

function get_ufs_tag {
  set +x
  git ls-remote https://github.com/ufs-community/ufs-weather-model.git HEAD | awk '{ print substr($1,0,7)}'
  set -x
}
  
function parse_yaml {
  set +x
  local yamlprefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\):|\1|" \
       -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
       -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
     indent = length($1)/2;
     vname[indent] = $2;
     for (i in vname) {if (i > indent) {delete vname[i]}}
     if (length($3) > 0) {
        vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
        printf("export %s%s%s=\"%s\"\n", "'$yamlprefix'",vn, $2, $3);
     }
  }'
  set -x
}

#
export -f get_ufs_tag
export -f parse_yaml

#
export ufs_tag="$(get_ufs_tag)"

#
set +x
