FROM debian:wheezy

MAINTAINER Christian Luginbühl <dinkel@pimprecords.com>

ENV BTR_BACKUP_URL https://github.com/dinkel/btr-backup.git
ENV BTR_BACKUP_BRANCH master

RUN apt-key adv --keyserver pgp.mit.edu --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main' > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        btrfs-tools \
        git \
        postgresql-client \
        rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch $BTR_BACKUP_BRANCH $BTR_BACKUP_URL /opt/btr-backup

VOLUME ["/backup"]

ADD run.sh /

CMD ["/run.sh"]
