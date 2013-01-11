#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LogFIleName=postgresql-$(date -v-1d +%F_000000).log
LogFile=/Users/viktornazarenko/code/slow_logs_aggregator/${LogFIleName}
AggFile=${DIR}/slow_query.log.aggrerated
ArchDir=${DIR}/archive/
ResultLog=${DIR}/result.log
SendScript=${DIR}/send_report.rb
if [ "${DB_TYPE}" == "mysql" ]; then
  LogType="genlog"
else
  LogType="pglog"
fi

# IF RDS we need to get slow log data
if [ "${RDS}" == "1" ]; then
  MysqlConfig=${DIR}/mysql_db.cnf
  GetSript=${DIR}/get_slow_queries_log.py
  LogFile=${DIR}/${LogFIleName}
  python $GetSript $MysqlConfig > $LogFile
fi

#aggregate slow log
mk-query-digest --limit=30 --type=${LogType} $LogFile > $AggFile
#
##archive slow logs
ArchFile=${ArchDir}slow-queries-$(date +%F_%H-%M-%S).log.tar.gz
tar czPf $ArchFile $LogFile
#
Line=$(grep -n 'Query 21:' $AggFile|awk -F: '{print $1}')

if [[ -z "$Line" ]]; then
  echo $(ruby $SendScript $AggFile 2>&1)
else
  Line=$(expr $Line - 1)
  head -$Line $AggFile > $ResultLog
  echo $(ruby $SendScript $ResultLog 2>&1)
fi

##rm $LogFile
rm $AggFile
rm $ResultLog

# Rotate slow logs. Will move them into the backup table slow_log_backup. If
# that table exists it's overwritten with the primary slow log.
# So with this strategy we can still access yesterday's slow log by querying
# slow_log_backup.

if [ "${RDS}" == "1" ]; then
  RotateScript=${DIR}/rotate_slow_logs.py
  python $RotateScript $MysqlConfig
fi
