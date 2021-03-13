# Usage:
#
# mkdir -p dist && chmod o+rw dist; dk build . | tail -n 1 | awk '{ print $3; }' | xargs sudo docker run --rm -v `pwd`/dist:/skarnet-builder/dist

FROM ubuntu

ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install git curl build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY skarnet-builder /skarnet-builder

RUN chown -R nobody:nogroup /skarnet-builder

USER nobody
ENV HOME /skarnet-builder
WORKDIR /skarnet-builder

CMD ["/skarnet-builder/build-wrapper"]
