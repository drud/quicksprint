To access
Website:     http://sprint-[ts].ddev.local:8080/
             https://sprint-[ts].ddev.local:8443/
             (User:admin Pass:admin)

Mailhog:     http://sprint-[ts].ddev.local:8025/
phpMyAdmin:  http://sprint-[ts].ddev.local:8036/
Chat:        https://drupal.org/chat to join Drupal Slack or drupalchat.eu!


Common ddev commands to know:

ddev start (-h)                         [start project]
ddev rm (-h)                            [stop and remove project, nothing lost]
ddev import-db --src=[path to db] (-h)  [import database]
ddev help

For full ddev documentation see https://ddev.readthedocs.io/
And support on Stack Overflow: https://stackoverflow.com/tags/ddev


To reset this instance and start on a new issue:
./start_clean.sh                    [note: overwrites any changes you have made]
