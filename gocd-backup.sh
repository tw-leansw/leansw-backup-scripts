#!/bin/bash
# Requirement: jq (eg. yum install -y jq)

RESPONSE=$(curl "http://${GOCD_DOMAIN_NAME:=gocd.dev.twleansw.com}:8153/go/api/backups" \
      -u "${GOCD_USER}:${GOCD_PASSWORD}" \
      -H 'Confirm: true' \
      -H 'Accept: application/vnd.go.cd.v1+json' \
      -X POST)

BACKUP_PATH=$(echo $RESPONSE|jq -r '.path' )
BACKUP_DIR=$(echo $RESPONSE |jq -r '.path|split("/")|last')
echo "BACKUP_PATH:" $BACKUP_PATH
echo "BACKUP_DIR:" $BACKUP_DIR

GOCD_HOST=${GOCD_HOST:=gocd.dev.twleansw.com}
GOCD_CONTAINER_NAME=${GOCD_CONTAINER_NAME:=gocd-server}

ssh root@$GOCD_HOST << EOF
docker cp $GOCD_CONTAINER_NAME:$BACKUP_PATH /tmp/
cd /tmp
tar -czf $BACKUP_DIR.tgz $BACKUP_DIR
rm -rf /tmp/$BACKUP_DIR
docker exec $GOCD_CONTAINER_NAME rm -rf $BACKUP_PATH
EOF

scp -r root@$GOCD_HOST:/tmp/$BACKUP_DIR.tgz /root/backup/deliflow-gocd/
find /root/backup/deliflow-gocd/ -type f -mtime +10 -name '*.tgz' | xargs rm -rf
