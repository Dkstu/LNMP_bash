#!/bin/bash
yum update -y;
yum install -y epel-release wget vim;
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config;

yum install nginx -y;
systemctl enable nginx;
systemctl start nginx;

wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm;
rpm -Uvh remi-release-7.rpm;
yum install yum-utils -y;
yum-config-manager --enable remi-php71;

yum install -y php-cli php-fpm php-gd php-curl php-mbstring php-mcrypt php-odbc php-mysqlnd php-xmlrpc php-xml php-pdo php-opcachey;
systemctl enable php-fpm;

wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm;
rpm -Uvh mysql57-community-release-el7-11.noarch.rpm;
yum install mysql-community-server -y;
systemctl enable mysqld;

systemctl start mysqld;
clear;
cat /var/log/mysqld.log | grep password | awk '{print "MySQL預設密碼: "$11}';
echo "請輸入預設密碼後, 變更您的資料庫密碼";
mysql_secure_installation;

sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /etc/php.ini;
sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php.ini;
sed -i 's/post_max_size = 8M/post_max_size = 20M/' /etc/php.ini;
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/' /etc/php.ini;
sed -i 's/;date.timezone =/date.timezone = Asia\/Taipei/' /etc/php.ini;

sed -i 's/user = apache/user = nginx/' /etc/php-fpm.d/www.conf;
sed -i 's/group = apache/group = nginx/' /etc/php-fpm.d/www.conf;
sed -i 's/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm\/www.sock/' /etc/php-fpm.d/www.conf;
sed -i 's/;listen.owner = nobody/listen.owner = nginx/' /etc/php-fpm.d/www.conf;
sed -i 's/;listen.group = nobody/listen.group = nginx/' /etc/php-fpm.d/www.conf;
sed -i 's/;listen.mode = 0660/listen.mode = 0660/' /etc/php-fpm.d/www.conf;

chown -R nginx.nginx /var/lib/php/session/;
mkdir /var/run/php-fpm/;
chown -R nginx.nginx /var/run/php-fpm/;
systemctl start php-fpm;

sudo firewall-cmd --zone=public --add-service=http --permanent;
sudo firewall-cmd --reload;
