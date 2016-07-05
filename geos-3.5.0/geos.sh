#!/bin/bash
  
BUILD_I386_IOS_SIM=1
BUILD_ARMV7_IPHONE=1
BUILD_ARMV7S_IPHONE=1
BUILD_ARM64_IPHONE=1
BUILD_x86_64_SIM=1
 
BUILD_TARGET=geos 
 
IOS_MIN_SDK=7.0
  
(
  
PWD=`pwd`
PREFIX=${PWD}/${BUILD_TARGET}
 
rm -rf ${PREFIX}/platform
mkdir -p ${PREFIX}/platform
  
EXTRA_MAKE_FLAGS="-j4"
  
XCODEDIR=`xcode-select --print-path`
 
IOS_SDK=$(xcodebuild -showsdks | grep iphoneos | sort | head -n 1 | awk '{print $NF}')
SIM_SDK=$(xcodebuild -showsdks | grep iphonesimulator | sort | head -n 1 | awk '{print $NF}')
 
 
IPHONEOS_PLATFORM=${XCODEDIR}/Platforms/iPhoneOS.platform
IPHONEOS_SYSROOT=${IPHONEOS_PLATFORM}/Developer/SDKs/${IOS_SDK}.sdk
 
IPHONESIMULATOR_PLATFORM=${XCODEDIR}/Platforms/iPhoneSimulator.platform
IPHONESIMULATOR_SYSROOT=${IPHONESIMULATOR_PLATFORM}/Developer/SDKs/${SIM_SDK}.sdk
 
CC=clang
CFLAGS="-DNDEBUG -g -O0 -pipe -fPIC -fcxx-exceptions"
CXX=clang
CXXFLAGS="${CFLAGS} -std=c++11 -stdlib=libc++"
LDFLAGS="-stdlib=libc++"
LIBS="-lc++ -lc++abi"
 
 
 
if [ $BUILD_ARMV7_IPHONE -eq 1 ]
then
 
 
echo "##################"
echo " armv7 for iPhone"
echo "##################"
 
 
(
        cd ${PWD}
     
        make ${EXTRA_MAKE_FLAGS} distclean
    ./configure --build=x86_64-apple-darwin15.5.0 --host=armv7-apple-darwin15.5.0 --enable-static --disable-shared --prefix=${PREFIX} "CC=${CC}" "CFLAGS=${CFLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -arch armv7 -isysroot ${IPHONEOS_SYSROOT}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch armv7 -isysroot ${IPHONEOS_SYSROOT}" LDFLAGS="-arch armv7 -miphoneos-version-min=${IOS_MIN_SDK} ${LDFLAGS}" "LIBS=${LIBS}"
    make ${EXTRA_MAKE_FLAGS}
    make ${EXTRA_MAKE_FLAGS} install 
         
        cd ${PREFIX}/platform
        rm -rf armv7
        mkdir armv7
        cp ${PREFIX}/lib/*.a ${PREFIX}/platform/armv7
         
)
ARMV7_IPHONE_OUTPUT=`find ${PREFIX}/platform/armv7/libgeos.a`
 
 
 
else
 
ARMV7_IPHONE_OUTPUT=
 
fi
 
if [ $BUILD_ARMV7S_IPHONE -eq 1 ]
then
 
echo "###################"
echo " armv7s for iPhone"
echo "###################"
 
 
(
        cd ${PWD}
         
    make ${EXTRA_MAKE_FLAGS}  distclean
    ./configure --build=x86_64-apple-darwin15.5.0 --host=armv7s-apple-darwin15.5.0 --enable-static --disable-shared --prefix=${PREFIX} "CC=${CC}" "CFLAGS=${CFLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -arch armv7s -isysroot ${IPHONEOS_SYSROOT}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch armv7s -isysroot ${IPHONEOS_SYSROOT}" LDFLAGS="-arch armv7s -miphoneos-version-min=${IOS_MIN_SDK} ${LDFLAGS}" "LIBS=${LIBS}"
    make ${EXTRA_MAKE_FLAGS}
    make ${EXTRA_MAKE_FLAGS} install 
         
        cd ${PREFIX}/platform
        rm -rf armv7s
        mkdir armv7s
        cp ${PREFIX}/lib/*.a ${PREFIX}/platform/armv7s
 
)
ARMV7S_IPHONE_OUTPUT=`find ${PREFIX}/platform/armv7s/libgeos.a`
 
 
else
 
ARMV7S_IPHONE_OUTPUT=
 
fi
 


if [ $BUILD_ARM64_IPHONE -eq 1 ]
then

echo "###########################"
echo " arm64 for iPhone OS"
echo "###########################"

(
        cd ${PWD}
	
    make ${EXTRA_MAKE_FLAGS} distclean
    ./configure --build=x86_64-apple-darwin15.5.0 --host=arm-apple-darwin --enable-static --disable-shared --prefix=${PREFIX} "CC=${CC}" "CFLAGS=${CFLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -arch arm64 -isysroot ${IPHONEOS_SYSROOT}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch arm64 -isysroot ${IPHONEOS_SYSROOT}" LDFLAGS="-arch arm64 -miphoneos-version-min=${IOS_MIN_SDK} ${LDFLAGS}" "LIBS=${LIBS}"
 	make ${EXTRA_MAKE_FLAGS}
    make ${EXTRA_MAKE_FLAGS} install
        
        
        cd ${PREFIX}/platform
        rm -rf arm64
        mkdir arm64
        cp ${PREFIX}/lib/*.a ${PREFIX}/platform/arm64
)

IOS_ARM64_OUTPUT=`find ${PREFIX}/platform/arm64/libgeos.a`

else

IOS_ARM64_OUTPUT=

fi

 
if [ $BUILD_I386_IOS_SIM -eq 1 ]
then
 
echo "###########################"
echo " i386 for iPhone Simulator"
echo "###########################"
 
(
        cd ${PWD}
        make ${EXTRA_MAKE_FLAGS} distclean
    ./configure --build=x86_64-apple-darwin15.5.0 --host=i386-apple-darwin15.5.0 --enable-static --disable-shared --prefix=${PREFIX} "CC=${CC}" "CFLAGS=${CFLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -arch i386 -isysroot ${IPHONESIMULATOR_SYSROOT}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch i386 -isysroot ${IPHONESIMULATOR_SYSROOT}" LDFLAGS="-arch i386 -miphoneos-version-min=${IOS_MIN_SDK} ${LDFLAGS}" "LIBS=${LIBS}"
    make ${EXTRA_MAKE_FLAGS}
    make ${EXTRA_MAKE_FLAGS} install
         
         
        cd ${PREFIX}/platform
        rm -rf sim
        mkdir sim
        cp ${PREFIX}/lib/*.a ${PREFIX}/platform/sim
)
 
IOS_SIM_OUTPUT=`find ${PREFIX}/platform/sim/libgeos.a`
 
else
 
IOS_SIM_OUTPUT=
 
fi
 
 
 if [ $BUILD_x86_64_SIM -eq 1 ]
 then
 
 echo "###########################"
 echo " x86_64 for iPhone Simulator"
 echo "###########################"
 
 (
         cd ${PWD}
         make ${EXTRA_MAKE_FLAGS} distclean
     ./configure --build=x86_64-apple-darwin15.5.0 --host=x86_64-apple-darwin15.5.0 --enable-static --disable-shared --prefix=${PREFIX} "CC=${CC}" "CFLAGS=${CFLAGS} -miphoneos-version-min=${IOS_MIN_SDK} -arch x86_64 -isysroot ${IPHONESIMULATOR_SYSROOT}" "CXX=${CXX}" "CXXFLAGS=${CXXFLAGS} -arch x86_64 -isysroot ${IPHONESIMULATOR_SYSROOT}" LDFLAGS="-arch x86_64 -miphoneos-version-min=${IOS_MIN_SDK} ${LDFLAGS}" "LIBS=${LIBS}"
     make ${EXTRA_MAKE_FLAGS}
     make ${EXTRA_MAKE_FLAGS} install
         
         
         cd ${PREFIX}/platform
         rm -rf sim64
         mkdir sim64
         cp ${PREFIX}/lib/*.a ${PREFIX}/platform/sim64
 )
 
 IOS_SIM64_OUTPUT=`find ${PREFIX}/platform/sim64/libgeos.a`
 
 else
 
 IOS_SIM64_OUTPUT=
 
 fi

 
 
echo "############################"
echo " Create Mixd Libraries"
echo "############################"
 
(
 
        cd ${PREFIX}/platform
        rm -rf mixd
        mkdir -p mixd
 
    lipo ${IOS_SIM_OUTPUT} ${IOS_SIM64_OUTPUT} ${ARMV7_IPHONE_OUTPUT} ${ARMV7S_IPHONE_OUTPUT} ${IOS_ARM64_OUTPUT} -create -output ${PREFIX}/platform/mixd/lib${BUILD_TARGET}.a
         
)
 
 
) 2>&1
#) >build.log 2>&1
 
echo "done"