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

# RUN wget https://raw.githubusercontent.com/laxnpander/OpenREALM/dev/tools/install_deps.sh

# RUN cd / && sed -i 's/sudo //g' install_deps.sh && apt-get update && export DEBIAN_FRONTEND=noninteractive && \
# 	bash install_deps.sh && rm -rf /var/lib/apt/lists/*

# Finally install OpenREALM Librararies
# RUN set -ex \
#     && cd ~ && mkdir OpenREALM && cd OpenREALM \
#     && git clone https://github.com/laxnpander/OpenREALM.git \
#     && cd OpenREALM && OPEN_REALM_DIR=$(pwd) \
#     && git submodule init && git submodule update 
    # && cd $OPEN_REALM_DIR && mkdir build && cd build && cmake -DTESTS_ENABLED=ON -DWITH_PCL=ON .. \
    # && make -j $(nproc --all) && make install


# Create catkin workspace and clone the repo
# RUN set -ex \
#     && cd / && mkdir -p catkin_ws/src \
#     && cd catkin_ws/src \
#     && git clone https://github.com/laxnpander/OpenREALM_ROS1_Bridge.git

# Set workdir
# WORKDIR /catkin_ws

# Clone rviz_satellite for rviz plugins
# RUN set -ex && cd ./src && git clone https://github.com/gareth-cross/rviz_satellite.git


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

# Setup .bashrc and /ros_entrypoint.sh
# RUN set -ex \
#     && echo "source /opt/ros/melodic/setup.bash" >> /root/.bashrc \
#     && echo "source /catkin_ws/devel/setup.bash" >> /root/.bashrc \
#     && echo 'export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH' >> /root/.bashrc 


    # && sed --in-place --expression \
    # '$isource "/catkin_ws/devel/setup.bash"' \
    # /ros_entrypoint.sh

CMD ["/bin/bash"]
