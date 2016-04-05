#!/usr/bin/env bash

echo "***** Pivotal Greenplum Command Center Initialization *****"

# change to the root directory
cd /

# change ownership of /usr/local/greenplum-cc-web-1.3.0.0-build-91 to gpadmin
chown -h gpadmin:gpadmin /usr/local/greenplum-cc-web
chown -R gpadmin:gpadmin /usr/local/greenplum-cc-web-2.0.0-build-32

echo "***** Install gpperfmon *****"
# make greenplum database commands available to gpadmin
# install gpperfmon
sudo -u gpadmin bash -c ". ~/.bashrc && source /home/gpadmin/.bash_profile && gpperfmon_install --enable --password changeme --port 5432"

cd /home/gpadmin

# echo "***** add GPPERFMONHOME to .bash_profile *****"
echo "" >> .bash_profile
echo "GPPERFMONHOME=/usr/local/greenplum-cc-web" >> .bash_profile
echo "export GPPERFMONHOME" >> .bash_profile
echo "" >> .bash_profile
echo "source /usr/local/greenplum-cc-web/gpcc_path.sh" >> .bash_profile

source /home/gpadmin/.bash_profile

# add pg_hba.conf entry to allow access by gpmon to gpperfmon via ip6 ::1
echo "host     all                 gpmon   ::1/128                md5" >>  /data/master/gpseg-1/pg_hba.conf

echo "***** run gpstop -u to reload pg_hba.conf *****"
# make greenplum database commands available to gpadmin
# run gpstop -u
sudo -u gpadmin bash -c ". ~/.bashrc && source /home/gpadmin/.bash_profile && gpstop -u"

echo "***** configuring Greenplum Command Center *****"
# setup Greenplum Command Center
/usr/bin/expect<<EOF

#spawn  sudo -u gpadmin bash -c ". ~/.bashrc && source /home/gpadmin/.bash_profile && source /usr/local/greenplum-db/greenplum_path.sh && gpcmdr --setup"
spawn  sudo -u gpadmin bash -c ". ~/.bashrc && source /home/gpadmin/.bash_profile && gpcmdr --setup"

expect "Please enter a new instance name:"
send "gp1\r"

expect "Is the master host for the Greenplum Database remote?"
send "\r"

expect "What would you like to use for the display name for this instance:" 
send "traindb\r"

expect "What port does the Greenplum Database use?" 
send "\r"

expect "Would you like to install workload manager?" 
send "\r"

expect "What port would you like the web server to use for this instance" 
send "\r"

expect "Do you want to enable SSL for the Web API" 
send "n\r"

expect "Do you want to enable ipV6 for the Web API" 
send "\r"

expect "Do you want to enable Cross Site Request Forgery Protection for the Web API" 
send "\r"

expect "Do you want to copy the instance to a standby master host" 
send "n\r"

expect

EOF

echo "***** starting Greenplum Command Center *****"
# start Greenplum Command Center
sudo -u gpadmin bash -c ". ~/.bashrc && source /home/gpadmin/.bash_profile && gpcmdr --start gp1"