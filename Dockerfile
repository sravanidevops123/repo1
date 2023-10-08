FROM tomcat:8.5.41-jdk8-slim
COPY TestWebApp/target/TestWebApp.war /usr/local/tomcat/webapps 

