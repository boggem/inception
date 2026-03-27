FROM alpine:3.23.2

RUN apk update && apk add nginx openssl

EXPOSE 443

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes \
	-out /etc/nginx/ssl/public_certificate.crt \
	-keyout /etc/nginx/ssl/private.key \
	-subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Hive/CN=gboggion.42.fr"

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
RUN chmod 644 /etc/nginx/nginx.conf

CMD ["nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
