## -*- docker-image-name: "xingfuryda/osm-load:latest" -*-

##
# osm2pgsql
#
# This creates an image with osm2pgsql
#

FROM phusion/baseimage:0.9.18
MAINTAINER xingfuryda

# Ensure `add-apt-repository` is present
RUN apt-get update -y

# install compiler
RUN apt-get install -y gcc-4.8 g++-4.8
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 20
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 20
RUN update-alternatives --config gcc
RUN update-alternatives --config g++

# Install osm2pgsql dependencies
RUN apt-get install -y make cmake g++ libboost-dev libboost-system-dev libboost-filesystem-dev libexpat1-dev zlib1g-dev libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev lua5.2 liblua5.2-dev

# Install utilities I need
RUN apt-get install -y wget git

# Build osm2pgsql v 0.90.0 2 Mar 2016 2a14ddffb3b4762bb370fbf947868d94af23f808
RUN cd /tmp && git clone git://github.com/openstreetmap/osm2pgsql.git  
RUN cd /tmp/osm2pgsql && git checkout 2a14ddffb3b4762bb370fbf947868d94af23f808 && mkdir build && cd build && cmake ..
RUN cd /tmp/osm2pgsql/build && make && make install

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the osm2pgsql import cache size in MB. Used in `run import`.
ENV OSM_IMPORT_CACHE 800

# Add the entrypoint
ADD run.sh /usr/local/sbin/run
RUN chmod +x /usr/local/sbin/run
ENTRYPOINT ["/sbin/my_init", "--", "/usr/local/sbin/run"]