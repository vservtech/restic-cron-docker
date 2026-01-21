#!/bin/bash

echo "restic version: $(restic version)"
echo "supercronic version: $(supercronic -version)"
echo "ssh version:"
ssh -V
echo "sqlite3 version: $(sqlite3 --version)"
echo "pg_dump version: $(pg_dump --version)"
echo "pg_dump16 version: $(pg_dump16 --version)"
echo "pg_dump17 version: $(pg_dump17 --version)"
echo "pg_restore version: $(pg_restore --version)"
echo "pg_restore16 version: $(pg_restore16 --version)"
echo "pg_restore17 version: $(pg_restore17 --version)"
echo "psql version: $(psql --version)"
echo "psql16 version: $(psql16 --version)"
echo "psql17 version: $(psql17 --version)"
echo "mysqldump version: $(mysqldump --version)"
echo "bun version: $(bun -v)"