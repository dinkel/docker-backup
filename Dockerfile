FROM debian:jessie

MAINTAINER Christian Luginbühl <dinkel@pimprecords.com>

ENV BTR_BACKUP_URL https://github.com/dinkel/btr-backup.git
ENV BTR_BACKUP_BRANCH master

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys A4A9406876FCBD3C456770C88C718D3B5072E1F5
ENV MYSQL_MAJOR 5.6
RUN echo "deb http://repo.mysql.com/apt/debian/ jessie mysql-${MYSQL_MAJOR}" > /etc/apt/sources.list.d/mysql.list

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        btrfs-tools \
        ca-certificates \
        git \
        ldap-utils \
        mysql-client \
        postgresql-client \
        rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch $BTR_BACKUP_BRANCH $BTR_BACKUP_URL /opt/btr-backup

VOLUME ["/backup"]

ADD run.sh /

CMD ["/run.sh"]
