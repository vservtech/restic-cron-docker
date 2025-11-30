#!/bin/bash

echo "restic version: $(restic version)"
echo "supercronic version: $(supercronic -version)"
echo "ssh version:"
ssh -V
echo "sqlite3 version: $(sqlite3 --version)"
echo "pg_dump version: $(pg_dump --version)"
echo "mysqldump version: $(mysqldump --version)"
echo "bun version: $(bun -v)"