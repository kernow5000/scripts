#!/bin/sh

# a better backup script? - depends on rsync

# v0.4 - A working script
# problems with fat32, but its not this script its ext2->fat32 without tarring problems
# add a switch to tar it up after? maybe
# what do I do about recursive / synching? uh?

# &>filename

# BACKUPROOT is where you want to backup to, defaults to /tmp/backup
# $BACKUPTARGETS are the dirs you want to back up, seperated by a colon


# delete the current log, rotate in next version
rm /var/log/kernsync.log

# Check $BACKUPROOT has been set, if not default to /tmp/backup-$USER
if [ "$BACKUPROOT" = "" ]; then
  echo "<!> BACKUPROOT not set, defaulting to /tmp/backup-$USER"
   BACKUPROOT=/tmp/backup-$USER
else
  echo "<*> BACKUPROOT is set to $BACKUPROOT"
fi
# end


# check backuptargets is set, if not then exit
if [ "$BACKUPTARGETS" = "" ]; then
  echo '<!> BACKUPTARGETS variable not set, please set at least one target'
  exit 1
else
  echo "<*> BACKUPTARGETS found, attempting to backup your targets..."
fi

# the backup loop, test this out
# set the builtin delimiter
IFS=":"

# replace this with rsync command soon
for token in $BACKUPTARGETS; do
  # check its readable
  if [ -r $token ]; then
    # sync it
    rsync -Rav --delete $token $BACKUPROOT &> /var/log/kernsync.log
    if [ "$?" = "1" ]; then
      echo "<!> Failed sync on $token, skipping."
    else
      echo "<*> Success synching $token."
    fi  
    else
      echo "<!> Failed sync on $token, skipping."
    fi
done

# end of file
