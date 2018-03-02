
echo "This simple script just starts drupal running in ddev and imports a starter database."

cd drupal8
ddev start
ddev import-db --src=.db_dumps/d8_installed_db.sql.gz
ddev exec drush cr
ddev describe
