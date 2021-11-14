#!/bin/bash

for i in {5,6}; do
    echo "=> $i.0 pass"
    for t in {build,prebuilt}; do
        mkdir ./out/dotnet-$i-$t
        echo " => building $i.0-$t"
        docker build --tag dotnet-$i-$t ./dotnet-$i-$t &>> ./out/dotnet-$i-$t/build.log

        echo " => inspecting $i.0-$t image"
        docker image inspect dotnet-$i-$t &>> ./out/dotnet-$i-$t/image.json

        echo " => running $i.0-$t"
        docker run --name dotnet-$i-$t dotnet-$i-$t &>> ./out/dotnet-$i-$t/run.log

        echo " => inspecting $i.0-$t container"
        docker inspect dotnet-$i-$t &>> ./out/dotnet-$i-$t/container.json

        echo " => cleaning $i.0-$t"
        docker rm dotnet-$i-$t &>> ./out/dotnet-$i-$t/build-clean.log
        docker image rm dotnet-$i-$t &>> /.out/dotnet-$-$t/image-clean.log
    done

    echo "=> inspecting mcr $i images"
    mkdir ./out/mcdr-$i-{runtime,sdk}
    docker inspect mcr.microsoft.com/dotnet/sdk:$i.0 &>> ./out/mcr-$i-sdk/image.json
    docker inspect mcr.microsoft.com/dotnet/runtime:$i.0 &>> /.out/mcr-$i-runtime/image.json
done

echo "removing residual build containers"
_DOCKER_IMG=$(docker image ls | awk '/^<none>/{ print $3 }')

if [[ -n $_DOCKER_IMG ]]; then
    for img in $_DOCKER_IMG; do
        _DOCKER_CON=$(docker ps -a | awk "/$img/{ print \$1 }")
        [[ -n $_DOCKER_CON ]] && docker rm $_DOCKER_CON    
        docker image rm $img
    done
fi
