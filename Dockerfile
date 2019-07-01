FROM ubuntu:18.04

MAINTAINER Shams <shams@shams.in>

ARG node_ver=10
ARG pandoc_ver=2.7.2

ENV HOME /root
WORKDIR /root

ENV DEBIAN_FRONTEND noninteractive

# install general dependencies
RUN apt-get -qq -y update
RUN apt-get -qq -y install curl wget build-essential zip python-pip jq git libfontconfig locales software-properties-common

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_$node_ver.x -o nodesource_setup.sh && chmod +x nodesource_setup.sh
RUN ./nodesource_setup.sh
RUN apt-get -qq -y install nodejs

# log what version of node we're running on
RUN echo "node version $(node -v) running"
RUN echo "npm version $(npm -v) running"

# install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -yqq
RUN apt-get install -yqq yarn

# install pm2
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv D1EA2D4C
RUN echo "deb http://apt.pm2.io/ubuntu stable main" | tee /etc/apt/sources.list.d/pm2.list
RUN apt-get update -yqq
RUN apt-get install -yqq pm2

# download the latest version of pandoc and install it
RUN wget https://github.com/jgm/pandoc/releases/download/$pandoc_ver/pandoc-$pandoc_ver-1-amd64.deb -O pandoc.deb
RUN dpkg -i pandoc.deb && rm pandoc.deb

# install latest texlive
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
RUN tar -zxvf install-tl-unx.tar.gz
COPY texlive.profile .
RUN install-*/install-tl --profile=texlive.profile
RUN rm -rf install-tl*

# export useful texlive paths
ENV PATH /opt/texbin:$PATH
ENV PATH /usr/local/texlive/2019/bin/x86_64-linux:$PATH

# test Latex
RUN wget ftp://www.ctan.org/tex-archive/macros/latex/base/small2e.tex
RUN latex  small2e.tex
RUN pdflatex  small2e.tex
RUN xelatex small2e.tex

RUN  rm -rf /var/lib/apt/lists/*
RUN rm -rf /root/*

WORKDIR /data
VOLUME ["/data"]