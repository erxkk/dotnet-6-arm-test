#!/bin/bash

[[ ! -d docker-test ]] && git clone git@github.com:erxkk/dotnet-6-arm-test.git docker-test
cd docker-test
git clean -d -f
git pull

mkdir ./out
touch ./out/self.log
./start.sh |& tee ./out/self.log

