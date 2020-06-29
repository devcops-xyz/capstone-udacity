FROM nginx:alpine

COPY /app/. /usr/share/nginx/html

ADD https://get.aquasec.com/microscanner /
RUN chmod +x /microscanner
RUN /microscanner <TOKEN> [--continue-on-failure]