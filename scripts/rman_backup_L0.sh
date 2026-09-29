#!/bin/bash
###############################################################################
#
# Script Name : rman_backup_level0.sh
#
# Purpose:
# Performs a weekly RMAN Level 0 backup of the Oracle 19c RAC database.
#
# Backup Includes:
# - Complete RAC database
# - Archived redo logs not previously backed up
# - Current control file
#
# Oracle Version : 19c
# Database       : ORCL
# Execution Node : RAC1
#
# Retention Policy:
# - Recovery Window: 14 Days
#
###############################################################################

##############################
# Oracle Environment
##############################

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export ORACLE_SID=orcl1
export PATH=$ORACLE_HOME/bin:$PATH
export NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'

##############################
# Backup Configuration
##############################

BACKUP_ROOT='+FRA/ORCL/RMAN'
LOG_DIR=/home/oracle/rman_logs

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/rman_level0_${TIMESTAMP}.log"

##############################
# Create Log Directory
##############################

mkdir -p "${LOG_DIR}"

if [ $? -ne 0 ]; then
    echo "ERROR: Unable to create log directory: ${LOG_DIR}"
    exit 1
fi

##############################
# Verify Oracle Home
##############################

if [ ! -d "${ORACLE_HOME}" ]; then
    echo "ERROR: ORACLE_HOME does not exist: ${ORACLE_HOME}"
    exit 1
fi

##############################
# Verify Database Status
##############################

DB_STATUS=$(sqlplus -s / as sysdba <<SQL
set pages 0 feedback off verify off heading off
select open_mode from v\$database;
exit;
SQL
)

DB_STATUS=$(echo "${DB_STATUS}" | xargs)

if [ "${DB_STATUS}" != "READ WRITE" ]; then
    echo
    echo "ERROR: Database is not OPEN READ WRITE."
    echo "Current Status: ${DB_STATUS}"
    echo
    exit 1
fi

##############################
# Backup Information
##############################

START_TIME=$(date +%s)

echo
echo "========================================================="
echo "Oracle 19c RAC - RMAN Level 0 Backup"
echo "========================================================="
echo "Database       : ${ORACLE_SID}"
echo "Backup Target  : ${BACKUP_ROOT}"
echo "Retention      : RECOVERY WINDOW OF 14 DAYS"
echo "Started        : $(date)"
echo

##############################
# RMAN Backup
##############################

rman target / log="${LOG_FILE}" <<EOF

RUN {

    ALLOCATE CHANNEL c1 DEVICE TYPE DISK;

    BACKUP AS COMPRESSED BACKUPSET
        INCREMENTAL LEVEL 0
        FORMAT '${BACKUP_ROOT}/L0_%d_%T_%U.bkp'
        DATABASE;

    BACKUP AS COMPRESSED BACKUPSET
        FORMAT '${BACKUP_ROOT}/ARCH_%d_%T_%U.bkp'
        ARCHIVELOG ALL NOT BACKED UP 1 TIMES;

    BACKUP AS COMPRESSED BACKUPSET
        FORMAT '${BACKUP_ROOT}/CTRL_%d_%T_%U.bkp'
        CURRENT CONTROLFILE;

    RELEASE CHANNEL c1;

}

EXIT;

EOF

RMAN_STATUS=$?

##############################
# Backup Summary
##############################

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))

echo
echo "========================================================="

if [ ${RMAN_STATUS} -eq 0 ]; then
    echo "Status         : SUCCESS"
else
    echo "Status         : FAILED"
fi

echo "Database       : ${ORACLE_SID}"
echo "Backup Target  : ${BACKUP_ROOT}"
echo "Retention      : RECOVERY WINDOW OF 14 DAYS"
echo "Log File       : ${LOG_FILE}"
echo "Elapsed Time   : ${ELAPSED} seconds"
echo "Finished       : $(date)"
echo "========================================================="

exit ${RMAN_STATUS}
EOF

chmod 750 /home/oracle/rman_scripts/rman_backup_level0.sh

bash -n /home/oracle/rman_scripts/rman_backup_level0.sh

if [ $? -eq 0 ]; then
    echo
    echo "Level 0 script syntax validation: SUCCESS"
else
    echo
    echo "Level 0 script syntax validation: FAILED"
    exit 1
fi
