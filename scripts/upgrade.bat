REM Run after new version is copied into /var/ess/application
REM Run as admin

REM Copy the required images over if they are not there.

REM If there are database updates they should be checked and then done.

mklink \var\ess\application\webapps\ess-app\WEB-INF\web.xml \var\ess\xmls\web.xml

mklink \var\ess\application\webapps\ess-app\WEB-INF\classes\ess_en_XX.properties \var\ess\xmls\en\ess_en_XX.properties

mklink \var\ess\application\webapps\ess-app\WEB-INF\classes\ess_en_XX.properties \var\ess\xmls\fr\ess_en_XX.properties


