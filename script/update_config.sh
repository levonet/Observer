#!/bin/sh

# Default setting
PROJECT_CONFIG="observer.conf~"
DEFAULT_CONFIG="observer.conf.default"
CONFIG_DIFF="observer.conf.diff"
CONFIG_MASK="0600"

COMMAND=$1
if [ -z "$COMMAND" ]; then
    COMMAND="X"
fi

case "$COMMAND" in
    "init" )
        if [ ! -z "$2" ]; then
            cp -f $2 $PROJECT_CONFIG
            chmod $CONFIG_MASK $PROJECT_CONFIG
        fi
        diff -urN $DEFAULT_CONFIG $PROJECT_CONFIG > $CONFIG_DIFF
        chmod $CONFIG_MASK $CONFIG_DIFF
        rm $PROJECT_CONFIG
        exit
        ;;
    "update" )
        if [ -f $CONFIG_DIFF ]; then
            cp -f $DEFAULT_CONFIG $PROJECT_CONFIG
            patch -p0 < $CONFIG_DIFF
            chmod $CONFIG_MASK $PROJECT_CONFIG
        else
            echo "$CONFIG_DIFF not found!"
        fi
        exit
        ;;
    # Unknow option
    * )
        echo "Usage:"
        echo "    $0 init <configfile>   Create diff file between current and default configs"
        echo "    $0 update              Create config file with '~' from default config file"
        exit 1
        ;;
esac
