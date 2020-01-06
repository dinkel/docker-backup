FROM debian:buster

MAINTAINER Christian Luginbühl <dinkel@pimprecords.com>

ENV BTR_BACKUP_URL https://github.com/dinkel/btr-backup.git
ENV BTR_BACKUP_BRANCH master

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        btrfs-tools \
        ca-certificates \
        git \
        gnupg2 \
        ldap-utils \
        mariadb-client \
        rsync \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        postgresql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --branch $BTR_BACKUP_BRANCH $BTR_BACKUP_URL /opt/btr-backup

VOLUME ["/backup"]

ADD run.sh /

CMD ["/run.sh"]
