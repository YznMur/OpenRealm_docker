#! /bin/bash
# enable access to xhost from the container


cd "$(dirname "$0")"
cd ..

workspace_dir=$PWD
 
if ["$(docker ps -aq -f status=exited -f name=realmapping)" ]; then
    docker rm realmapping
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
    --name realmapping \
    -v /media/yazan/Samsung_SSD/mapping_workspace/:/home/trainer/ \
    -e DISPLAY=:0 \
    realmapping:latest 

docker exec -it realmapping \
    /bin/bash -c "
    cd /home/trainer/OpenREALM/tools/
        ./install_deps.sh
        ./install_opencv.sh
    cd /home/trainer/openvslam/build/
    cmake \
        -DUSE_PANGOLIN_VIEWER=OFF \
        -DINSTALL_PANGOLIN_VIEWER=ON \
        -DUSE_SOCKET_PUBLISHER=OFF \
        -DUSE_STACK_TRACE_LOGGER=ON \
        -DBUILD_TESTS=ON \
        -DBUILD_EXAMPLES=ON \
        ..
    make -j4
    sudo make install

    cd /home/trainer/OpenREALM/build/
    cmake -DTESTS_ENABLED=ON .. && make -j4
    sudo make install

    git config --global --add safe.directory /home/trainer/openvslam/3rd/FBoW
    git config --global --add safe.directory /home/trainer/openvslam

    cd /home/trainer/catkin_ws
    source /opt/ros/melodic/setup.bash
    catkin_make -DCMAKE_BUILD_TYPE=Release
    source devel/setup.bash
    ldconfig -v | grep "g2o"
    "

    