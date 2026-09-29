#!/bin/bash
###############################################################################
#
# Script Name : rman_maintenance.sh
#
# Purpose:
# Performs scheduled RMAN backup repository maintenance.
#
# Maintenance Includes:
# - Crosscheck RMAN backup pieces
# - Crosscheck archived redo logs
# - Delete expired backup metadata
# - Delete expired archived-log metadata
# - Delete obsolete backups according to the RMAN retention policy
#
# Retention Policy:
# - Recovery Window: 14 Days
#
# Oracle Version : 19c
# Database       : ORCL
# Execution Node : RAC1
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
# Maintenance Configuration
##############################

LOG_DIR=/home/oracle/rman_logs

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/rman_maintenance_${TIMESTAMP}.log"

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
# Maintenance Information
##############################

START_TIME=$(date +%s)

echo
echo "========================================================="
echo "Oracle 19c RAC - RMAN Maintenance"
echo "========================================================="
echo "Database       : ${ORACLE_SID}"
echo "Retention      : RECOVERY WINDOW OF 14 DAYS"
echo "Started        : $(date)"
echo

##############################
# RMAN Maintenance
##############################

rman target / log="${LOG_FILE}" <<EOF

CROSSCHECK BACKUP;

CROSSCHECK ARCHIVELOG ALL;

DELETE NOPROMPT EXPIRED BACKUP;

DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;

DELETE NOPROMPT OBSOLETE;

EXIT;

EOF

RMAN_STATUS=$?

##############################
# Maintenance Summary
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
echo "Retention      : RECOVERY WINDOW OF 14 DAYS"
echo "Log File       : ${LOG_FILE}"
echo "Elapsed Time   : ${ELAPSED} seconds"
echo "Finished       : $(date)"
echo "========================================================="

exit ${RMAN_STATUS}
