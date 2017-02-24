#!/bin/bash
# Requirement: jq (eg. yum install -y jq)
# RESPONSE=curl 'http://GOCD_DOMAIN:8153/go/api/backups' \
#       -u 'GOCD_USER:GOCD_PWD' \
#       -H 'Confirm: true' \
#       -H 'Accept: application/vnd.go.cd.v1+json' \
#       -X POST
RESPONSE=$(cat /root/backup/response.json)

BACKUP_PATH=$(echo $RESPONSE|jq -r '.path' )
BACKUP_DIR=$(echo $RESPONSE |jq -r '.path|split("/")|last')
echo "BACKUP_PATH:" $BACKUP_PATH
echo "BACKUP_DIR:" $BACKUP_DIR
docker cp gocd-server:/$BACKUP_PATH /tmp/
scp -r /tmp/$BACKUP_DIR root@backup.demo.twleansw.com:/root/backup/deliflow-gocd/
#docker exec gocd-server rm -rf
