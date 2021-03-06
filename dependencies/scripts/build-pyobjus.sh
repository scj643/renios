#!/bin/bash

. $(dirname $0)/utils.sh



if [ ! -d $TMPROOT/pyobjus ] ; then
    git clone https://github.com/kivy/pyobjus.git $TMPROOT/pyobjus
fi

try pushd $TMPROOT/pyobjus

# Set environment variables for Python module cross-compile
OLD_CC="$CC"
OLD_CFLAGS="$CFLAGS"
OLD_LDSHARED="$LDSHARED"
export CC="$ARM_CC"
export CFLAGS="$ARM_CFLAGS"
export CFLAGS="$CFLAGS -I$BUILDROOT/include -I$BUILDROOT/include/ffi"
export LDSHARED="$RENIOSDEPROOT/scripts/liblink"

HOSTPYTHON="$RENIOSDEPROOT/tmp/Python-$PYTHON_VERSION/hostpython"

export KIVYIOSROOT=1
export ARCH=$RENIOSARCH

echo 'Building pyobjus'
try $HOSTPYTHON -O setup.py \
    build_ext -g -b build/lib.$PYARCH -t build/tmp.$PYARCH \
    install -O2 --root $DESTROOT

try cp build/lib.$PYARCH/pyobjus/*.so "$DESTROOT/usr/local/lib/python2.7/site-packages/pyobjus"

unset KIYIOSROOT

echo "Linking and deduplicating pyobjus libraries"
rm -rf $BUILDROOT/lib/libpyobjus.a
try $RENIOSDEPROOT/scripts/biglink $BUILDROOT/lib/libpyobjus.a build/lib.$PYARCH/pyobjus

try deduplicate $BUILDROOT/lib/libpyobjus.a

rm -Rf "$BUILDROOT/python/lib/python2.7/site-packages/pyobjus"
try cp -R "$DESTROOT/usr/local/lib/python2.7/site-packages/pyobjus" "$BUILDROOT/python/lib/python2.7/site-packages"

export CC="$OLD_CC"
export CFLAGS="$OLD_CFLAGS"
export LDSHARED="$OLD_LDSHARED"

popd

