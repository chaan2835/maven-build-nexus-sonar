FROM tomcat:8
# COPY target/*.war /usr/local/tomcat/webapps/
COPY target/*.html /usr/local/tomcat/webapps/
