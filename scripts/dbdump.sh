#!/bin/bash
echo This script will create a SQL dump
echo of the ess database.
mysqldump -u root -p ess > /var/ess/essBackup.sql

