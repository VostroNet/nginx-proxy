FROM openresty/openresty:alpine
MAINTAINER Matthew Mckenzie mmckenzie@vostronet.com

# Install wget and install/updates certificates
RUN apk add --no-cache --virtual .run-deps \
    ca-certificates bash wget openssl unzip \
    && update-ca-certificates

RUN ln -s /usr/local/openresty/nginx /etc/nginx && mkdir /etc/nginx/conf.d && rm /usr/local/openresty/nginx/conf/nginx.conf

# Install Forego
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

# ENV DOCKER_GEN_VERSION 0.7.3
ENV VERSION_RANCHER_GEN="artifacts/master"

RUN wget "https://gitlab.com/adi90x/rancher-gen-rap/builds/$VERSION_RANCHER_GEN/download?job=compile-go" -O /tmp/rancher-gen-rap.zip \
	&& unzip /tmp/rancher-gen-rap.zip -d /usr/local/bin \
	&& chmod +x /usr/local/bin/rancher-gen \
	&& rm -f /tmp/rancher-gen-rap.zip


# 19/07/2017 13:10:28cron.1      | /bin/bash: crond: command not found
# 19/07/2017 13:10:28ranchergen.1 | /bin/bash: /usr/local/bin/rancher-gen: No such file or directory

# RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
#  && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
#  && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

RUN mkdir -p /var/log/nginx/ && touch /var/log/nginx/access.log

COPY . /app/

COPY ./nginx.conf /usr/local/openresty/nginx/conf/

WORKDIR /app/

# ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs", "/etc/nginx/dhparam"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
