FROM centos:centos8

WORKDIR /headerdoc_build
RUN dnf update -y \
&& dnf install -y epel-release \
&& dnf groupinstall -y "Development Tools" \
&& dnf install -y \
libxml2-devel \
perl-HTML-Parser \
perl-libwww-perl \
perl-FreezeThaw \
libxml2-devel \
wget \
perl-Devel-Peek \
ruby-devel \
rubygem-bundler \
&& dnf clean all

RUN wget https://opensource.apple.com/tarballs/headerdoc/headerdoc-8.9.5.tar.gz -qO- | tar xzf -
WORKDIR headerdoc-8.9.5
RUN make all || true
RUN make realinstall

COPY . /translator
WORKDIR /translator
RUN gem install bundler && bundle install --system
CMD ./translate
