#!/bin/bash -x

# Publish the combined site layout on to the server
rsync -av --exclude='.git/' --exclude='.DS_Store' --exclude='*.swp' --delete lib/ ${MY_WEBUSER}@${MY_WEBHOST}:/var/www/macrophile.com/lib
rsync -av --exclude='.git/' --exclude='.DS_Store' --exclude='*.swp' --delete www/ ${MY_WEBUSER}@${MY_WEBHOST}:/var/www/macrophile.com/dev
