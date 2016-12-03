#!/bin/sh

# kernsync wrapper for cron daemon


# I really need to set excludes one day maybe
# its trashing my hard disk synching $HOME all the time

# backup root
export BACKUPROOT=/mnt/data/sync-latest

# backup targets
# taken out $HOME for now, it was 6GB
export BACKUPTARGETS="/boot:/lib:/root:/etc:/var/lib/mysql:/sbin/kernsync.sh"

# command

/sbin/kernsync.sh
