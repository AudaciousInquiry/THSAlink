FROM maven AS build

WORKDIR /tmp

# Copy code and compile
COPY . .

WORKDIR /tmp
RUN mvn install

FROM tomcat:jdk15-openjdk-oracle
COPY --from=build /tmp/api/target/nandina-api.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
