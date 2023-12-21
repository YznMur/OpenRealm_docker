FROM nvcr.io/nvidia/cuda:10.0-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive

# Basic deps
RUN apt-get update && apt-get install -y\
    build-essential \
    pkg-config \
    git \
    wget \
    curl \
    unzip \
    sudo \
    libgeographic-dev \
    libgoogle-glog-dev \
    apt-utils

RUN apt-get update \
  && apt-get -y install build-essential \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-Linux-x86_64.sh \
      -q -O /tmp/cmake-install.sh \
      && chmod u+x /tmp/cmake-install.sh \
      && mkdir /opt/cmake-3.24.1 \
      && /tmp/cmake-install.sh --skip-license --prefix=/opt/cmake-3.24.1 \
      && rm /tmp/cmake-install.sh \
      && ln -s /opt/cmake-3.24.1/bin/* /usr/local/bin

RUN cd / && wget https://raw.githubusercontent.com/laxnpander/OpenREALM/dev/tools/install_opencv.sh

RUN cd / && sed -i 's/sudo //g' install_opencv.sh && bash install_opencv.sh && cd ~ && rm -rf *


#ros-melodic-desktop-full

RUN apt-get update && apt-get install -y lsb-release && apt-get clean all

RUN set -ex \
    && apt-get update \
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && apt-get update \
    && apt-get install -y -q ros-melodic-desktop-full \
    && apt search ros-melodic

RUN set -ex \
    && apt-get install -y -q ros-melodic-geographic-msgs ros-melodic-geodesy \
        ros-melodic-cv-bridge ros-melodic-rviz ros-melodic-pcl-ros

# Build catkin workspace
# RUN set -ex && . /opt/ros/melodic/setup.sh && catkin_make -DCMAKE_BUILD_TYPE=Release

# Install rosbrindge suite
RUN apt-get install -yq --no-install-recommends ros-melodic-rosbridge-suite
COPY ../OpenREALM-aerial-mapping ./OpenREALM
RUN cd OpenREALM/tools/ && \
    ./install_deps.sh && \
    ./install_opencv.sh
RUN cd ./Pangolin/build/ && \
    cmake .. && \
    make -j4 && \
    make install

RUN cd ./openvslam/build/ && \
    cmake \
        -DUSE_PANGOLIN_VIEWER=OFF \
        -DINSTALL_PANGOLIN_VIEWER=ON \
        -DUSE_SOCKET_PUBLISHER=OFF \
        -DUSE_STACK_TRACE_LOGGER=ON \
        -DBUILD_TESTS=ON \
        -DBUILD_EXAMPLES=ON \
        .. && \
    make -j4 && \
    make install

RUN cd ./OpenREALM/build/ && \
    cmake -DTESTS_ENABLED=ON .. && \
    make -j4 && \
    make install

RUN git config --global --add safe.directory ./openvslam/3rd/FBoW && \
    git config --global --add safe.directory ./openvslam

COPY ../catkin_ws ./catkin_ws
RUN source /opt/ros/melodic/setup.bash && cd catkin_ws \
    catkin_make -DCMAKE_BUILD_TYPE=Release && \
    source devel/setup.bash && \
    ldconfig -v | grep "g2o"

CMD ["/bin/bash"]
