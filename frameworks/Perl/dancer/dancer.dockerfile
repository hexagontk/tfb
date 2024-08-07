FROM perl:5.40

RUN apt-get update -yqq && apt-get install -yqq nginx

ADD ./ /dancer
WORKDIR /dancer

RUN cpanm --notest --no-man-page \
      JSON IO::Socket::IP IO::Socket::SSL \
      Dancer@1.3134 \
      Dancer::Plugin::Database@2.10 \
      DBI@1.633 \
      DBD::MariaDB@1.23 \
      JSON::XS@3.01 \
      Plack@1.0034 \
      Starman@0.4011

EXPOSE 8080

CMD nginx -c /dancer/nginx.conf && \
    plackup -E production -s Starman --workers=$(nproc) --max-requests=100000 -l /tmp/perl-dancer.sock -a ./app.pl

