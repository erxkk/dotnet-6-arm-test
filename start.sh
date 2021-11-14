#!/bin/bash

[[ ! -d 'out' ]] && mkdir out

for i in {5,6}; do
    for t in {build,prebuilt}; do
        echo "=> building $i-$t"
        docker build --tag dotnet-$i-$t ./dotnet-$i-$t &>> out/dotnet-$i-$t.build.log

        echo "=> inspecting $i-$t image"
        docker image inspect dotnet-$i-$t &>> out/dotnet-$i-$t.image.json

        echo "=> running $i-$t"
        docker run --name dotnet-$i-$t dotnet-$i-$t &>> out/dotnet-$i-$t.run.log

        echo "=> inspecting $i-$t container"
        docker inspect dotnet-$i-$t &>> out/dotnet-$i-$t.image.json

        echo "=> cleaning $i-$t"
        docker rm dotnet-$i-$t &>> /dev/null
        docker image rm dotnet-$i-$t &>> /dev/null
    done

    echo "inspecting mcr $i images"
    docker inspect mcr.microsoft.com/dotnet/sdk:$i.0 &>> out/mcr-$i-runtime.image.json
    docker inspect mcr.microsoft.com/dotnet/runtime:$i.0 &>> out/mcr-$i-runtime.image.json
done

echo "remvoing residual build container"
_DOCKER_RES=$(docker image ls | awk '/^<none>/{ print $3 }')
[[ -n $DOCKER_RES ]] && echo $_DOCKER_RES | xargs docker image rm

