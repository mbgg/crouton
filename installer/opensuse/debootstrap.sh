#!/bin/sh -e
# Copyright (c) 2017 The crouton Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# openSUSE does not have debootstrap, so this is a pseudo implementation of the tool
# just enough to download a minimal image.

set -e

ARCH=$(uname -m)

while [ $# -gt 0 ]
do
    case $1 in
    --arch=?*)
        ARCH="${1#*=}"
        ;;
    (--) shift; break;;
    (*) break;;
    esac
    shift
done

RELEASE="$1"
TARGET="$2"

if [ ! "$RELEASE" -o ! "$TARGET" ]; then
    exit 1
fi

# Tumbleweed
url_tumbleweed_armv7hl="http://download.opensuse.org/ports/armv7hl/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS.armv7hl-rootfs.armv7l-Current.tbz"
url_tumbleweed_aarch64="http://download.opensuse.org/ports/aarch64/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS.aarch64-rootfs.aarch64-Current.tbz"

# Leap
url_leap_42_2_armv7hl="http://download.opensuse.org/ports/armv7hl/distribution/leap/42.2/appliances/openSUSE-Leap42.2-ARM-X11.armv7-rootfs.armv7l-2017.02.02-Build1.1.tbz"
url_leap_42_2_aarch64="http://download.opensuse.org/ports/aarch64/distribution/leap/42.2/appliances/openSUSE-Leap42.2-ARM-JeOS.aarch64-rootfs.aarch64-2017.02.02-Build1.1.tbz"

# Rename factory to tumbleweed
[ "$RELEASE" = "factory" ] && RELEASE=tumbleweed
# Fix leap release name
[ "$RELEASE" = "leap-42.2" ] && RELEASE=leap_42_2
# fix up the good old toolchain/kernel naming conflict
[ "$ARCH" = "arm64" ] && ARCH=aarch64

key=$(echo "\$url_${RELEASE}_${ARCH}")
URL=$(echo $(eval echo "${key}"))

if [ ! "$URL" ]; then
    echo "Unknown Distribution / Architecture: $key"
    exit 1
fi

if [ -e "$(which wget)" ]; then
    WGET="wget -O -"
elif [ -e "$(which curl)" ]; then
    WGET="curl"
else
    echo "No HTTP download tool found."
    exit 1
fi

if [ -e "$(which pbzip2 2>/dev/null)" ]; then
    BZIP2="pbzip2"
elif [ -e "$(which bzip2 2>/dev/null)" ]; then
    BZIP2="bzip2"
else
    echo "No decompression tool found."
    exit 1
fi

mkdir -p "$TARGET"
( cd "$TARGET"; $WGET $URL | $BZIP2 -d | tar x )

echo "done"
