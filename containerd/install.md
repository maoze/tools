git clone https://gitee.com/maozed/containerd.git

cd containerd/

git remote rename origin old-origin

git remote add origin https://gitlab.ctyun.cn/maoze/containerd.git

git checkout release/1.0
git checkout release/1.1
git checkout release/1.2
git checkout release/1.3
git checkout release/1.4
git checkout release/1.5
git checkout release/1.6
git checkout v0.2.x

git push -u origin --all

git push -u origin --tags

// compile binaries
make

// install-cri-deps
#dnf install -y libseccomp-devel
dnf install -y tar
make install-deps
make install-cri-deps






mv ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust
