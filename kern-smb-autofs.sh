############################################################################
#    Copyright (C) 2004 by kernow                                          #
#    kernow@stalemeat.net                                                  #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################

#!/bin/sh

VERSION="0.1"

# this is just a drawing board for my SMB-autofs-manager
# it would run every 30 seconds, for example, and dynamically
# manage /mnt/network, creating/destroying symlinks for hosts and shares
# and also creating/destroying appropriate config lines in /etc/auto.mnt
# which is my automounter config, which I know can be edited on the fly 
# with no visible harm, obviously I'll only be touching the SMB parts anyway 

# Things I need to find out
# does a netbios name need to be in /etc/hosts? with an IP, my guess is no.


# begin defaults here.

# we need a basepoint, for the symlinks
SYMLINK_BASE="./mnt/network"
# and the location of the automount basepoint
AUTOMOUNT_BASE="./mnt/auto"
# this will be using /etc/auto.mnt or /etc/auto.network soon.
AUTOMOUNT_CONFIG="/etc/fstab"

# these will be autoupdated in a loop, and symlinks created from them.
HOST=""
SHARE=""

# display what we are doing, just for verbosity.
echo "Samba automount config manager V$VERSION."
echo "Using $AUTOMOUNT_BASE as the automounter base."
echo "Using $SYMLINK_BASE as the symlink base."
echo "Using $AUTOMOUNT_CONFIG as the automounter configuration file."


# check the automount base directory exists, if not, we won't be able to
# symlink to it, so exit.
test -e $AUTOMOUNT_BASE
if [ $? = "1" ]; then
  echo "Fatal - automount base $AUTOMOUNT_BASE not found, exiting."
  exit 1
fi

# check the automounter config exists, if not, exit
test -e $AUTOMOUNT_CONFIG
if [ $? = "1" ]; then
  echo "Fatal - automount config $AUTOMOUNT_CONFIG not found, exiting."
  exit 1
fi

# if the symlink base doesn't exist, create it I guess :)
test -e $SYMLINK_BASE
if [ $? = "1" ]; then
  echo "Symlink base $SYMLINK_BASE does not exist, creating it."
  mkdir -p $SYMLINK_BASE
fi

# hmm, this comparison will be happening every 60 seconds or even less,
# will this be a chugging resource hog or what? every 3 seconds for example.


# delete everything in the $SYMLINK_BASE, it will be remade soon remember
# its easier to delete it all in there, and start again symlinking it all,
# than to check whats in there already and add appropriately, ugh.
echo "Deleting all stale symlinks in the symlink base $SYMLINK_BASE."
rm -rf $SYMLINK_BASE/*


# if I wrote the damn parser/symlink engine in c, it would just involve a 
# simple call to it here, such as 
# $ENGINE_CMD="./smb_eng -f $SMBTREE_OUT -b $AUTOMOUNT_BASE -c $AUTOMOUNT_CONFIG
# -s $SYMLINK_BASE"
# sigh.. eternal.. it would then make the links by itself and edit the
# automounter config, but see how messy that is already.. GRR.
# I'd rather keep it in this damn script :)

# now we need to run the right 'smbtree' command
# to get the latest 'smb hosts and shares' then parse it.
SMBTREE_OUT="smbtree.out"
SMBTREE_CMD="smbtree -N > $SMBTREE_OUT"
# -N is from the man page, it doesn't ask for a password.

# we can get the workgroup easily enough , by this below
WORKGROUP=$(cat $SMBTREE_OUT | head -1)
echo "Got the workgroup, it is $WORKGROUP."
# we don't really need the workgroup, but we can grep it and get the rest
# echo "stripping off workgroup at line 1 of $SMBTREE_OUT"
cat $SMBTREE_OUT | grep -v $WORKGROUP > $SMBTREE_OUT.stripped
# hah, now we have just a list of hosts and shares.. cool eh?
# remember to change blech.stripped to the actual smbtree.out file
# so we are basically 'stripping off' the workgroup at the top, and
# overwriting smbtree.out with a new nonworkgroup stripped copy

# echo "getting a hostname on line 1 of $SMBTREE_OUT.stripped"
HOST=$(cat $SMBTREE_OUT.stripped | head -1)
# need to trim the leading backslashes off
HOST=$(echo $HOST | tr '\\' --delete) # | (| tr A-Z a-z for lowercase)
# convert to lower case or what? no, because we need to compare sadly
# I guess making symlinks in lower case could be classed as 'cosmetic'
echo "Got the host, it is $HOST."

# *** my god - this parser is shit and needs a rewrite *** 
# argh - why am I finding this difficult eh? we need an .. algorithm sigh


# create some fake symlinks to test the mechanism out.
# just realised, it'll show YOU too on in there, excellent.
# these will be created properly from the latest parsed smbtree results.
echo "Creating some fake hosts and shares."

HOST="ulysses"
SHARE="dump"
mkdir -p $SYMLINK_BASE/$HOST/$SHARE

HOST="bottleneck"
SHARE="cdrom"
mkdir -p $SYMLINK_BASE/$HOST/$SHARE

HOST="fortbuche"
SHARE="dump"
mkdir -p $SYMLINK_BASE/$HOST/$SHARE
SHARE="drivers"
mkdir -p $SYMLINK_BASE/$HOST/$SHARE
# this is because the host didn't change
# end the playing around

#     SYMLINKING
# an example of something like the symlink command would be ... gehhh
#SYMLINK_CMD="ln -s $AUTOMOUNT_BASE/$AUTOMOUNT_MAP $SYMLINK_BASE/$HOST/$SHARE"

#     EDITING OF AUTOMOUNTER CONFIG
# I actually think the config editing should be done before the symlinking
# but its easier to visualize it this way around by seeing the symlinks
# move around as it parses smbtree, hmm I guess it doesn't make much difference.
# an example config line that would be added to the automounter config would be
# MAPNAME -OPTIONS  :HOST:/SHARE
# fortbuche_dump -rw,fstype=smbfs,user=kernow,password=	 fortbuche:/dump
# or something very similar, christ it'll get hairy at that point eh?

# clean up, why not?
unset HOST
unset SHARE

echo "Operation successful. Exiting with return code 0."
exit 0

# end of file/script
# kernow 2005