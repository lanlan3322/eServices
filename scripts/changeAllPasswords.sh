#!/bin/bash
# example %>./changeAllPasswords.sh newpassword
# you need to know the MySQL password to run this
echo This script will change all the passwords in
echo the database - use with caution.

mysql -u root -p -e "update USER set password = '$1'; select email, password from USER;" ess


