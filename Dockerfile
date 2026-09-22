FROM httpd:2.4-alpine

RUN apk add --no-cache apache2-utils

COPY site/ /usr/local/apache2/htdocs/
COPY apache/httpd-auth.conf /usr/local/apache2/conf/extra/httpd-auth.conf
RUN echo "Include conf/extra/httpd-auth.conf" >> /usr/local/apache2/conf/httpd.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd-foreground"]
