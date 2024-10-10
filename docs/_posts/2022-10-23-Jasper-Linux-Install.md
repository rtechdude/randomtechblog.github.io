---
layout: post
title:  "Jasper Report Server Linux Install"
date:   2022-10-23 09:30:22 -0600
categories: cool stuff
---
Jasper Report Server is a powerful and flexible reporting and analytics platform developed by TIBCO Software Inc. It's designed to help organizations create, manage, and distribute reports and data visualizations.

TIBCO offers an all in one install package but it makes it harder to patch individual components.

So I decided to use the minimal install and manually install the components myself.



{% highlight bash %}
#!/bin/bash


#Install java
sudo yum install java-1.8.0-openjdk


##############Install tomcat#######################
sudo wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.64/bin/apache-tomcat-9.0.64.zip -O /opt/tomcat/apache-tomcat-9.0.64.zip
sudo unzip /opt/tomcat/apache-tomcat-9.0.64.zip

# Create tomcat group
sudo groupadd tomcat

# Create tomcat user
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

#chmod scripts
files_to_change=$(find /opt/tomcat/latest/bin -name "*.sh")

# Set each found file as executable
for file in $files_to_change; do
    chmod +x "$file"
done

sudo ln -s /opt/tomcat/apache-tomcat-9.0.64 latest


#create service file
sudo bash -c 'cat <<EOF > /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 8.5 servlet container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat/latest"
Environment="CATALINA_HOME=/opt/tomcat/latest"
Environment="CATALINA_PID=/opt/tomcat/latest/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"
ExecStart=/opt/tomcat/latest/bin/startup.sh
ExecStop=/opt/tomcat/latest/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable tomcat.service
sudo systemctl start tomcat.service

#postgres install
sudo yum install postgresql postgresql-server postgresql-contrib -y

#Initialize PostgreSQL
postgresql-setup initdb


#Change postgres to password auth
sudo sed -i 's|^host    all    all    127.0.0.1/32    ident|host    all    all    127.0.0.1/32    md5|' /var/lib/pgsql/data/pg_hba.conf

#start and enable postgres
sudo systemctl start postgresql
sudo systemctl enable postgresql

#change postgres password
sudo su postgres
psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"

############ install jasper #################

# Download Jasper zip from TIBCO's website
        
#copy sample properties file
sudo cp /opt/jasperreports-server-cp-8.0.0-bin/buildomatic/sample_conf/postgresql_master.properties /opt/jasperreports-server-cp-8.0.0-bin/buildomatic/default_master.properties

#change property file
sudo sed -i 's/^appServerDir = C:\\\\Program Files\\\\Apache Software Foundation\\\\Tomcat 9.0/#&/' /opt/jasperreports-server-cp-8.0.0-bin/buildomatic/default_master.properties
sudo sed -i 's|^# CATALINA_HOME = /usr/share/tomcat9|CATALINA_HOME = /opt/tomcat/latest' /opt/jasperreports-server-cp-8.0.0-bin/buildomatic/default_master.properties
sudo sed -i 's|^# CATALINA_BASE = /var/lib/tomcat9|CATALINA_BASE = /opt/tomcat/latest' /opt/jasperreports-server-cp-8.0.0-bin/buildomatic/default_master.properties
sudo sed -i 's|^# webAppNameCE = jasperserver|webAppNameCE = jasperserver' /opt/jasperreports-server-cp-8.0.0-bin/buildomatic/default_master.properties

#run jasper installer
cd /opt/jasperreports-server-cp-8.0.0-bin/buildomatic
./js-install-ce.sh minimal


{% endhighlight %}


You should now be able to access the web UI at http://127.0.0.1:8080

