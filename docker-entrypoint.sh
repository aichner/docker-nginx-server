#!/usr/bin/env bash

# developed by Florian Kleber for terms of use have a look at the LICENSE file

# terminate on errors
set -xe

# check if volume is not empty
if [ ! -f /var/www/content/index.php ]; then
    echo 'Setting up content directory'
    # copy content from content src to directory
    cp -r /usr/src/content /var/www/

    # set owner to nobody
    chown -R nobody:nobody /var/www
fi

# execute CMD[]
exec "$@"
