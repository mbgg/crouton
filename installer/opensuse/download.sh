#!/bin/sh -e
# Copyright (c) 2016 The crouton Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.


URL=$1
TARGET=$2

mkdir -p "$TARGET"
( cd $TARGET; wget -O - $URL | bzip2 -d | tar x )

echo "done"
