slow_logs_aggregator
====================

Small script, gathered from several places,  just to help
get, aggregate and send reports with slow logs.

just git clone it to your server
and correct in generate_slow_queries_report.sh LogFIleName and LogFile
also update send_report.rb script to send generated report to your team.
Currently it use mailtrap(mailtrap.io) to gather all slow queries logs and after that forward them to support team.

also you can use this script as for MySQL, as for PostgresSQL.
Also you can use it to get logs from RDS(and rotate them)
