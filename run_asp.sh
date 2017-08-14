#!/usr/bin/env bash

set -x

if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform
    bin/clingcon-mac asp/vega-lite.lp asp/task.lp;
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under GNU/Linux platform
    bin/clingcon-linux asp/vega-lite.lp asp/task.lp;
fi
