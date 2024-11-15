FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ARG WS_VERSION=3.4.0

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential ca-certificates ninja-build tzdata wget xz-utils \
  python3 python3-dev python3-pip python3-serial python3-crcmod

WORKDIR /mi

RUN \
  wget -qO- https://www.wireshark.org/download/src/all-versions/wireshark-${WS_VERSION}.tar.xz \
  | tar xJ

RUN \
  sed 's/apt-get install/apt-get install -y/' wireshark-${WS_VERSION}/tools/debian-setup.sh \
  | bash && rm -rf /var/lib/apt/lists/*

RUN \
  mkdir wireshark-${WS_VERSION}/build && cd wireshark-${WS_VERSION}/build && \
  cmake -G Ninja .. && ninja && ninja install && \
  rm /etc/ld.so.cache && ldconfig

COPY . .

RUN cd ws_dissector && \
  WS_SRC_PATH=../wireshark-${WS_VERSION} WS_LIB_PATH=/usr/local/lib make && \
  cp ws_dissector /usr/local/bin/

RUN pip install .

WORKDIR /

RUN rm -rf /mi
