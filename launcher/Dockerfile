FROM registry.fedoraproject.org/fedora-toolbox:38
RUN dnf update -y && \
    dnf install -y \
        git \
        wine \
        wine-mono \
        python3 \
        msitools \
        python3-simplejson \
        python3-six \
        cmake \
        ninja-build \
        make \
        samba \
        libunwind && \
    dnf clean all && \
    mkdir /opt/msvc/ /build

RUN git config --global --add safe.directory /build
RUN git clone https://github.com/mstorsjo/msvc-wine && \
    ./msvc-wine/vsdownload.py --accept-license --dest /opt/msvc/ && \
    ./msvc-wine/install.sh /opt/msvc/ && \
    rm -rf ~/.wine ./msvc-wine/ && \
    git config --global --add safe.directory '/build'
ENV PATH="/opt/msvc/bin/x64:${PATH}"
WORKDIR /build/
