FROM alpine:3.12.1
RUN apk update && apk upgrade && apk add --no-cache mariadb-client nano sudo wget curl \
	tree elinks bash shadow procps util-linux coreutils binutils findutils grep && \
	wget https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64 && \
	chmod +x busybox-x86_64 && mv busybox-x86_64 bin/busybox1.28 && \
	mkdir -p /opt/www/cgi-bin                                                                                    
COPY kungfu /opt/www/cgi-bin/
CMD ["/bin/bash","-c","busybox1.28 httpd -f -p 8888 -h /opt/www "]
