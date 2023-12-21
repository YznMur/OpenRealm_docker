#! /bin/bash
# enable access to xhost from the container


cd "$(dirname "$0")"
cd ..

workspace_dir=$PWD
 
if ["$(docker ps -aq -f status=exited -f name=realmap)" ]; then
    docker rm realmap
fi

xhost +
docker run -it -d --rm --privileged \
    --gpus '"device=0"' \
    --net host \
    -e "NVIDIA_DRIVER_CAPABILITIES=all" \
    -e "DISPLAY" \
    -e "QT_X11_NO_MITSHM=1" \
    --shm-size="45g" \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    --name realmap \
    -v /media/yazan/Samsung_SSD/mapping_workspace/:/home/trainer/ \
    -e DISPLAY=:0 \
    realmap:latest 