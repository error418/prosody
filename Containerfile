ARG PROSODY_VERSION=0.12.4
ARG LUA_VERSION=5.4
ARG BASE_IMAGE=debian:bookworm-slim
ARG USERID=5222
ARG GROUPID=${USERID}

###############################################################################
# Base image

FROM ${BASE_IMAGE} as base
ARG LUA_VERSION

RUN apt-get update

# prosody lua dependencies
RUN apt-get install -y lua-unbound lua${LUA_VERSION} lua-event lua-readline lua-sql-sqlite3 lua-dbi-sqlite3 lua-socket lua-sec lua-expat lua-filesystem luarocks \
 && apt-get install -y liblua${LUA_VERSION}-dev libidn11-dev libssl-dev libicu-dev \
 && rm -rf /var/lib/apt/lists/*



###############################################################################
# Build image

FROM base as builder
ARG PROSODY_VERSION
ARG LUA_VERSION

# add tooling required for build
RUN apt-get update \
 && apt-get install -y mercurial build-essential bsdmainutils \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /build

RUN hg clone https://hg.prosody.im/trunk -r ${PROSODY_VERSION} /build/prosody-hg
 
WORKDIR /build/prosody-hg

RUN ./configure \
      --idn-library=icu \
      --prefix=/opt/prosody \
      --libdir=/opt/prosody/lib \
      --sysconfdir=/etc/prosody \
      --datadir=/var/lib/prosody \
      --lua-version=${LUA_VERSION} \
      --no-example-certs

RUN make
RUN make install

# preserve symbolic links
RUN tar -cf /build/install.tar /opt/ /etc/prosody/ /var/lib/prosody



###############################################################################
# Application image

FROM base

ARG USERID
ARG GROUPID

ENV PATH=/opt/prosody/bin:$PATH

COPY rootfs/ /
COPY --from=builder /build/install.tar /build/

RUN tar -xf /build/install.tar -C / \
 && rm -rf /build \
 && groupadd -g ${GROUPID} prosody \
 && useradd -u ${USERID} -d /opt/prosody --system -g ${GROUPID} prosody \
 && mkdir -p /usr/lib/prosody/enabled-modules/ \
 && mkdir -p /var/lib/prosody/custom_plugins \
 && chown -R prosody:prosody \
          /var/lib/prosody \
          /usr/lib/prosody/enabled-modules/ \
          /var/lib/prosody/custom_plugins

VOLUME [ "/var/lib/prosody" ]

USER prosody

WORKDIR /opt/prosody

EXPOSE 5000 5222 5269 5281

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "prosody", "-F" ]
