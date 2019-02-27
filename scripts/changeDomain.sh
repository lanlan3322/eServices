#!/bin/bash
# example %>./changeDomain.sh newdomain.com
# You need to know the MySQL password to run this

mysql -u root -p -e "update USER set email = concat(substring(email, 1, instr(email,'@')),'$1'); select email from USER;" ess


