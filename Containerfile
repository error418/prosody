ARG PROSODY_VERSION=0.12.4
ARG LUA_VERSION=5.4
ARG BASE_IMAGE=debian:bookworm


FROM ${BASE_IMAGE} as base
ARG LUA_VERSION

RUN apt-get update

# prosody lua dependencies
RUN apt-get install -y lua-unbound lua${LUA_VERSION} lua-event lua-readline lua-sql-sqlite3 lua-dbi-sqlite3 lua-socket lua-sec lua-expat lua-filesystem luarocks
# prosody build dependencies
RUN apt-get install -y liblua${LUA_VERSION}-dev build-essential bsdmainutils libidn11-dev libssl-dev libicu-dev


FROM base as builder
ARG PROSODY_VERSION
ARG LUA_VERSION

RUN apt-get install -y mercurial

# build dependencies
RUN mkdir -p /build

RUN hg clone https://hg.prosody.im/trunk -r ${PROSODY_VERSION} /build/prosody-hg
 
WORKDIR /build/prosody-hg

RUN ./configure \
      --idn-library=icu \
      --prefix=/opt/prosody \
      --sysconfdir=/etc/prosody \
      --libdir=/opt/prosody-lib \
      --datadir=/var/lib/prosody \
      --lua-version=${LUA_VERSION}

RUN make
RUN make install

# preserve symbolic links
RUN tar -cf /build/install.tar /opt/ /etc/prosody/


FROM base

ENV PATH=/opt/prosody/bin:$PATH

COPY --from=builder /build/install.tar /build/
RUN tar -xf /build/install.tar -C / \
 && rm -rf /build

RUN useradd -d /opt/prosody --system --user-group prosody

RUN mkdir -p /var/lib/prosody \
 && chown -R prosody:prosody /var/lib/prosody

USER prosody

WORKDIR /opt/prosody

