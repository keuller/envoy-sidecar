FROM envoyproxy/envoy

LABEL "Author"="Keuller Magalhaes"

RUN set -eux; \
	apt-get update; \
    apt-get install -y --no-install-recommends wget bzip2 unzip xz-utils ca-certificates p11-kit; \
	rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
ENV JAVA_HOME /usr/local/openjdk-11
ENV PATH $JAVA_HOME/bin:$PATH

# backwards compatibility shim
RUN { echo '#/bin/sh'; echo 'echo "$JAVA_HOME"'; } > /usr/local/bin/docker-java-home && chmod +x /usr/local/bin/docker-java-home && [ "$JAVA_HOME" = "$(docker-java-home)" ]

ENV JAVA_VERSION 11.0.4
ENV JAVA_BASE_URL https://github.com/AdoptOpenJDK/openjdk11-upstream-binaries/releases/download/jdk-11.0.4%2B11/OpenJDK11U-jre_
ENV JAVA_URL_VERSION 11.0.4_11

RUN set -eux; \
	\
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
		amd64) upstreamArch='x64' ;; \
		arm64) upstreamArch='aarch64' ;; \
		*) echo >&2 "error: unsupported architecture: $dpkgArch" ;; \
	esac; \
	\
	wget -O openjdk.tgz.asc "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz.sign"; \
	wget -O openjdk.tgz "${JAVA_BASE_URL}${upstreamArch}_linux_${JAVA_URL_VERSION}.tar.gz" --progress=dot:giga; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys CA5F11C6CE22644D42C6AC4492EF8D39DC13168F; \
	mkdir -p "$JAVA_HOME"; \
    	tar --extract \
    		--file openjdk.tgz \
    		--directory "$JAVA_HOME" \
    		--strip-components 1 \
    		--no-same-owner \
    	; \
    	rm openjdk.tgz*

COPY docker/entrypoint.sh /entrypoint.sh

COPY docker/envoy.yml /etc/envoy/envoy.yaml

COPY target/hello-*.jar /hello.jar

ENTRYPOINT ["/entrypoint.sh"]

CMD ["envoy", "-c", "/etc/envoy/envoy.yaml"]
