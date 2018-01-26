#
# Debian9 (stretch) + apache 2.6
#
# Ideas were taken from https://hub.docker.com/r/josefcs/debian-apache/~/dockerfile/
#

# Pull base image
FROM debian:stretch

# From https://hub.docker.com/_/debian/
# Set utf8 support by default 
ENV LANG C.UTF-8

# Update apt sources to fastest local mirror
RUN sed -i "s/deb.debian.org/mirrors.kernel.org/g" /etc/apt/sources.list

# Make apt-get commands temporarily non-interactive
# Solution from https://github.com/phusion/baseimage-docker/issues/58
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Update apt cache to use fastest local mirror
RUN apt-get update

# Install useful utilities and apache
RUN apt-get install -y apt-utils less nano emacs-nox curl apache2

# Update to local timezone
RUN echo US/Arizona > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# Restore apt-get commands to interactive
RUN echo 'debconf debconf/frontend select Teletype' | debconf-set-selections

# Enable directory colors:
RUN \
sed -i "s/^# export LS/export LS/g" /root/.bashrc && \
sed -i "s/^# eval/eval/g" /root/.bashrc && \
sed -i "s/^# alias l/alias l/g" /root/.bashrc

# Enable apache modules modules
RUN \
a2enmod proxy && \
a2enmod proxy_http && \
a2enmod authn_core && \
a2enmod alias && \
a2enmod headers && \
a2enmod authz_core && \
a2enmod authz_host && \
a2enmod authz_user && \
a2enmod dir && \
a2enmod env && \
a2enmod mime && \
a2enmod reqtimeout && \
a2enmod rewrite && \
a2enmod deflate && \
a2enmod ssl 

# Pipe apache logging to stout/stderr
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

# Force start of container to also also autostart apache
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
