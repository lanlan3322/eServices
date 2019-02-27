#!/bin/bash

#Run after new version is copied into /var/ess/application
#Run under sudo

#Copy the required images over if they are not there.

#If there are database updates they should be checked and then done.

chmod 775 /var/ess/application/scripts/*.sh

ln /var/ess/xmls/web.xml /var/ess/application/webapps/ess-app/WEB-INF/web.xml
ln /var/ess/xmls/en/ess_en_XX.properties /var/ess/application/webapps/ess-app/WEB-INF/classes/ess_en_XX.properties
ln /var/ess/xmls/fr/ess_fr_XX.properties /var/ess/application/webapps/ess-app/WEB-INF/classes/ess_fr_XX.properties




