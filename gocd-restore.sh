#!/bin/bash
# Requirement: unzip
# NOTICE: should be used in gocd/gocd-server:17.1.0 the officail image
# Usage: ./gocd-restore.sh /path/to/backup_file.tgz CONTAINER_NAME
BACKUP_FILE=$1
CONTAINER_NAME=$2
BACKUP_DIR=$(basename -s .tgz $BACKUP_FILE)

tar -xzf $BACKUP_FILE -C /tmp/
cd /tmp/$BACKUP_DIR
unzip db.zip
unzip config-dir.zip -d config-dir
unzip config-repo.zip -d config-repo
docker stop $CONTAINER_NAME
docker cp cruise.h2.db $CONTAINER_NAME:/var/lib/go-server/db/h2db/
docker cp config-dir/. $CONTAINER_NAME:/etc/go
docker cp config-repo/. $CONTAINER_NAME:/var/lib/go-server/db/config.git
docker start $CONTAINER_NAME
docker exec -t $CONTAINER_NAME bash -c "mv /etc/go/plugins/* /var/lib/go-server/plugins/external/; rm -rf /etc/go/plugins/; chown -R go:go /var/lib/go-server/ /etc/go; rm -rf /var/lib/go-server/db/h2db/cruise.lock.db; rm -rf /var/lib/go-server/db/h2db/cruise.trace.db"
rm -rf /tmp/$BACKUP_DIR
