#!/bin/bash

mkdir -p animation/
mv *.png animation/
pushd animation/
convert -delay 0.04 -loop 0 *.png animation.gif
rm *.png
