#!/usr/bin/env python
"""
Rotate logs in mysql.slow_logs table
"""

import sys
import _mysql

db = _mysql.connect(db="mysql", read_default_file=sys.argv[1])
cur = db.query("CALL mysql.rds_rotate_slow_log")