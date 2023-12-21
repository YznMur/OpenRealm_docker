#!/bin/bash
docker exec -it realmap  \
    /bin/bash -c "
    cd /home/trainer;
    nvidia-smi;
    /bin/bash"