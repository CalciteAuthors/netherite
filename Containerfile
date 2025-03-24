# hardened_malloc
FROM quay.io/almalinuxorg/almalinux:10-kitten AS hardened_malloc

# Dependencies
RUN dnf install -y git gcc gcc-c++ make

# Download hardened_malloc
RUN git clone --depth=1 --single-branch --branch=main https://github.com/GrapheneOS/hardened_malloc.git

# Build hardened_malloc
RUN cd hardened_malloc && \
    make

# Netherite build
FROM ghcr.io/calciteauthors/calcite:a10s AS netherite

# hardened_malloc
COPY --from=hardened_malloc /hardened_malloc/out/libhardened_malloc.so /usr/lib64/libhardened_malloc.so
RUN echo /usr/lib64/libhardened_malloc.so >> /etc/ld.so.preload

# Disable coredump
COPY config/60-disable-coredump-limits-d.conf /etc/security/limits.d/60-disable-coredump.conf
COPY config/60-disable-coredump.conf /etc/systemd/system.conf.d/60-disable-coredump.conf
COPY config/60-disable-coredump.conf /etc/systemd/user.conf.d/60-disable-coredump.conf

# Kernel tunables
COPY config/tunables.conf /usr/lib/sysctl.d/tunables.conf

# Trivalent
COPY config/secureblue.repo /etc/yum.repos.d/secureblue.repo
RUN dnf install epel-release -y && \
    dnf config-manager --set-enabled crb && \
    dnf swap -y firefox trivalent

# chrony
COPY config/chrony.conf /etc/chrony.conf

# NetworkManager privacy
COPY config/30-net-privacy.conf /usr/lib/NetworkManager/conf.d/30-net-privacy.conf

# usbguard
RUN dnf install usbguard -y && systemctl disable usbguard

# countme
RUN sed -i -e s,countme=1,countme=0, /etc/yum.repos.d/*.repo
RUN systemctl mask rpm-ostree-countme.timer

# Remove sudo
RUN rpm --nodeps -e sudo sudo-python-plugin

# Good practice
RUN bootc container lint
