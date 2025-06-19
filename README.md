# Cross compilation environment for libcamera for the RPi Bookworm OS

A meson cross file will be automatically generated inside the debian bookworm Docker environment. Produces debian packages to install onto RPi.

## Setting up your working directory
1. Make the directory <br>
`mkdir libcamera-raspi; cd libcamera-raspi`

2. Download repositories <br>
`git clone https://github.com/NSLeung/libcamera-cross-compile.git/`

3. Clone the sources (downstream libcamera and rpicam-apps) <br>
`git clone https://github.com/raspberrypi/libcamera.git libcamera-raspi-downstream` <br>
`git clone https://github.com/raspberrypi/rpicam-apps.git`

## Building and installing

1. Build cross compile docker image <br>
`sudo docker build -t debian-bookworm-cross-compiler .`

2. Run a shell in the new docker image in your working directory (containing libcamera and your mountpoint) <br>
`sudo docker run -v "$PWD":"$PWD" -w "$PWD" --rm -it debian-bookworm-cross-compiler`

3. Enter sources directory <br>
`cd libcamera-raspi-downstream`

4. Configure meson to perform the cross build <br>
`meson setup build/rpi/bullseye --cross-file /usr/share/meson/arm64-cross`

5. (Cross-compile) Build libcamera at host compile speeds <br>
`ninja -C ./build/rpi/bullseye/`

6. Install to container <br>
`sudo ninja -C ./build/rpi/bullseye install`

7. Build deb package for libcamera <br>
```bash
sudo DESTDIR=$(readlink -f ../libcamera-raspi-debian) ninja -C ./build/rpi/bullseye install

cd ../

sudo dpkg -b libcamera-raspi-debian
```

8. Build deb package for rpicam-apps
```bash
sudo DESTDIR=$(readlink -f ../rpicam-debian) ninja -C ./build/rpi/bullseye install

cd ../

sudo dpkg -b rpicam-debian
```

9. SSH to RPi and  Install built deb files
```bash
sudo dpkg -i ./libcamera-raspi-debian.deb
sudo dpkg -i ./rpicam-debian.deb
```

10. Update linker path <br>
Installing the debian packages dumps the files into `/usr/local/lib` since it is a user-maintained package.

`export LD_LIBRARY_PATH=/usr/local/lib`

Add to $HOME/.bashrc to persist path.

## Additional Useful Commands
### Copying deb file from container to host
`docker cp [docker_container_id]:/[path_to_deb] [dest]`
