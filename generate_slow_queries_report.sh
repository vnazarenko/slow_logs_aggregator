#!/bin/bash
echo "initializing"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DB_TYPE=mysql
LogFIleName=mysql-slow.log
LogFile=/var/log/mysql/${LogFIleName}
AggFile=${DIR}/slow_query.log.aggrerated
ArchDir=${DIR}/archive/
ResultLog=${DIR}/result.log
SendScript=${DIR}/send_report.rb
if [ "${DB_TYPE}" == "mysql" ]; then
  LogType="slowlog"
else
  LogType="pglog"
fi

# IF RDS we need to get slow log data
if [ "${RDS}" == "1" ]; then
  echo "gathering data from RDS"
  MysqlConfig=${DIR}/mysql_db.cnf
  GetSript=${DIR}/get_slow_queries_log.py
  LogFile=${DIR}/${LogFIleName}
  python $GetSript $MysqlConfig > $LogFile
fi

#aggregate slow log
echo "creating aggregated log"
mk-query-digest --limit=30 --type=${LogType} --filter '$event->{bytes} < 512_576' $LogFile > $AggFile
# you can use filter with some other params
#mk-query-digest --limit=30 --type=${LogType} --filter '!($event->{fingerprint} =~ m/^insert/i)' $LogFile > $AggFile
#
##archive slow logs
echo "archive aggregated log"
ArchFile=${ArchDir}slow-queries-aggrerated-$(date +%F_%H-%M-%S).log.tar.gz
tar czPf $ArchFile $AggFile
#

##rm $LogFile
rm $AggFile

# Rotate slow logs. Will move them into the backup table slow_log_backup. If
# that table exists it's overwritten with the primary slow log.
# So with this strategy we can still access yesterday's slow log by querying
# slow_log_backup.

if [ "${RDS}" == "1" ]; then
  RotateScript=${DIR}/rotate_slow_logs.py
  python $RotateScript $MysqlConfig
fi
