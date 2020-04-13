#!/bin/bash

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P )"
SCRIPT_DIRNAME="$(basename "${SCRIPT_PATH}")"

LIBPATH=${SCRIPT_PATH}/../Externals/HDKey
LIBPATH_SPV=${SCRIPT_PATH}/../Externals/SPVWrapper/SPVWrapper
LIBPATTERN="/ahl0107.*ios_arm64.*zip"
LIBPATTERN_SPV="/ahl0107.*ios_spv_x64.*zip"
LIBDIR="-iphoneos"

if [ $1 = "x64" ] ; then
    LIBPATTERN="/ahl0107.*ios_x64.*zip"
    LIBPATTERN_SPV="/ahl0107.*ios_spv_x64.*zip"
    LIBDIR="-iphonesimulator"
elif [ $1 = "macOS" ]; then
    LIBPATTERN="/ahl0107.*darwin_x64.*gz"
    LIBDIR="macosx"
fi

packageUrl=`curl https://github.com/ahl0107/Elastos.DID.Swift.SDK/releases/tag/internal-test | grep -e $LIBPATTERN -o`
libPackageName=${packageUrl##*/}
packageUrl_spv=`curl https://github.com/ahl0107/Elastos.DID.Swift.SDK/releases/tag/internal-test | grep -e $LIBPATTERN_SPV -o`
libPackageName_spv=${packageUrl_spv##*/}
echo "1"
echo $packageUrl
echo $packageUrl_spv
echo "2"

cd /tmp
echo "https://github.com"${packageUrl} >did_libs.txt
echo "https://github.com"${packageUrl_spv} >spv_libs.txt

#remove old package
rm ${libPackageName}
rm ${libPackageName_spv}

wget -i did_libs.txt
wget -i spv_libs.txt

cd ${LIBPATH}
mkdir lib

cd lib
mkdir -- ${LIBDIR}
tar --strip-components=1 -zxf /tmp/${libPackageName} -C ${LIBDIR}

cd ${LIBPATTERN_SPV}
mkdir lib

cd lib
mkdir -- ${LIBDIR}
tar --strip-components=1 -zxf /tmp/${libPackageName_spv} -C ${LIBDIR}

