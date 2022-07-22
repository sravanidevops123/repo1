#!/bin/bash
cp ~/TestWebApp.war /opt/tomcat8.5.41/webapps
./opt/tomcat8.5.41/bin/startup.sh 

ps -ef | grep java
