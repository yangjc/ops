#!/bin/bash

( _run() {
    _url="$1"

    cat <<EOF > /usr/local/sbin/proxy-on
#!/bin/bash
if [ "\$0" == "-bash" ]; then
    export http_proxy="$_url"
    export https_proxy="$_url"
    echo "HTTP(S) Proxy enabled."
    echo "http_proxy=\$http_proxy"
    echo "https_proxy=\$https_proxy"
else
    echo -e "\033[0;31mIncorrect usage. Should run:\033[0m" >&2
    echo ". proxy-on" >&2
fi
EOF
    chmod +x /usr/local/sbin/proxy-on

    cat <<EOF > /usr/local/sbin/proxy-off
#!/bin/bash
if [ "\$0" == "-bash" ]; then
    export http_proxy=
    export https_proxy=
    echo "HTTP(S) Proxy disabled."
    echo "http_proxy=\$http_proxy"
    echo "https_proxy=\$https_proxy"
else
    echo -e "\033[0;31mIncorrect usage. Should run:\033[0m" >&2
    echo ". proxy-off" >&2
fi
EOF
    chmod +x /usr/local/sbin/proxy-off
}
# _run proxy-url
_run "" )