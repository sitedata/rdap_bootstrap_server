FROM jboss/wildfly:18.0.1.Final 

LABEL maintainer="gdubin@arin.net"

# COPY path-to-your-application-war path-to-webapps-in-docker-tomcat
COPY build/libs/rdap_bootstrap_server-1000.0-SNAPSHOT.war /opt/jboss/wildfly/standalone/deployments/
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
