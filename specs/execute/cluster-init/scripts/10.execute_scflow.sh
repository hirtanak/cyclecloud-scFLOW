#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -ex

echo "starting 10.execute_scflow.sh"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# disabling selinux
echo "disabling selinux"
setenforce 0
sed -i -e "s/^SELINUX=enforcing$/SELINUX=disabled/g" /etc/selinux/config

CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/jetpackd.log | awk '{print $6}')
CUSER=${CUSER//\'/}
CUSER=${CUSER//\`/}
# After CycleCloud 7.9 and later 
if [[ -z $CUSER ]]; then
   CUSER=$(grep "Added user" /opt/cycle/jetpack/logs/initialize.log | awk '{print $6}' | head -1)
   CUSER=${CUSER//\`/}
fi
echo ${CUSER} > /shared/CUSER
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/scFlow/execute

scFLOW_VERSION=13
scFLOW_VERSION=$(jetpack config scFLOW_VERSION)
STREAM_VERSION=st2020
STREAM_VERSION=$(jetpack config STREAM_VERSION)

# License Port Setting
LICENSE=$(jetpack config LICENSE)
(echo "CRADLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:/mnt/exports/shared/home/azureuser/apps/sct${scFLOW_VERSION}/bin") > /etc/profile.d/cradle.sh
chmod +x /etc/profile.d/cradle.sh

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

yum install -y htop

#clean up
popd
rm -rf $tmpdir


echo "end 10.execute_scflow.sh"
