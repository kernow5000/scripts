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

# script only runs as root, investigate into that.


# this will be shown on running the script with -h for help
function print_info()
{
echo "rip.sh $VERSION"
echo "============"
echo "Copyright (C) 2004 by kernow <kernow@stalemeat.net>"
echo "This is free software, and you are welcome to redistribute it under"
echo "the conditions of the GNU General Public License."
echo
echo "Usage:"
echo "$(basename $0) (rips whole cd using default options for convenience"
echo "$(basename $0) [options]"
echo
echo -e "Options:"
echo -e "-d <device> \tUse this cdrom device (default is /dev/cdrom)"
echo -e "-b <bitrate> \tLAME encoding bitrate (default is 192) BROKEN"
echo -e "-p <prefix> \tUse this prefix (default is track-xx, i.e track-xx.mp3)"
echo -e "-o <outputdir> \tUse this output directory (default is mp3/)"
echo -e "-x \t\tEject cd when finished."
echo -e "-h or --help \tDisplay this help."
echo -e "-v \t\tDisplay script version."
echo
}


# setup some defaults

# default bitrate for encoding
BITRATE=192

# device for cdparanoia to use, usually /dev/cdrom but not always
CDP_DEVICE="/dev/cdrom"

# ID3 tag support not in this version ( I decided, so there )
BOTHERTAGGING=""
ID3_ARTIST=""
ID3_ALBUM=""

# if id3_artist is set to an artist, use that for the output directory
# else, use the default output dir value, uhm, what about "SPACED FILENAMES.MP3"
# grr, not even escape sequences work 100 percent correct sigh
OUTPUTDIR="mp3"
QUIET="NO"
EJECTCD="NO"

# a prefix for the mp3, it needs to be different or maybe use ID3 Artist name I dunno
PREFIX="track-"

# the track counter, used in the main ripping loop
TRACKCOUNT=1

# command based defaults, apps must be in your path, tweak these if you wish.
PARANOIA_EXEC="cdparanoia -q -d $CDP_DEVICE"
LAME_EXEC="lame --quiet -b $BITRATE cdda.wav"
ID3_EXEC="id3tag $MP3FILENAME --artist=$ID3_ARTIST --album=$ID3_ALBUM"
# end of defaults

# here we check to see if the binaries we need are in our path
# this works, but its fucking useless, cosmetically
#cdparanoia 1>&2
#if [ $? = "127" ]; then
#  echo "cdparanoia binary not found in your PATH"
#  exit 1
#fi

#lame 1>&2
#if [ $? = "127" ]; then 
#    echo "LAME binary not found in your PATH"
#  exit 1
#fi

#id3tag 1>&2
#if [ $? = "127" ]; then 
#   echo "id3tag binary not in your PATH"
#  exit 1
#fi



# now, get some values from command line arguments, 
while test $# -gt 0; do
	if test "$1" = "-h" -o "$1" = "--help"; then
		print_info
		exit 1
		
	elif test "$1" = "-v"; then
	  echo $(basename $0) v$VERSION
	  echo "by kernow, 2004 (kernow@stalemeat.net)"
	  exit 1
	  
	elif test "$1" = "-x"; then
	  EJECTCD="YES"
	
	elif test "$1" = "-b"; then
	  echo "Setting bitrate to something (fake)"
		
	elif test "$1" = "-p"; then
	  test -z "$2"
	  if [ $? = "0" ]; then
	    echo "No prefix specified."
	    exit 1
	  else
	    PREFIX=$2
	    echo "Prefix is set to $PREFIX"
	  fi
	shift
	
	elif test "$1" = "-o"; then 
	  test -z "$2"
	  if [ $? = "0" ]; then
	    echo "No output directory specified."
	    exit 1
	  else
	    OUTPUTDIR=$2
	    echo "Output directory is set to $OUTPUTDIR"
	  fi
	  shift

	elif test "$1" = "-d"; then
		if test -b "$2"; then
			CDP_DEVICE="$2"
			echo "Using $CDP_DEVICE"
		else
			test -z "$2"
			if [ $? = "0" ]; then
			  echo "No block device specified."
			  exit 1
			else
			  echo "$2 is not a valid block device."
			  exit 1
			fi
		fi
	shift
	
	else
		echo "Invalid parameter: $1"
		echo "Try $0 -h for help."
		echo
		exit 1
	fi
	
	shift
done

# dont worry about id3tag yet, not that important in this version


# after here is where the real work begins bois

# Check what type of disc is in the drive, if any
cdparanoia -sqQ 1>&2
# this redirection shit doesnt totally work for me
if [ $? = "1" ]; then
  echo "Failed reading track $TRACKCOUNT. Mo cd in drive. or disc is not a music cd."
  exit 1
fi  
# if the drive tray is open you get an additional "cannot read TOC" error regardless of redirection, how come I'm not getting that error anymore? eh?


# make the directory first, if an artist is filled in
# use that instead for clarity, fuck knows what to do about 
# spaced artist names, which they all are, by the way :(

# DOH !! - we need to check $OUTPUTDIR isnt equal to mp3/ also
# then we know we have a differing outputdir
# also id3tag support has been canned in this version so.. meh
# we could really comment this out without any harm at all.
#test -z $ID3_ARTIST
#if [ $? = "0" ]; then
#  echo "Using default output directory"
#else
#  echo "Using id3_artist as output_dir"
#  OUTPUTDIR=$ID3_ARTIST
#fi
# this block is only going to be useful in the next version I guess, id3 and all that

# check outputdir dont exist, if it don't - make it
# found out how to do spaced filenames too woo
# edit: no I havent actually :(
test -e $OUTPUTDIR
if [ $? = "1" ]; then
  mkdir $OUTPUTDIR
fi

# prompt the user that we are about to *actually* start ripping, or attempt to 
echo "Ripping and Encoding audioCD to MP3 format."


# the main encoding loop, increment trackcounter and rip until cdparanoia complains 
while [ $? != "1" ] ; do
  
  # rip a wav from the audiocd
  $PARANOIA_EXEC $TRACKCOUNT
  
  if [ $? = "1" ]; then
    echo -e  "\nOperation complete."
    if [ $EJECTCD = "YES" ]; then
      echo "Ejecting cd (because of -x switch)"
      eject $CDP_DEVICE
    fi  
    # could call some cleanup funcs here before exit I guess.
    exit 0
  fi
   
  # encode to MP3 with LAME
  $LAME_EXEC

  # we should have an mp3 now
  # if cdda.wav exists, which it should after ripping a track, delete it after encoding to mp3
  test -e cdda.wav
  if [ $? = "0" ]; then
    rm cdda.wav
  fi

  # 'prefix up' the mp3 file, works ok for now I guess.
  test $TRACKCOUNT -le 9

  if [ $? = "0" ]; then
    # track-0x.mp3
    MP3FILENAME=$(echo -n $PREFIX ; echo -n "0"; echo -n $TRACKCOUNT ; echo ".mp3")
  else
    # track-x.mp3
    MP3FILENAME=$(echo -n $PREFIX ; echo -n $TRACKCOUNT ; echo ".mp3")
  fi

  # rename the mp3 file
  mv cdda.wav.mp3 $MP3FILENAME

  #echo "id3tagging the mp3"
  #verbose again - sigh
  # tag it here, dont worry for now though
  #$ID3_EXEC
	
  # move to the output directory
  mv $MP3FILENAME $OUTPUTDIR
	 
  # move to the next track on the audiocd
  let TRACKCOUNT=TRACKCOUNT+1

done
# end of hairy encoding loop


# end of file/script
# kernow 2004