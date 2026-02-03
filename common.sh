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

SCRIPT_DIR=$PWD 

START_TIME=$(date +%s)
MONGODB_HOST=mongodb.vardevops.online
MYSQL_HOST=mysql.vardevops.online

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

nodejs_setup()
{
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "disabling node js default version"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "enabling node js 20 version"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "installing node js"

    npm install &>>$LOGS_FILE
    VALIDATE $? "Install dependencies"
}

java_setup()
{
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Installing Maven"

    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "Installing and Building $app_name"


    mv target/$app_name-1.0.jar $app_name.jar 
    VALIDATE $? "Moving and Renaming $app_name"
}


app_setup()
{
    id roboshop &>>$LOGS_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "Roboshop user exists, hence $RED skipping $NORMAL"
    fi

    mkdir -p /app 
    VALIDATE $? "Creating directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Downloading $app_name code"

    cd /app 
    VALIDATE $? "Moving to app directory"

    rm -rf /app/*
    VALIDATE $? "Remove existing code"

    unzip /tmp/$app_name.zip &>>$LOGS_FILE
    VALIDATE $? "Unzipping the $app_name code"
}

systemd_setup()
{
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "Created systemctl $app_name service"

    systemctl daemon-reload
    VALIDATE $? "daemon reload"

    systemctl enable $app_name &>>$LOGS_FILE
    systemctl start $app_name &>>$LOGS_FILE
    VALIDATE $? "enabling and starting $app_name"

}

app_restart()
{
    systemctl restart $app_name &>>$LOGS_FILE
    VALIDATE $? "Restarting $app_name"
}


print_total_time()
{
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME-$START_TIME))
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") || Script executed at: $TOTAL_TIME seconds" | tee -a $LOGS_FILE
}