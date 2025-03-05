# scudo
FROM quay.io/centos/centos:stream10 AS scudo

RUN dnf install -y gcc-c++ kernel-headers

RUN curl -sO "https://android.googlesource.com/platform/external/scudo/+archive/ad3335c7b5769bcee16be0d47c48089ada488857/standalone.tar.gz" && \
    mkdir scudo && \
    tar xf standalone.tar.gz -C scudo && \
    rm standalone.tar.gz

RUN cd scudo && \
    g++ -fPIC -Iinclude -c *.cpp && \
    g++ -shared -o libscudo.so *.o

# Netherite build
FROM ghcr.io/calciteauthors/calcite:c10s AS netherite

# scudo
COPY --from=scudo /scudo/libscudo.so /usr/lib64/libscudo.so
RUN echo /usr/lib64/libscudo.so >> /usr/etc/ld.so.preload
RUN echo /usr/lib64/libscudo.so >> /etc/ld.so.preload

# Trivalent
COPY config/secureblue.repo /usr/etc/yum.repos.d/secureblue.repo
COPY config/secureblue.repo /etc/yum.repos.d/secureblue.repo
RUN dnf install epel-release -y && \
    dnf config-manager --set-enabled crb && \
    dnf swap -y firefox trivalent

# chrony
COPY config/chrony.conf /usr/etc/chrony.conf
COPY config/chrony.conf /etc/chrony.conf

# NetworkManager privacy
COPY config/30-net-privacy.conf /usr/lib/NetworkManager/conf.d/30-net-privacy.conf

# Kernel tunables
COPY config/tunables.conf /usr/lib/sysctl.d/tunables.conf

# usbguard
RUN dnf install usbguard -y && systemctl disable usbguard

# countme
RUN sed -i -e s,countme=1,countme=0, /usr/etc/yum.repos.d/*.repo
RUN sed -i -e s,countme=1,countme=0, /etc/yum.repos.d/*.repo
RUN systemctl mask rpm-ostree-countme.timer
