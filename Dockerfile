FROM registry.access.redhat.com/ubi8-minimal AS builder

ENV M2_HOME=/opt/maven
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.17.0.8-2.el8_6.aarch64/

RUN microdnf install -y tar gzip which java-11-openjdk java-11-openjdk-devel

RUN curl -s https://apache.uib.no/maven/maven-3/3.5.4/binaries/apache-maven-3.5.4-bin.tar.gz | tar xz && mv apache-maven-3.5.4 /opt/maven 

WORKDIR /tmp/keycloak
ADD quarkus .

#Build stage
#RUN $M2_HOME/bin/mvn -Pdistribution -pl distribution/server-dist -am -Dmaven.test.skip -e -X clean install
RUN $M2_HOME/bin/mvn clean install -Pdistribution -am -Dmaven.test.skip  

RUN (cd /tmp/keycloak/dist/target/ && \
    tar -xvf keycloak-*.tar.gz && \
    rm -rf keycloak-*.tar.gz archive-tmp dependency-maven-plugin-markers keycloak-*.zip keycloak-client-tools keycloak-quarkus-server keycloak-quarkus-server-app) || true

RUN mv /tmp/keycloak/dist/target/keycloak-* /opt/keycloak && mkdir -p /opt/keycloak/data
RUN mv /tmp/keycloak/dist/target/lib /opt/keycloak

RUN chmod -R g+rwX /opt/keycloak

#FROM registry.access.redhat.com/ubi8-minimal
#ENV LANG en_US.UTF-8

#COPY --from=builder --chown=1000:0 /opt/keycloak /opt/keycloak

#RUN microdnf update -y && microdnf install -y --nodocs java-17-openjdk-headless glibc-langpack-en && microdnf clean all && rm -rf /var/cache/yum/* && echo "keycloak:x:0:root" >> /etc/group && echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd

#USER 1000

#EXPOSE 8080
#EXPOSE 8443

#ENTRYPOINT [ "/opt/keycloak/bin/kc.sh" ]
