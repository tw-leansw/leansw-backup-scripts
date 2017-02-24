#!/bin/bash
# Requirement mongorestore command
# MAKE SURE YOUR CONFIG YOUR DB FIRST (eg. createUser and grantRolesToUser)
# usage:
# 1. restore one specific db: ./test.sh /root/backup/deliflow-mongo/daily/2017-02-24_15h11m.Friday.tgz deliflow-jobs-quartz-docker
# 1. restore default four dbs: ./test.sh /root/backup/deliflow-mongo/daily/2017-02-24_15h11m.Friday.tgz
DBUSERNAME=${DELIFLOW_MONGO_USERNAME:=USERNAME}
DBPASSWORD=${DELIFLOW_MONGO_PASSWORD:=PASSWORD}
DBAUTHDB=${DELIFLOW_MONGO_AUTH_DB:=AUTH_DB}
DBHOST=${DELIFLOW_MONGO_HOST:=XXX.XXX.XXX.XXX}
DBPORT=${DELIFLOW_MONGO_PORT:=27017}

[ "$#" -eq 0 ] && exit 1
BACKUP_FILE=$1
shift
[ "$#" -ne 0 ] && DBNAMES=$@ || DBNAMES=('deliflow-identity-docker' 'deliflow-cd-metrics-docker' 'deliflow-code-metrics-dockerv2' 'deliflow-jobs-quartz-docker')

TEMP_DIR=/tmp/mongo_backup_tmp
mkdir -p $TEMP_DIR
tar -xzf $BACKUP_FILE -C $TEMP_DIR
BACKUP_DIR=$(basename -s .tgz $BACKUP_FILE)
for db in ${DBNAMES[@]}
do
   mongorestore \
   --host $DBHOST:$DBPORT \
   --username ${DBUSERNAME} \
   --password ${DBPASSWORD} \
   --authenticationDatabase ${DBAUTHDB} \
   --db $db \
   $TEMP_DIR/$BACKUP_DIR/$db
done

rm -rf $TEMP_DIR
