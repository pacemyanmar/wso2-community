FROM curlimages/curl as source
WORKDIR /tmp
RUN curl -o wso2.tar.gz -L "https://github.com/wso2/product-apim/archive/refs/tags/v4.1.0.tar.gz"

RUN curl -o postgresql-42.5.0.jar -L https://jdbc.postgresql.org/download/postgresql-42.5.0.jar

RUN tar -zxf wso2.tar.gz


FROM maven:3-eclipse-temurin-8 as builder

RUN mkdir /opt/wso2

COPY --from=source /tmp/product-apim-4.1.0 /opt/wso2

WORKDIR /opt/wso2

RUN MAVEN_OPTS="-Xmx8192M -XX:MaxPermSize=1024m -Dmaven.wagon.http.ssl.allowall=true -Dterminal.jline=false -Dterminal.ansi=true -Dmaven.test.skip=true" mvn clean install


FROM eclipse-temurin:8-jdk

WORKDIR /opt

COPY --from=builder /opt/wso2/modules/distribution/product/target/wso2am-4.1.0.zip /opt/

RUN apt update && apt dist-upgrade -yqq && apt install unzip

RUN unzip wso2am-4.1.0.zip && rm -rf wso2am-4.1.0.zip

RUN mv wso2am-4.1.0 wso2am

COPY --from=source /tmp/postgresql-42.5.0.jar /opt/wso2am/repository/components/lib/

EXPOSE 9443

EXPOSE 8243

EXPOSE 8280

CMD ["/opt/wso2am/bin/api-manager.sh"]
