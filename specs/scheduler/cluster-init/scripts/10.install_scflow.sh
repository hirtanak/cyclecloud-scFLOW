#!/bin/bash
# Copyright (c) 2020 Hiroshi Tanaka, hirtanak@gmail.com @hirtanak
set -ex

echo "starting 10.install_cradle.sh"

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
echo ${CUSER} > /mnt/exports/shared/CUSER
HOMEDIR=/shared/home/${CUSER}
CYCLECLOUD_SPEC_PATH=/mnt/cluster-init/scFlow/scheduler

scFLOW_VERSION=13
scFLOW_VERSION=$(jetpack config scFLOW_VERSION)
STREAM_VERSION=st2020
STREAM_VERSION=$(jetpack config STREAM_VERSION)

# License Port Setting
LICENSE=$(jetpack config LICENSE)
(echo "CRADLE_LICENSE_FILE=${LICENSE}"; echo "export PATH=$PATH:/mnt/exports/shared/home/azureuser/apps/sct${scFLOW_VERSION}/bin") > /etc/profile.d/cradle.sh
chmod a+x /etc/profile.d/cradle.sh

# Create tempdir
tmpdir=$(mktemp -d)
pushd $tmpdir

yum install -y redhat-lsb-core

# Installation
case ${scFLOW_VERSION} in
    11 )
    # scFLOW Directory
    if [[ ! -d ${HOMEDIR}/SCRYU${scFLOW_VERSION} ]]; then
       mkdir -p ${HOMEDIR}/SCRYU${scFLOW_VERSION}
       chown -R ${CUSER}:${CUSER} ${HOMEDIR}/SCRYU${scFLOW_VERSION}
    fi
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/SCRYU${scFLOW_VERSION}
    # installation
    if [[ ! -f ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer.zip ]]; then
       jetpack download sct${scFLOW_VERSION}_lnx64_installer.zip ${HOMEDIR}
       chown ${CUSER}:${CUSER} ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer.zip
    fi
    if [[ ! -f ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer ]]; then
       chown ${CUSER}:${CUSER} ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer.zip
       unzip -o ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer.zip -d ${HOMEDIR}
       chmod -R a+rX ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer
       chown -R ${CUSER}:${CUSER} ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer
       tar zxfp ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer/modules/rh4amd64/sct${scFLOW_VERSION}Pii.tgz -C ${HOMEDIR}/SCRYU${scFLOW_VERSION}/
    fi
    # Intel MPI
    if [[ ! -f ${HOMEDIR}/l_mpi_p_5.1.3.223.tgz ]]; then
       jetpack download l_mpi_p_5.1.3.223.tgz ${HOMEDIR}/
       chown ${CUSER}:${CUSER} ${HOMEDIR}/l_mpi_p_5.1.3.223.tgz
    fi
    if [[ ! -d /opt/intel/impi/5.1.3.223 ]]; then
       tar zxf ${HOMEDIR}/l_mpi_p_5.1.3.223.tgz -C ${HOMEDIR}/
       sed -i -e 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/' ${HOMEDIR}/l_mpi_p_5.1.3.223/silent.cfg
       sed -i -e 's/ACTIVATION_TYPE=exist_lic/ACTIVATION_TYPE=trial_lic/' ${HOMEDIR}/l_mpi_p_5.1.3.223/silent.cfg
       ${HOMEDIR}/l_mpi_p_5.1.3.223/install.sh -s ${HOMEDIR}/l_mpi_p_5.1.3.223/silent.cfg
       chown -R ${CUSER}:${CUSER} ${HOMEDIR}/l_mpi_p_5.1.3.223
    fi
    ;;
    13 )
    # scFLOW Directory
    if [[ ! -d ${HOMEDIR}/SCRYU${scFLOW_VERSION} ]]; then
       mkdir -p ${HOMEDIR}/SCRYU${scFLOW_VERSION}
       chown -R ${CUSER}:${CUSER} ${HOMEDIR}/SCRYU${scFLOW_VERSION}
    fi
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/SCRYU${scFLOW_VERSION}
    # installation
    if [[ ! -d ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer ]]; then
       jetpack download sct${scFLOW_VERSION}_lnx64_installer.zip ${HOMEDIR}
       unzip ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer.zip -d ${HOMEDIR}
    fi
    chmod -R a+rX ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer
    tar zxf ${HOMEDIR}/sct${scFLOW_VERSION}_lnx64_installer/modules/sctsol${scFLOW_VERSION}Pii_net.tgz -C ${HOMEDIR}/SCRYU${scFLOW_VERSION}/
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/SCRYU${scFLOW_VERSION}
    # Intel MPI
    if [[ ! -f ${HOMEDIR}/l_mpi_p_5.1.3.223.tgz ]]; then
       jetpack download l_mpi_p_5.1.3.223.tgz ${HOMEDIR}/
       chown ${CUSER}:${CUSER} ${HOMEDIR}/l_mpi_p_5.1.3.223.tgz
    fi
    if [[ ! -d /opt/intel/impi/5.1.3.223 ]]; then
       tar zxf ${HOMEDIR}/l_mpi_p_5.1.3.223.tgz -C ${HOMEDIR}/
       sed -i -e 's/ACCEPT_EULA=decline/ACCEPT_EULA=accept/' ${HOMEDIR}/l_mpi_p_5.1.3.223/silent.cfg
       sed -i -e 's/ACTIVATION_TYPE=exist_lic/ACTIVATION_TYPE=trial_lic/' ${HOMEDIR}/l_mpi_p_5.1.3.223/silent.cfg
       ${HOMEDIR}/l_mpi_p_5.1.3.223/install.sh -s ${HOMEDIR}/l_mpi_p_5.1.3.223/silent.cfg
    fi
    ;;
    scFLOW2020 )
    # scFLOW Directory
    if [[ ! -d ${HOMEDIR}/${scFLOW_VERSION} ]]; then
       mkdir -p ${HOMEDIR}/${scFLOW_VERSION}
       chown -R ${CUSER}:${CUSER} ${HOMEDIR}/${scFLOW_VERSION}
    fi
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/${scFLOW_VERSION}
    # installation
    if [[ ! -f ${HOMEDIR}/scFLOW2020_lnx64_installer_202005.bin ]]; then
       jetpack download scFLOW2020_lnx64_installer_202005.bin ${HOMEDIR}
       chown ${CUSER}:${CUSER} ${HOMEDIR}/scFLOW2020_lnx64_installer_202005.bin
       chmod a+ ${HOMEDIR}/scFLOW2020_lnx64_installer_202005.bin
    fi
    if [[ ! -d ${HOMEDIR}/${scFLOW_VERSION}/Dscflowsol2020 ]]; then
       chmod +x ${HOMEDIR}/scFLOW2020_lnx64_installer_202005.bin
       ${HOMEDIR}/scFLOW2020_lnx64_installer_202005.bin -s i -d ${HOMEDIR}/${scFLOW_VERSION} -c CRADLE_LICENSE_FILE=${LICENSE}
    fi
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/${scFLOW_VERSION}
    ;;
