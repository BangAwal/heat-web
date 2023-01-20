#!/bin/bash
sudo yum install -y firewalld git mariadb-server python3-PyMySQL
sudo setsebool -P mysql_connect_any 1
sudo touch /etc/my.cnf
cat << EOF > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
user=mysql
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
port=3306

[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
EOF
sudo systemctl restart mariadb

touch /var/log/mysqld.log
chown mysql:mysql /var/log/mysqld.log
chmod 775 /var/log/mysqld.log

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
chmod 775 /var/run/mysqld

sudo systemctl start mariadb
mysql -u root -p -se "CREATE DATABASE mydb;"
mysql -u root -p -se "CREATE USER 'admin'@'%' IDENTIFIED BY 'redhat';GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';"
mysql --database=mydb --user=admin --password=redhat -se "CREATE TABLE employee(id INT NOT NULL AUTO_INCREMENT,name VARCHAR(100) NOT NULL,age VARCHAR(40) NOT NULL,PRIMARY KEY ( id ));"

RES=$?
[[ "$RES" -eq 0 ]] && $db_wc_notify \
--data-binary '{"status": "SUCCESS"}' \
|| $db_wc_notify --data-binary '{"status": "FAILURE"}'
