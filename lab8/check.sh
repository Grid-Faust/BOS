#!/bin/bash

err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S')]: $*" >&2
}

unitpath() {
    tmp=$(systemctl status $1 | grep loaded | head -1)
    local path=$(awk '{ sub(/.*\(/, ""); sub(/;.*/, ""); print }' <<< $tmp)
    echo $path
}

getw() {
    getfacl $1 2>/dev/null | grep -v "#" | grep -v "user::" | grep w
}

getsuid() {
    getfacl $1 2>/dev/null | grep flags | grep -E " s**"
}

getowner() {
    tmp=$(getfacl $1 2>/dev/null | grep owner)
    echo $(awk '{ sub(/.*: /, ""); print }' <<< $tmp)
}

services=$(systemctl list-units --type=service | head -n -7 |  tail -n +2 | cut -d " " -f1)

for service in $services; do
    upath=$(unitpath $service)
    firstv=$(getw $upath)
    uowner=$(getowner $upath)

    if [[ ! -z "$firstv" ]]; then
        echo unit of service $service can be changed not only by owner \(see getfacl $upath\)
    fi

    readarray -t files < <(grep ^Exec $upath)

    for start in "${files[@]}"; do
        startfile=$(awk '{ sub(/ .*/, ""); sub(/^Exec.*?=-?/, "");  print }' <<< $start)
        firstv=$(getw $startfile)
        if [[ ! -z "$firstv" ]]; then
            echo startfile of service $service can be changed not only by owner \(see getfacl $startfile\)
        fi

        startowner=$(getowner $startfile)
        if [ $startowner == "root" ]; then
            if [ $uowner != "root" ]; then
                suidcheck=$(getsuid $startfile)
                if [[ ! -z $suidcheck ]]; then
                    echo startfile of service $service owned not by root by have suid bit \(see getfacl $startfile\)
                fi
            fi
        fi
    done

done
