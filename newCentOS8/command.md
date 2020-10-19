sed -e 's!^mirrorlist=!#mirrorlist=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//mirror.centos.org!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!http://mirrors\.tuna!https://mirrors.tuna!g' \
    -i /etc/yum.repos.d/CentOS-AppStream.repo /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-centosplus.repo /etc/yum.repos.d/CentOS-CR.repo \
    /etc/yum.repos.d/CentOS-Debuginfo.repo /etc/yum.repos.d/CentOS-Extras.repo /etc/yum.repos.d/CentOS-fasttrack.repo /etc/yum.repos.d/CentOS-HA.repo \
    /etc/yum.repos.d/CentOS-Media.repo /etc/yum.repos.d/CentOS-PowerTools.repo /etc/yum.repos.d/CentOS-Sources.repo /etc/yum.repos.d/CentOS-Vault.repo

dnf install epel-release -y

sed -e 's!^metalink=!#metalink=!g' \
    -e 's!^#baseurl=!baseurl=!g' \
    -e 's!//download\.fedoraproject\.org/pub!//mirrors.tuna.tsinghua.edu.cn!g' \
    -e 's!http://mirrors\.tuna!https://mirrors.tuna!g' \
    -i /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo \
    /etc/yum.repos.d/epel-modular.repo /etc/yum.repos.d/epel-playground.repo /etc/yum.repos.d/epel-testing-modular.repo

dnf install -y chrony vim git wget curl tar bash-completion*

systemctl start chronyd && systemctl enable chronyd

wget -c https://studygolang.com/dl/golang/go1.14.2.linux-amd64.tar.gz

wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo
sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo
wget -c https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
dnf install -y ./containerd.io-1.2.6-3.3.el7.x86_64.rpm
dnf install -y docker-ce
systemctl start docker && systemctl enable docker

cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=kubernetes
baseurl=https://mirrors.tuna.tsinghua.edu.cn/kubernetes/yum/repos/kubernetes-el7-\$basearch
gpgcheck=0
enabled=1
EOF
dnf install -y kubelet kubectl kubeadm
systemctl start kubelet && systemctl enable kubelet
firewall-cmd --add-port=6443/tcp --permanent
firewall-cmd --add-port=10250/tcp --permanent
kubeadm init --image-repository registry.cn-hangzhou.aliyuncs.com/google_containers
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
