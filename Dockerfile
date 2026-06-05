FROM tomcat:9.0-jdk17

# Remove default webapps to avoid Tomcat default apps
RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/hospital_management-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
