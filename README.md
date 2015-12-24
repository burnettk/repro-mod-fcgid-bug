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

    # it *can* run more than 1 worker. just siege it with 10 concurrent connections...
    siege -c 10 localhost/workers

    # repeat above steps to check number of workers. it'll be more...
    # does FcgidMinProcessesPerClass not work?
