#!/bin/bash --
# check natapp proc, check logfile, post new url
# USAGE: nat_endpoint_checker.sh (system startup / crontab)

NATAPP_AUTHTOKEN=0fe7367c70378222
SERVERCHAN_KEY=SCU14967Tb8a2240fb9881e859ba765c77730fdb659f862a2cf932
LOGFILE=/tmp/natapp.log
KEYWORD="established"


start_natapp() {
    rm -rf $LOGFILE
    /usr/local/bin/natapp -authtoken $NATAPP_AUTHTOKEN -log stdout -loglevel INFO > $LOGFILE &
    sleep 10 # MAGIC wait for natapp connection established
}

# check natapp proc
if $(ps -ef | grep natapp | grep -q -v grep); then
    sleep 0; # Do nothing
else
    start_natapp
fi

ENDPOINT_URL=$(grep $KEYWORD $LOGFILE | tail -n 1 | sed 's=.*tcp://\(.*\)$=\1=')
# check logfile
SERVED_ADDR=$(head -n 1 $LOGFILE | awk -F'%' '{print $2}')
if [[ $SERVED_ADDR == '' ]]; then
    # logfile is not initlized, add served address to first line & post url
    _sed_pattern="1 i\served address%${ENDPOINT_URL}"
    sed -i "$_sed_pattern" $LOGFILE
    curl -sSfL "https://sc.ftqq.com/${SERVERCHAN_KEY}.send?text=${ENDPOINT_URL}"
else
    if [[ $SERVED_ADDR != $ENDPOINT_URL ]]; then
        # write back to logfile & post url
        sed -i "s%${SERVED_ADDR}%${ENDPOINT_URL}%" $LOGFILE
        curl -sSfL "https://sc.ftqq.com/${SERVERCHAN_KEY}.send?text=${ENDPOINT_URL}"
    fi
fi