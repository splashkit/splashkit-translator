FROM almalinux:9 

USER 0

RUN dnf update -y \
    && dnf install -y \
    make \
    gcc \
    which \
    libxml2-devel \
    perl-core \
    perl-Devel-Peek \
    perl-HTML-Parser \
    perl-libwww-perl \
    wget \
    ruby \
    ruby-devel \
    rubygems \
    cpan \ 
    && dnf clean all

RUN cpan -i FreezeThaw

RUN gem install bundler

WORKDIR /headerdoc_build

RUN wget https://opensource.apple.com/tarballs/headerdoc/headerdoc-8.9.31.tar.gz -qO- | tar xzf -

WORKDIR headerdoc-headerdoc-8.9.31

WORKDIR xmlman
# This command finds the xml2man build command and appends the linking flags at the end. This is not done already, for some reason.
RUN sed -i 's/^xml2man: xml2man.o \(.*\)$/xml2man: xml2man.o \1\n\t$(CC) -o $@ $^ $(LDFLAGS)/' Makefile 

WORKDIR ..
RUN make realinstall

COPY . /translator
WORKDIR /translator

RUN bundle install --system

CMD ./translate