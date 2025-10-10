FROM mysql:latest
ENV MYSQL_ROOT_PASSWORD=urubu100
COPY script_cyberbeef.sql ./docker-entrypoint-initdb.d/
EXPOSE 3306
