#install asterisk in debian 9 stretch

#install net-tools

apt-get install net-tools

#update

apt-get update && apt-get upgrade -y

#install packeges needs
apt-get install -y build-essential linux-headers-`uname -r`

apt-get install -y openssh-server apache2 bison flex libmariadb-dev

apt-get install -y libmariadbclient-dev mariadb-server mariadb-client

apt-get install -y php-pear curl sox php7.0 php7.0-mysql php7.0-mcrypt

apt-get install -y php7.0-curl php7.0-gd libapache2-mod-php7.0 php7.0-mbstring

apt-get install -y php7.0-xml libncurses5-dev libssl-dev mpg123 libpng-dev

apt-get install -y libxml2-dev libxml2 libcurl3 libnewt-dev sqlite3 libsqlite3-dev

apt-get install -y pkg-config automake libtool autoconf git unixodbc-dev uuid uuid-dev

apt-get install -y libasound2-dev libogg-dev libvorbis-dev libcurl4-openssl-dev

apt-get install -y libical-dev libneon27-dev libsrtp0-dev libspandsp-dev

apt-get install -y sudo vim subversion libgmime-2.6-0 libgmime-2.6-dev

#Downloads arquives dahdi, libpri and asterisk 15


wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz

wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz

wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-15-current.tar.gz

wget http://www.digip.org/jansson/releases/jansson-2.11.tar.gz

wget http://www.pjsip.org/release/2.7.2/pjproject-2.7.2.tar.bz2

#descompact and install arquives dahdi and libpri


cd /usr/src/

tar xvfz dahdi-linux-complete-current.tar.gz

cd dahdi-linux-complete-*

make all

make install

make config

cd /usr/src/

tar xvfz libpri-current.tar.gz

cd libpri-*

make

make install


#install pjproject

cd /usr/src

tar -xjvf pjproject-2.6.tar.bz2

cd pjproject-2.6

CFLAGS='-DPJ_HAS_IPV6=1' ./configure --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr

make dep

make

make install

#install jansson

cd /usr/src

tar vxfz jansson.tar.gz

cd jansson-*

autoreconf -i

./configure

make

make install

#configure ODBC

cat >> /etc/odbcinst.ini << EOF
[MySQL]
Description = ODBC for MySQL
Driver = /usr/lib/x86_64-linux-gnu/odbc/libmyodbc.so
Setup = /usr/lib/x86_64-linux-gnu/odbc/libodbcmyS.so
FileUsage = 1
EOF

#Edite ou crie o arquivo /etc/odbc.ini e configure:

cat >> /etc/odbc.ini << EOF
[MySQL-asteriskcdrdb]
Description=MySQL connection to 'asteriskcdrdb' database
driver=MySQL
server=localhost
database=cdr
Port=3306
Socket=/var/run/mysqld/mysqld.sock
option=3
EOF

#configure MariaDB

mysql -u root -p

create database asterisk;

use dateabase asterisk;

CREATE TABLE `cdr` (
`calldate` datetime NOT NULL default '0000-00-00 00:00:00',
`clid` varchar(80) NOT NULL default '',
`src` varchar(80) NOT NULL default '',
`dst` varchar(80) NOT NULL default '',
`dcontext` varchar(80) NOT NULL default '',
`channel` varchar(80) NOT NULL default '',
`dstchannel` varchar(80) NOT NULL default '',
`lastapp` varchar(80) NOT NULL default '',
`lastdata` varchar(80) NOT NULL default '',
`duration` int(11) NOT NULL default '0',
`billsec` int(11) NOT NULL default '0',
`disposition` varchar(45) NOT NULL default '',
`amaflags` int(11) NOT NULL default '0',
`accountcode` varchar(20) NOT NULL default '',
'uniqueid' varchar(32) NOT NULL default '',
`userfield` varchar(255) NOT NULL default '',
'did' varchar(50) NOT NULL default '',
'recordingfile' varchar(255) NOT NULL default '',
 KEY `calldate` (`calldate`),
 KEY `dst` (`dst`),
 KEY `accountcode` (`accountcode`),
 KEY `uniqueid` (`uniqueid`)
);

# Editar o arquivo /etc/odbcinst.ini nas seguintes configurações
[Default]
Driver = /path/to/libmyodbc.so
[MySQL]
Description = MySQL driver
Driver = /path/to/libmyodbc.so
Setup = /path/to/libodbcmyS.so
# Editar o arquivo /etc/odbc.ini nas seguintes configurações
[MySQL-asterisk]
Driver = MySQL
Description = MySQL Connector for Asterisk
Server = localhost
Port = 3306
Database = asterisk
username = asterisk
password = asteriskpasswordhere
Option = 3
Socket = /var/run/mysqld/mysqld.sock
# Editar o arquivo /etc/asterisk/res_odbc.conf nas seguintes configurações
[asterisk]
enabled=yes
dsn=MySQL-asterisk
username=asterisk
password=yourasteriskpasswordhere
pooling=no
limit=1
pre-connect=yes
share_connections=yes
sanitysql=select 1
isolation=repeatable_read
# Editar o arquivo /etc/asterisk/cdr_odbc.conf nas seguintes configurações
[global]
dsn=asterisk
loguniqueid=yes
table=cdr
dispositionstring=yes
usegmtime=no
hrtime=yes
# Editar o arquivo /etc/asterisk/cdr_manager.conf nas seguintes configurações
[general]
enabled = yes
# Editar o arquivo /etc/asterisk/cdr_adaptive_odbc.conf nas seguintes
configurações
[asteriskcdr]
connection=asterisk
table=cdr
alias start=calldate
# Editar o arquivo /etc/asterisk/modules.conf e descomentar as opções do odbc
# Restart o Asterisk
sudo service asterisk restart
# Verifique se o Asterisk está conectado junto ao ODBC e o CDR.
odbcinst -q -d
CLI > odbc show all
CLI > cdr show status

#configurar driver odbc no debian
cd /usr/src

wget https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.11-linux-debian9-x86-64bit.tar.gz

 tar -zxvf mysql-connector-odbc-8.0.11-linux-debian9-x86-64bit.tar.gz

 cp mysql-connector-odbc-8.0.11-linux-debian9-x86-64bit/lib/libmyodbc8a.so /usr/lib/x86_64-linux-gnu/odbc/

 cd /usr/lib/x86_64-linux-gnu/odbc/

 mv libmyodbc8a.so libmyodbc.so

#Restart o Asterisk
sudo service asterisk restart
# Verifique se o Asterisk está conectado junto ao ODBC e o CDR.
odbcinst -q -d
CLI > odbc show all
CLI > cdr show status

 #
