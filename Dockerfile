# ---- build stage ----
FROM node:22-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---- runtime stage ----
FROM httpd:2.4-alpine

RUN apk add --no-cache apache2-utils

COPY --from=build /app/dist/ /usr/local/apache2/htdocs/
COPY apache/httpd-auth.conf /usr/local/apache2/conf/extra/httpd-auth.conf
RUN echo "Include conf/extra/httpd-auth.conf" >> /usr/local/apache2/conf/httpd.conf

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["httpd-foreground"]
