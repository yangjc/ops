#!/usr/bin/env bash

# 返回内容输出到stdout，其它信息输出到stderr，返回代码表示执行是否成功
# 如果使用管道，第一个管道的返回码：${PIPESTATUS[0]}
test_connection() {
    # **替换为具体的请求
    ttext="$( set -x && curl --silent -I https://www.baidu.com )"

    tcode=$?

    # **替换为对请求结果的额外处理
    ttext="$(echo "$ttext" | head -1)"

    # 输出请求结果
    print_ttext "$ttext"
    
    # **替换为如何判断请求结果符合预期
    if [ "$tcode" == "0" ] && [[ "$ttext" =~ ^HTTP\/1\.1\ 200\ OK ]]; then
        # 输出符合预期的标记
        echo "$rok"
    fi

    return $tcode
}


print_ttext() {
    echo "$1" | sed -e 's/^/  /g'
}

rok="--- Result Status: Expected"

logfile="${BASH_SOURCE}.log"

if [ "$1" == "log" ]; then
    cd "$(dirname "$0")"
    awk -F ' Cost ' \
        '$1~/^---$/{c=$2;a=int(c);b=a+1;x[a" ~ "b]++;s++;if(c<3)x["0 ~ 3"]++}'\
'END{for(i in x)printf "%ss  %s/%s %s%\n",i,x[i],s,x[i]/s*100}' \
        "$logfile" \
    | sort -k 1 -n
    echo
#    awk -F ' Cost ' \
#        '{if($0~/^\+\+\+/){d=substr($0,5,13);r=0}'\
#'if($0~/^Total [0-9]+ repositories.$/){r=1}'\
#'if($0~/^--- Cost /){x[d]+=r;y[d]+=(1-r);s[d]++}}'\
#'END{for(i in x)printf "[%s]\tOK: %s, Timeout: %s, all: %s, Success: %s%\n",i,x[i],y[i],s[i],x[i]/s[i]*100}' \
    awk -F ' Cost ' \
        '{if($0~/^\+\+\+/){d=substr($0,5,13);r=0}'\
'if($0~/^'"$rok"'$/){r=1}'\
'if($0~/^--- Cost /){x[d]+=r;y[d]+=(1-r);s[d]++;t[d]+=$2}}'\
'END{for(i in x)printf "[%s]\tOK: %s, Timeout: %s, all: %s, Success: %s%, Cost: %s sec\n",i,x[i],y[i],s[i],x[i]/s[i]*100,t[i]/s[i]}' \
        "$logfile" \
    | sort -k1,1 -k2,2
    echo
#    awk '{if($0~/^Total [0-9]+ repositories.$/)a++;if($0~/^--- Result /)b++}'\
#'END{printf "OK: %s, Timeout: %s, All: %s, Success: %s%\n",a,b-a,b,a/b*100}' \
    awk '{if($0~/^'"$rok"'$/)a++;if($0~/^--- Result Code /)b++}'\
'END{printf "OK: %s, Timeout: %s, All: %s, Success: %s%\n",a,b-a,b,a/b*100}' \
        "$logfile"
    exit
fi

echo "+++ $(date "+%Y-%m-%d %H:%M:%S")"
t="$(date +%s)"
n="$(date +%N)"

( test_connection )
r=$?

zz="000000000"
tt="$(expr $(date +%s) - $t)"
nn="$(date +%N)"
c="$(expr $tt$zz + $nn - $n)"
l="$(expr ${#nnn} - ${#zz})"
sec="${c:0:$l}"
[ -z "$sec" ] && sec=0
cost="$sec.${c:$l}"

echo "--- $(date "+%Y-%m-%d %H:%M:%S")"
echo "--- Result Code $r"
echo "--- # $tt $n,$nn,$c"
echo "--- Cost $cost"
echo
