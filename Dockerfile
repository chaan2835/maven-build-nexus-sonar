FROM tomcat:8
# COPY target/*.war /usr/local/tomcat/webapps/
COPY src/main/webapp/*.html /usr/local/tomcat/webapps/