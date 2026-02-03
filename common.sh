# Day 19:

#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"
# colors
NORMAL='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[33m'

START_TIME=$(date +%s)
mkdir -p $LOGS_FOLDER


echo "$(date "+%Y-%m-%d %H:%M:%S") || Script started executing at: $(date)" | tee -a $LOGS_FILE

check_root()
{
if [ $USERID -ne 0 ]; then
    echo -e "$RED Pls run this script with root user access $NORMAL"
    exit 1
fi
}

# Validate function
VALIDATE()
{
if [ $1 -ne 0 ]; then
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") || $2... $RED failed $NORMAL" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") || $2... $GREEN success $NORMAL" | tee -a $LOGS_FILE
fi
}

print_total_time()
{
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") || Script executed at: $TOTAL_TIME seconds" | tee -a $LOGS_FILE
}
