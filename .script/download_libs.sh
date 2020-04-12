#!/bin/bash

SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd -P )"
SCRIPT_DIRNAME="$(basename "${SCRIPT_PATH}")"

LIBPATH=${SCRIPT_PATH}/../Externals/HDKey
LIBPATHSPV=${SCRIPT_PATH}/../Externals/SPVWrapper/SPVWrapper
LIBPATTERN="/elastos.*ios_arm64.*gz"
LIBPATTERNSPV="/elastos.*ios_arm64.*gz"
LIBDIR="-iphoneos"

if [ $1 = "x64" ] ; then
    LIBPATTERN="/elastos.*ios_x64-hdk.*gz"
    LIBPATTERNSPV="/elastos.*ios_x64-spv.*gz"
    LIBDIR="-iphonesimulator"
elif [ $1 = "macOS" ]; then
    LIBPATTERN="/elastos.*darwin_x64.*gz"
    LIBDIR="macosx"
fi

packageUrl=`curl https://github.com/ahl0107/Elastos.DID.Swift.SDK/releases/tag/internal-test | grep -e $LIBPATTERN -o`
packageUrlspv=`curl https://github.com/ahl0107/Elastos.DID.Swift.SDK/releases/tag/internal-test | grep -e $LIBPATTERNSPV -o`
libPackageName=${packageUrl##*/}
#libPackageNamespv=${packageUrlspv##*/}

cd /tmp
echo "succeed 1============"
echo "https://github.com"${packageUrl} >did_libs.txt
echo "succeed 2============${packageUrl}"
#echo "https://github.com"${packageUrlspv} >spv_libs.txt

#remove old package
rm ${libPackageName}
echo "succeed 3============${libPackageName}"
#rm ${libPackageNamespv}

wget -i did_libs.txt
echo "succeed 4============did_libs.txt"
#wget -i spv_libs.txt

cd ${LIBPATH}
echo "succeed ============5"

cd lib
mkdir -- ${LIBDIR}
echo "succeed ============6"
tar --strip-components=1 -zxf /tmp/${libPackageName} -C ${LIBDIR}/ lib
echo "succeed ============7"
#cd ${LIBPATHSPV}
#
#cd lib
#mkdir -- ${LIBDIR}
#tar --strip-components=1 -zxf /tmp/${libPackageNamespv} -C ${LIBDIR}/ lib
