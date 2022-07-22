sudo yum update -y && sudo yum install java-1.8.0-openjdk -y

cd /opt/
curl -O https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.41/bin/apache-tomcat-8.5.41.tar.gz
tar -xzvf apache-tomcat-8.5.41.tar.gz
mv apache-tomcat-8* tomcat8.5.41
