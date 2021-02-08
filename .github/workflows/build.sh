#!/bin/bash

ls /Applications | grep Xcode
echo "Before"
xcode-select -p || true
sudo xcode-select -switch /Applications/Xcode_11.7.app || true
echo "Mid"
xcode-select -p || true
echo "mid_sdk"
xcrun -show-sdk-version
x=$(ls /Applications | grep Xcode[_0-9\.]*\.app | sort -V | tail -n 1)
echo "sed"
ls /Applications | grep Xcode[_0-9\.]*\.app | sort -V | tail -n 1 | sed s/Xcode_([0-9]+)\..*/\1/
echo "x"
echo $x
sudo xcode-select -switch /Applications/$x || true
echo "After"
xcode-select -p || true
echo "after_sdk"
xcrun -show-sdk-version