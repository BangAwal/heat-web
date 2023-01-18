#!/bin/bash
sudo subscription-manager register --force --username=your-email --password=your-pass
sudo subscription-manager attach --auto
sudo yum repolist
yum install -y ansible firewalld
mkfs -t xfs /dev/vdb
export ANSIBLE_LOG_PATH=~/ansible.log
cd /tmp; git clone https://github.com/BangAwal/heat-web.git
cp -rf /tmp/heat-web/db-role/db /etc/ansible/roles
touch /tmp/heat-web/db-role/hosts
cat << EOF > /tmp/heat-web/db-role/hosts
[dbservers]
localhost ansible_connection=local
EOF
cd /tmp/heat-web/db-role
ansible-playbook -i hosts dbserver.yml
mysql --database=mydb --user=admin --password=redhat -se "CREATE TABLE employee(id INT NOT NULL AUTO_INCREMENT,name VARCHAR(100) NOT NULL,age VARCHAR(40) NOT NULL,PRIMARY KEY ( id ));"
RES=$?
[[ "$RES" -eq 0 ]] && $db_wc_notify \
--data-binary '{"status": "SUCCESS"}' \
|| $db_wc_notify --data-binary '{"status": "FAILURE"}'
