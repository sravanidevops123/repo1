sudo yum update -y && sudo yum install java-1.8.0-openjdk -y
sudo chown ec2-user:ec2-user /opt/

cd /opt/
curl -O https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.41/bin/apache-tomcat-8.5.41.tar.gz &
sleep 15s
tar -xzvf apache-tomcat-8.5.41.tar.gz
mv apache-tomcat-8.5.41 tomcat8.5.41
