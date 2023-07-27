FROM tomcat:8
# COPY target/*.war /usr/local/tomcat/webapps/
COPY target/*-SNAPSHOT/*.html /usr/local/tomcat/webapps/
