#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Should run by root."
    exit 1
fi

if [ ! -f "/etc/os-release" ]; then
    echo "\"/etc/os-release\" not found." >&2
    exit 1
fi

osId="$(awk -F '"' '$1~/^ID=$/{print $2}' /etc/os-release)"
osVId="$(awk -F '"' '$1~/^VERSION_ID=$/{print $2}' /etc/os-release)"

install_docker() {
    type docker 2>/dev/null
    if [ "$?" == "0" ]; then
        echo "Guide: https://docs.docker.com/install/linux/docker-ce/centos/"
        return
    fi

    downUrl="https://download.docker.com/linux/centos/7/x86_64/stable/Packages/"
    list="$(
        curl "$downUrl" | awk -F '</a>' \
'$1~/<a\s+href="(containerd\.io-|docker-ce-)/{'\
'split($1,x,"\"");f=x[2];split($1,x,/-[0-9]/);split(x[1],y,"\"");p=y[2];t=$2;gsub(/\s+/," ",t);'\
'a[p]=t;b[p]=f;'\
'if(t>a[p]){a[p]=t;b[p]=f}'\
'}END{for(i in a){printf "%s\t%s\t%s\n",i,a[i],b[i]}}'
    )"
    echo

    downDir="/tmp/docker-ce"
    mkdir -p "$downDir"
    cd "$downDir"
    rm -rf *.rpm

    count=0
    while read -r line
    do
        IFS=$'\t' read -ra items <<< "$line"
        name=${items[0]}
        info=${items[1]}
        file=${items[2]}

        if [ "$name" == "docker-ce-selinux" ]; then
            echo "Skip \"$name\", $info, ${downUrl}${file}"
            continue
        fi

        count="$(($count + 1))"
        echo "Downloading \"$name\", $info"
        ( set -x
        wget "${downUrl}${file}"
        )
    done <<< "$list"

    c="$(ls "$downDir" | wc -l)"
    if [ "$c" != "$count" ]; then
        echo "Expecting $count files, get $c files."
        return
    fi

    yum install *
}

install_docker_compose() {
    type docker-compose 2>/dev/null
    if [ "$?" == "0" ]; then
        echo "Guide: https://docs.docker.com/compose/install/"
        return
    fi

    downDir="/tmp/docker-ce"
    mkdir -p "$downDir"
    [ -f "$downDir/docker-compose" ] && rm -f "$downDir/docker-compose"

    latestVersion="$(curl --silent "https://api.github.com/repos/docker/compose/releases/latest" \
        | awk -F '"' '$2~/^tag_name$/{print $4}')"

    url="https://github.com/docker/compose/releases/download/$latestVersion/docker-compose-$(uname -s)-$(uname -m)"
    
    ( set -x
    curl -L "$url" -o "$downDir/docker-compose"
    mv "$downDir/docker-compose" /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    )
}

install_in_centos() {
    if [ "$1" != "7" ]; then
        echo "Support CentOS 7 only." >&2
        return 1
    fi
    
    install_docker
    install_docker_compose
}

case "$osId" in
    "centos") install_in_centos "$osVId"; exit $?;;
    *) break;;
esac

echo "Not supported: OS ID=\"$osId\" VERSION_ID=\"$osVId\"" >&2
exit 1
