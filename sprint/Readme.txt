To access
Website:   http://sprint-[ts].ddev.local:8080/
           https://sprint-[ts].ddev.local:8443/
           (U:admin P:admin)

IDE:       http://sprint-[ts].ddev.local:8000/
           (U:username  P:password)

Mailhog:   http://sprint-[ts].ddev.local:8025/

DB Admin:  http://sprint-[ts].ddev.local:8036/


Common ddev commands to know:

ddev start                          [start project]
ddev stop                           [stop project]
ddev import-db --src=[path to db]   [import database]

For full ddev documentation see:
	https://ddev.readthedocs.io/


To reset this instance and start on a new issue:
./start_clean.sh                    [note: replaces local changes]