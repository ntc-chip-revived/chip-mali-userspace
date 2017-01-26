set -x

ls

sudo apt-get update && sudo apt-get install -y qemu-user-static

sudo rm -rf rootfs/

wget http://opensource.nextthing.co/chippian/rootfs/rootfs.tar.gz

sudo tar -xf rootfs.tar.gz
rm rootfs.tar.gz

sudo mkdir rootfs/home/build
sudo cp -r chip-mali-userspace rootfs/home/build/

sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin/
sudo cp /etc/resolv.conf rootfs/etc/

sudo touch rootfs/usr/sbin/policy-rc.d
sudo chmod a+w rootfs/usr/sbin/policy-rc.d
echo >rootfs/usr/sbin/policy-rc.d <<EOF
echo "************************************" >&2
echo "All rc.d operations denied by policy" >&2
echo "************************************" >&2
exit 101
EOF
sudo chmod 0755 rootfs/usr/sbin/policy-rc.d


sudo rm rootfs/dev/null

sudo mount -t proc      chproc  rootfs/proc
sudo mount -t sysfs     chsys   rootfs/sys
sudo chroot rootfs /bin/bash <<EOF

echo -e "\
deb http://ftp.us.debian.org/debian/ jessie main contrib non-free\n\
deb-src http://ftp.us.debian.org/debian/ jessie main contrib non-free\n\
\n\
deb http://security.debian.org/ jessie/updates main contrib non-free\n\
deb-src http://security.debian.org/ jessie/updates main contrib non-free\n\
\n\
" >/etc/apt/sources.list

apt-get update
apt-get install -y --force-yes build-essential fakeroot devscripts git pkg-config dpkg-dev dh-make
apt-get install -y --force-yes  libdrm2 libgbm1 libxfixes3 libxext6 libxdamage1 libx11-6 libgcc1 libstdc++6 libudev1 libwayland-client0 libwayland-server0
pushd /home/build/chip-mali-userspace
dpkg-buildpackage
popd

EOF

for a in $(mount |grep $PWD|awk '{print $3}'); do sudo umount -l $a; done

cp rootfs/home/build/*.deb .

ls
pwd

exit 0

