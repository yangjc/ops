#!/bin/bash

install_for_centos() {
    yum install -y wget curl openssl-devel curl-devel expat-devel perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker
    cd /tmp
    file="$(curl -s 'https://mirrors.edge.kernel.org/pub/software/scm/git/' \
        | awk -F '"' '$2~/^git-[0-9].*.tar.xz$/{x=$2}END{print x}')"
    ( set -x
    wget "https://mirrors.edge.kernel.org/pub/software/scm/git/$file"
    )
    tar xJf "$file"
    cd "${file:0:-7}"
    make prefix=/usr/local/lib/git all
    make prefix=/usr/local/lib/git install
    echo 'pathmunge /usr/local/lib/git/bin/' >> /etc/profile.d/custom.sh
    cd ..
    rm -rf "${file:0:-7}"
    rm -f "$file"
}

install_for_centos
