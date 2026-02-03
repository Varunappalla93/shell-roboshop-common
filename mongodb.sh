# Day 19:
#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Installing mongodb server"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable mongodb"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted mongodb"

print_total_time

#gf