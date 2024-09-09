FROM almalinux:9 

USER 0

RUN yum update -y \
    && yum install -y epel-release \
    && yum install -y \
    make \
    gcc \
    which \
    libxml2-devel \
    perl-core \
    perl-Devel-Peek \
    perl-FreezeThaw \
    perl-HTML-Parser \
    perl-libwww-perl \
    wget \
    ruby \
    ruby-devel \
    rubygems \
    && yum clean all

RUN gem install bundler

WORKDIR /headerdoc_build

RUN wget https://opensource.apple.com/tarballs/headerdoc/headerdoc-8.9.31.tar.gz -qO- | tar xzf -

WORKDIR headerdoc-headerdoc-8.9.31

WORKDIR xmlman
RUN sed -i 's/^xml2man: xml2man.o \(.*\)$/xml2man: xml2man.o \1\n\t$(CC) -o $@ $^ $(LDFLAGS)/' Makefile 

WORKDIR ..
RUN make realinstall

COPY . /translator
WORKDIR /translator

RUN bundle install --system

CMD ./translate
