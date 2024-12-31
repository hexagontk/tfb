FROM ubuntu:24.04

ENV SWOOLE_VERSION 6.0.0
ENV ENABLE_COROUTINE 1
ENV CPU_MULTIPLES 1
ENV DATABASE_DRIVER mysql

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -yqq > /dev/null \
    && apt install -yqq software-properties-common > /dev/null \
    && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php > /dev/null \
    && apt update -yqq > /dev/null \
    && apt install libbrotli-dev php8.4-cli php8.4-pdo-mysql php8.4-dev -y > /dev/null \
    && cd /tmp && curl -sSL "https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz" | tar xzf - \
    && cd /tmp/swoole-src-${SWOOLE_VERSION} \
    && phpize > /dev/null \
    && ./configure > /dev/null \
    && make -j "$(nproc)" > /dev/null \
    && make install > /dev/null \
    && echo "extension=swoole.so" > /etc/php/8.4/cli/conf.d/50-swoole.ini \
    && echo "memory_limit=1024M" >> /etc/php/8.4/cli/php.ini

WORKDIR /swoole

ADD ./swoole-server.php /swoole
ADD ./database.php /swoole

COPY 10-opcache.ini /etc/php/8.4/cli/conf.d/10-opcache.ini

EXPOSE 8080
CMD php /swoole/swoole-server.php