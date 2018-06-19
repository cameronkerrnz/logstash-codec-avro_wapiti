FROM docker.elastic.co/logstash/logstash-oss:6.3.0

ENV JRUBY_HOME=/usr/share/logstash/vendor/jruby
ENV PATH=$JRUBY_HOME/bin:$PATH

RUN gem install bundler rspec
RUN gem install logstash-core-plugin-api logstash-devutils

WORKDIR /work
ENTRYPOINT /bin/bash


