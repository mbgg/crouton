#!/bin/sh -e
# Copyright (c) 2017 Matthias Brugger. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

USAGE="${0##*/} -a|-r /path/to/chroot

Detects the release (-r) or arch (-a) of the chroot and prints it on stdout.
Fails with an error code of 1 if the chroot does not belong to this distro."

if [ "$#" != 2 ] || [ "$1" != '-a' -a "$1" != '-r' ]; then
    echo "$USAGE" 1>&2
    exit 2
fi

sources="${2%/}/usr/lib/os-release"
if [ ! -s "$sources" ]; then
    exit 1
fi

# Create release name from /etc/os-release file
# sed specialist can make that more elegant...
rel="`grep CPE_NAME "$sources" | cut -d ":" -f 4`"
if [ $rel = "opensuse" ]
then
    rel=tumbleweed
elif [ $rel = "leap" ]
then
    ver=`grep CPE_NAME "$sources" | cut -d ":" -f 5 | sed 's/"$//'`
    rel=${rel}-${ver}
elif [ $rel = "tumbleweed" ]
then
    continue
else
    exit 1
fi

# Print the architecture if requested
# Why use sed if you know cut...
sources="${2%/}/etc/products.d/openSUSE.prod"
if [ "$1" = '-a' ]; then
    grep "<arch>" "$sources"| cut -d '>' -f 2 | cut -d '<' -f 1
else
    echo "$rel"
fi

exit 0
