# README

The projects demonstrates a possible bug in mod_fcgid, where it ignores FcgidMinProcessesPerClass (and the deprecated DefaultMinClassProcessCount).

    docker build .
    # note image id generated

    docker run --rm THAT_IMAGE_ID
    # note container id that is started

    # in another shell
    docker exec -it THAT_CONTAINER_ID bash

    # in the container
    curl localhost/workers
    ps aux | grep dispatch

    # The number of workers should be at least 5, per fcgid.conf, which sets FcgidMinProcessesPerClass 5, but it is 1 or 2
