# README

The projects demonstrates a possible bug in mod_fcgid, where it ignores FcgidMinProcessesPerClass. See [the full fcgid.conf](fcgid.conf).

    docker build -t repro-mod-fcgid-bug .

    docker run --name fcgid-bug --rm repro-mod-fcgid-bug

    # in another shell
    docker exec -it fcgid-bug bash

    # in the resulting container shell
    curl localhost/workers
    ps aux | grep dispatch

    # The number of workers should be at least 5, per fcgid.conf, which sets FcgidMinProcessesPerClass 5, but it is 1 or 2

    # it *can* run more than 1 worker. just siege it with 10 concurrent connections...
    siege -c 10 localhost/workers

    # repeat above steps to check number of workers. it'll be more...
    # does FcgidMinProcessesPerClass not work?

## Environment details

    alias runftw='docker exec -it fcgid-bug'

    $ runftw apachectl -v                                                                                                                                                        [2.2.0]
    Server version: Apache/2.4.7 (Ubuntu)
    Server built:   Oct 14 2015 14:20:21

    $ runftw apt-cache show libapache2-mod-fcgid | grep Version                                                                                                                  [2.2.0]
    Version: 1:2.3.9-1

    $ runftw lsb_release -d                                                                                                                                                      [2.2.0]
    Description:Ubuntu 14.04.3 LTS