esac

case ${STREAM_VERSION} in
    st2020 )
    # STREAM Directory
    if [[ ! -d ${HOMEDIR}/STREAM/${STREAM_VERSION} ]]; then
       mkdir -p ${HOMEDIR}/STREAM/${STREAM_VERSION}
       chown ${CUSER}:${CUSER} ${HOMEDIR}/STREAM
       chown -R ${CUSER}:${CUSER} ${HOMEDIR}/STREAM/${STREAM_VERSION}
    fi
    chown ${CUSER}:${CUSER} ${HOMEDIR}/STREAM
    chown -R ${CUSER}:${CUSER} ${HOMEDIR}/STREAM/${STREAM_VERSION}
    # installation
    if [[ ! -f ${HOMEDIR}/st2020_lnx64_installer_202005.bin ]]; then
       jetpack download st2020_lnx64_installer_202005.bin ${HOMEDIR}
       chown ${CUSER}:${CUSER} ${HOMEDIR}/st2020_lnx64_installer_202005.bin
       chmod +x ${HOMEDIR}/st2020_lnx64_installer_202005.bin
    fi
    if [[ ! -f ${HOMEDIR}/STREAM/st2020/bin/stsol2020 ]]; then
       chmod +x ${HOMEDIR}/st2020_lnx64_installer_202005.bin
       ${HOMEDIR}/st2020_lnx64_installer_202005.bin -s i -d ${HOMEDIR}/STREAM/${STREAM_VERSION} -c CRADLE_LICENSE_FILE=${LICENSE}
    fi
    ;;
esac

if [ ! -f ${HOMEDIR}/cradlesetup.sh ]; then
   cp ${CYCLECLOUD_SPEC_PATH}/files/cradlesetup.sh ${HOMEDIR}
fi
chmod a+rx ${HOMEDIR}/cradlesetup.sh
chown -R ${CUSER}:${CUSER} ${HOMEDIR}/cradlesetup.sh

if [ ! -f ${HOMEDIR}/cradlerun.sh ]; then
   cp ${CYCLECLOUD_SPEC_PATH}/files/cradlerun.sh ${HOMEDIR}
fi
chmod a+rx ${HOMEDIR}/cradlerun.sh
chown -R ${CUSER}:${CUSER} ${HOMEDIR}/cradlerun.sh

yum install -y htop

# set up dirctory and apps.
chmod -R a+rx ${HOMEDIR}
chown -R ${CUSER}:${CUSER} ${HOMEDIR}

#clean up
popd
rm -rf $tmpdir


echo "end 10.install_cradle.sh"
