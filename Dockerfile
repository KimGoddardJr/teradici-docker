FROM ubuntu:18.04

# Use the following two lines to install the Teradici repository package
RUN apt-get update && apt-get install -y wget && apt-get install -y curl

# This was the bit that is wrong in the example dockerfile
RUN curl -1sLf https://dl.teradici.com/DeAdBCiUYInHcSTy/pcoip-client/cfg/setup/bash.deb.sh | sh=ubuntu codename=bionic bash

# Install apt-transport-https to support the client installation
RUN apt-get update && apt-get install -y apt-transport-https

# Install the client application
RUN apt-get install -y pcoip-client

# Setup a functional user within the docker container with the same permissions as your local user.
# Replace 1000 with your user / group id
# Replace myuser with your local username
RUN export uid=1000 gid=1000 && \
    mkdir -p /etc/sudoers.d/ && \
    mkdir -p /home/kg && \
    echo "kg:x:${uid}:${gid}:kg,,,:/home/kg:/bin/bash" >> /etc/passwd && \
    echo "kg:x:${uid}:" >> /etc/group && \
    echo "kg ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/kg && \
    chmod 0440 /etc/sudoers.d/kg && \
    chown ${uid}:${gid} -R /home/kg

# Set some environment variables for the current user
USER kg
ENV HOME /home/kg
ENV QT_QUICK_BACKEND=software


# Set the path for QT to find the keyboard context
ENV QT_XKB_CONFIG_ROOT /user/share/X11/xkb

ENTRYPOINT exec pcoip-client

#Command to run the docker container. Again don't forget to change kg to your username.

#$ docker run -d --rm -h myhost -v $(pwd)/.config/:/home/kg/.config/Teradici -v $(pwd)/.logs:/tmp/Teradici/$USER/PCoIPClient/logs -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY pcoip-client