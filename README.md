docker-backup
=============

A Docker image to backup files, databases, etc. using Btrfs for snapshots. It
uses the  [btr-backup](https://github.com/dinkel/btr-backup) scripts written by
me.

The idea of this image is a consistent environment that backs up the configured
stuff and then exits. There are **no** tools like `cron` installed. I believe
that the host operating system needs to schedule the jobs and control that they
start, run and end OK.

Usage
-----

The presumed initial situation is as follows: One has a more or less complex
hierarchy of Docker containers running, that constitute an application. E.g. a
"web" container, a linked "database" container and a connected data-only volume
that holds persistent data.

All variable or configuration data is either inside the database or inside a
volume container ... otherwise one should reread the base ideas of
containerization.

In order to run a backup job, six "steps" are necessary:

#### Connect Btrfs backup medium to container's /backup

The directory `/backup` is exposed to the host operating system and this is
where the backup is written to. It is expected that this directory is linked to
a Btrfs filesystem attached to the host operating system.

Example (external USB hard drive):

    docker run -d -v /media/backup:/backup [...] dinkel/backup

#### Connect data-only containers as --volumes-from

Connect the data-only container(s) to the backup container. Note that it is
possible that a data-only container exposes multiple directories and that more
than one data-only container can be connected.

Example:

    docker run -d [...] --volumes-from application-config --volumes-from application-data [...] dinkel/backup

#### Connect databases as --link

Databases to backup (by creating a full dump) need to be connected using the
`--link` option. Please note that the "name" after the colon, is the hostname
as known inside the backup container to connect to the database.

Example:

    docker run -d [...] --link application-db:db [...] dinkel/backup

#### Name the "project"

With a backup run, all variable data of an application should be saved, so that
a consistent state is found in one place. Therefore name this "project"
accordingly. It is set as an environment variable.

Example:

    docker run -d [...] -e BACKUP_PROJECT="application-name" [...] dinkel/backup

#### Set directories to backup

Set every *absolute* directory in the backup container you want to backup (ones
that have been included through `--volumes-from`). They need to be separated
with a colon.

Example:

    docker run -d [...] -e BACKUP_FILES_PATHS=/var/www/config:/var/www/data [...] dinkel/backup

#### Set database information to backup

Set the host running the database, port and user credentials. The `_HOST`
variable is mandatory and acts as the trigger to do an actual database backup,
`_USER` and `_PASSWORD` are optional and fall back to default values.

Example (for PostgreSQL):

    docker run -d [...] -e BACKUP_POSTGRESQL_HOST=db -e BACKUP_POSTGRESQL_USER=admin -e BACKUP_POSTGRESQL_PASSWORD=mysecretpassword [...] dinkel/backup

### Finally

We now have a complete example:

    docker run -d -v /media/backup:/backup --volumes-from application-config --volumes-from application-data --link application-db:db -e BACKUP_PROJECT="application-name" -e BACKUP_FILES_PATHS=/var/www/config:/var/www/data -e BACKUP_POSTGRESQL_HOST=db -e BACKUP_POSTGRESQL_USER=admin -e BACKUP_POSTGRESQL_PASSWORD=mysecretpassword dinkel/backup

Environment variables
---------------------

See above for a exemplified explanation. The environment variables are described
in more detail in [btr-backup](https://github.com/dinkel/btr-backup).
