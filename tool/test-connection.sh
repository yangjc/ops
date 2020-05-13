#!/usr/bin/env bash

if [ -z "$CONN_CMD" ] && [ -z "$1" ]; then
    echo "Usage 1
    CONN_CMD= [RESULT_CMD=] [OK_REG=] ./$(basename "$BASH_SOURCE")

    CONN_CMD=<连接命令>  例如: \"curl --silent -I https://www.baidu.com\"
    RESULT_CMD=<处理输出文本的命令>  例如: \"head -1\"
    OK_REG=<判断符合预期文本的正则表达式>  例如: \"^HTTP\\/1\\.1\\ 200\\ OK\"

Usage 2
    ./$(basename "$BASH_SOURCE") <log-file>
" >&2
    exit 1
fi

rok="--- Result Status Expected"
rnok="--- Result Status Unexpected"

show_log() {
    logfile="$1"

    awk -F ' Cost ' \
'$1~/^---$/{c=$2;a=int(c);b=a+1;x[a" ~ "b]++;s++;if(c<3)x["0 ~ 3"]++}'\
'END{for(i in x)printf "%ss  %s/%s %s%%\n",i,x[i],s,x[i]/s*100}' \
        "$logfile" \
    | sort -k 1 -n
    echo

    awk -F ' Cost ' \
'{if($0~/^\+\+\+/){d=substr($0,5,13);r=0}'\
'if($0~/^'"$rok"'$/){r=1}'\
'if($0~/^--- Cost /){x[d]+=r;y[d]+=(1-r);s[d]++;t[d]+=$2}}'\
'END{for(i in x)printf "[%s]\tOK: %s, Not-OK: %s, All: %s, Success: %s%%, Cost: %s sec\n",i,x[i],y[i],s[i],x[i]/s[i]*100,t[i]/s[i]}' \
        "$logfile" \
    | sort -k1,1 -k2,2
    echo

    awk '{if($0~/^'"$rok"'$/)a++;if($0~/^--- Result Code /)b++}'\
'END{printf "[Total] OK: %s, Not-OK: %s, All: %s, Success: %s%%\n",a,b-a,b,a/b*100}' \
        "$logfile"
}

if [ -n "$1" ]; then
    if [ -f "$1" ]; then
        show_log "$1"
        exit $?
    else
        echo "log file not found: \`$1\`" >&2
        exit 1
    fi
fi

# 返回内容输出到stdout，其它信息输出到stderr，返回代码表示执行是否成功
# 如果使用管道，第一个管道的返回码：${PIPESTATUS[0]}
test_connection() {
    # **替换为具体的请求
    ttext="$( set -x && $CONN_CMD )"

    tcode=$?

    # **替换为对请求结果的额外处理
    if [ -n "$RESULT_CMD" ]; then
        ttext="$(echo "$ttext" | $RESULT_CMD)"
    fi

    # 输出请求结果
    print_ttext "$ttext"
    
    # **替换为如何判断请求结果符合预期
    if [ "$tcode" == "0" ] &&
        ( [ -z "$OK_REG" ] || ( [ -n "$OK_REG" ] && [[ "$ttext" =~ $OK_REG ]] ) ); then
        # 输出符合预期的标记
        echo "$rok"
    else
        echo "$rnok"
    fi

    return $tcode
}


print_ttext() {
    echo "$1" | sed -e 's/^/  /g'
}

type gdate 1>/dev/null 2>&1
if [ "$?" == "0" ]; then
    datecmd=gdate
else
    datecmd=date
fi

echo "+++ $($datecmd "+%Y-%m-%d %H:%M:%S")"
t="$($datecmd +%s)"
n="$($datecmd +%N)"

( test_connection )
r=$?

zz="000000000"
tt="$(expr $($datecmd +%s) - $t)"
nn="$($datecmd +%N)"
c="$(expr $tt$zz + $nn - $n)"
l="$(( ${#c} - ${#zz} ))"
if [ $l -gt 0 ]; then
    cost="${c:0:$l}.${c:$l}"
else
    l="$(( ${#zz} + $l ))"
    cost="0.${zz:$l}$c"
fi

echo "--- Result Code $r"
echo "--- Cost $cost"
echo "--- Nanoseconds $c ($tt $n,$nn)"
echo "--- $($datecmd "+%Y-%m-%d %H:%M:%S")"
echo
