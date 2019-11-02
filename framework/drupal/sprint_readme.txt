To access
Website:     http://sprint-[ts].ddev.site:8080/
             https://sprint-[ts].ddev.site:8443/
             (User:admin Pass:admin)

Mailhog:     http://sprint-[ts].ddev.site:8025/
phpMyAdmin:  http://sprint-[ts].ddev.site:8036/
Chat:       https://drupal.org/chat to join Drupal Slack or DrupalChat.me!

Common ddev commands to know:

ddev start (-h)                         [start project]
ddev stop (-h)                          [stop project, nothing lost]
ddev poweroff                           [stop all projects and resources, nothing lost]
ddev import-db --src=[path to db] (-h)  [import database]
ddev help

For full ddev documentation see https://ddev.readthedocs.io/
And support on Stack Overflow: https://stackoverflow.com/tags/ddev

If you need to switch Drupal branches, for example to 9.0.x, you can
use the utility switch_branch.sh. Although the script stashes changes to
avoid losing your changes, you're best to save them away yourself first.
switch_branch.sh also drops your existing database, so after running it
you'll need to do a manual web-based install.

Examples:
./switch_branch.sh 9.0.x
./switch_branch.sh 8.8.x
