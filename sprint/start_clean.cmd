
echo "This simple script starts a clean instance of drupal running in ddev and imports a starter database."

ddev start
ddev exec git fetch
ddev exec git reset --hard origin/8.6.x
ddev exec composer install
ddev import-db --src=.ddev/.db_dumps/d8_installed_db.sql.gz
ddev exec drush cr
ddev describe
 
echo####
echo# Mailhog: 		http://sprint-[ts].ddev.local:8025/
echo#
echo# DB Admin: 	http://sprint-[ts].ddev.local:8036/
echo#
echo# IRC: 			http://sprint-[ts].ddev.local:9000/
echo#
echo# IDE: 			http://sprint-[ts].ddev.local:8000/  
echo#				(U:username  P:password)
echo#
echo# For more info see README.txt
echo####