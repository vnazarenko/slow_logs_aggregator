#!/usr/bin/env python
"""
Queries the slowlog database table maintained by Amazon RDS and outputs it in
the normal MySQL slow log text format.
"""

import sys
import _mysql

db = _mysql.connect(db="mysql", read_default_file=sys.argv[1])
db.query("""SELECT * FROM slow_log ORDER BY start_time""")
r = db.use_result()

print """/usr/sbin/mysqld, Version: 5.1.49-3-log ((Debian)). started with:
Tcp port: 3306  Unix socket: /var/run/mysqld/mysqld.sock
Time                 Id Command    Argument
"""

while True:
    results = r.fetch_row(maxrows=100, how=1)
    if not results:
        break

    for row in results:
        row['year'] = row['start_time'][2:4]
        row['month'] = row['start_time'][5:7]
        row['day'] = row['start_time'][8:10]
        row['time'] = row['start_time'][11:]

        hours = int(row['query_time'][0:2])
        minutes = int(row['query_time'][3:5])
        seconds = int(row['query_time'][6:8])
        row['query_time_f'] = hours * 3600 + minutes * 60 + seconds

        hours = int(row['lock_time'][0:2])
        minutes = int(row['lock_time'][3:5])
        seconds = int(row['lock_time'][6:8])
        row['lock_time_f'] = hours * 3600 + minutes * 60 + seconds

        if not row['sql_text'].endswith(';'):
            row['sql_text'] += ';'

        print '# Time: {year}{month}{day} {time}'.format(**row)
        print '# User@Host: {user_host}'.format(**row)
        print '# Query_time: {query_time_f}  Lock_time: {lock_time_f} Rows_sent: {rows_sent}  Rows_examined: {rows_examined}'.format(**row)
        print 'use {db};'.format(**row)
        print row['sql_text']