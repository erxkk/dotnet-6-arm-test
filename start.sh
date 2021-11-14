#!/bin/bash

for i in {5,6}; do
    echo "=> $i.0 pass"
    for t in {build,prebuilt}; do
        _ic="dotnet-$i-$t"
        _dir="./out/$_ic"
        
        echo " => preparing out dir"
        mkdir $_dir

        echo " => building $i.0-$t"
        docker build --tag $_ic $_ic &>> $_dir/build.log

        echo " => inspecting $i.0-$t image"
        docker image inspect $_ic &>> $_dir/image.json

        echo " => running $i.0-$t"
        docker run --name $_ic $_ic &>> $_dir/run.log

        echo " => inspecting $i.0-$t container"
        docker inspect $_ic &>> $_dir/container.json

        echo " => cleaning $i.0-$t"
        docker rm $_ic &>> $_dir/build-clean.log
        docker image rm $_ic &>> $_dir/image-clean.log
    done

    echo "=> inspecting mcr $i images"
    mkdir ./out/mcr-$i-{runtime,sdk}
    docker inspect mcr.microsoft.com/dotnet/sdk:$i.0 &>> ./out/mcr-$i-sdk/image.json
    docker inspect mcr.microsoft.com/dotnet/runtime:$i.0 &>> ./out/mcr-$i-runtime/image.json
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
