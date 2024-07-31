FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install apache2 -y
RUN apt-get install php -y
RUN apt-get install php-mysql -y
ADD . /var/www/html
EXPOSE 80
CMD [“apache2ctl”, “-D”, “FOREGROUND”]
