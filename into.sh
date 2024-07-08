#!/bin/bash
docker exec -it realmapping  \
    /bin/bash -c "
    cd /home/trainer;
    nvidia-smi;
    /bin/bash"