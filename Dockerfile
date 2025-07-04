FROM debian:bookworm

ENV DEBIAN_FRONTEND noninteractive
ENV LANG='C.UTF-8' LC_ALL='C.UTF-8'

# Support multiarch builds to perform cross compilation
# https://wiki.debian.org/Multiarch/HOWTO
RUN dpkg --add-architecture arm64

# Expected system requirements
RUN apt-get update && apt-get install -y \
	sudo \
	git

# Base libcamera image, with non-toolchain dependencies for building.
# Base libcamera always-host packages (compilation dependencies)
RUN apt-get install -y \
	meson ninja-build pkg-config dpkg-dev \
	python3-yaml python3-ply python3-jinja2 \
	openssl \
	python3-sphinx doxygen ghostscript graphviz texlive-latex-extra \
	liblttng-ust-dev python3-jinja2 lttng-tools

# rpicam-apps depedencies
RUN apt-get install -y \
	libboost-all-dev \
	libpng-dev

# Base libcamera cross compiler and target architecture packages
RUN apt-get install -y \
	gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
	libgnutls28-dev:arm64 \
	libboost-dev:arm64 \
	libudev-dev:arm64 \
	libgstreamer1.0-dev:arm64 libgstreamer-plugins-base1.0-dev:arm64 \
	libevent-dev:arm64 \
	qtbase5-dev:arm64 libqt5core5a:arm64 libqt5gui5:arm64 libqt5widgets5:arm64 \
	qttools5-dev-tools:arm64 libtiff-dev:arm64 \
	libexif-dev:arm64 libjpeg-dev:arm64 libyaml-dev:arm64

# Generate the meson cross file using the debian package helper
RUN /usr/share/meson/debcrossgen --arch arm64 -o /usr/share/meson/arm64-cross

# Fix exec error when checking versions (because of aarch64 bin)
RUN mv /usr/lib/aarch64-linux-gnu/qt5/bin/lrelease /usr/lib/aarch64-linux-gnu/qt5/bin/lrelease.old

# Create a custom user to operate in the container
RUN adduser --disabled-password --gecos '' libcamera
RUN adduser libcamera sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /home/libcamera
USER libcamera
